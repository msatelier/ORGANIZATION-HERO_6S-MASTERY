class_name GameSession
extends RefCounted

signal changed
signal action_applied(kind: String, context: Dictionary)

var level: LevelData
var placements: Dictionary[String, String] = {}
var slots: Dictionary[String, int] = {}
var opened: Dictionary[String, bool] = {}
var cleaned: PackedByteArray = []
var cleaned_count: int = 0
var found: bool = false
var completed: bool = false
var move_count: int = 0
var undo_stack: Array[Dictionary] = []

func _init(definition: LevelData) -> void:
	level = definition
	cleaned.resize(level.cleaning.columns * level.cleaning.rows)
	cleaned.fill(0)
	for container: ContainerData in level.containers:
		opened[container.id] = false

func placement_reason(item_id: String, target_id: String, yaw: float = 0.0) -> String:
	# Preview and commit share the same rules without mutating the session.
	if completed:
		return "LEVEL_FINISHED"
	var item: ItemData = level.item(item_id)
	var rule: ItemPlacementRule = level.placement(target_id)
	var occupied: int = 0
	for other_id: String in placements:
		if other_id != item_id and placements[other_id] == target_id:
			occupied += 1
	var is_open: bool = rule != null and (rule.container_id.is_empty() or opened.get(rule.container_id, false))
	var reason: String = PlacementRules.validate(item, rule, occupied, is_open, yaw)
	if not reason.is_empty():
		return reason
	if placements.get(item_id, "") == target_id:
		return "ALREADY_PLACED"
	return ""

func place(item_id: String, target_id: String, yaw: float = 0.0) -> String:
	var reason: String = placement_reason(item_id, target_id, yaw)
	if not reason.is_empty():
		return reason
	var rule: ItemPlacementRule = level.placement(target_id)
	undo_stack.append({"placements": placements.duplicate(), "slots": slots.duplicate()})
	var chosen_slot: int = 0
	var used: Array[int] = []
	for other_id: String in placements:
		if other_id != item_id and placements[other_id] == target_id:
			used.append(slots[other_id])
	while chosen_slot in used:
		chosen_slot += 1
	placements[item_id] = target_id
	slots[item_id] = chosen_slot
	move_count += 1
	changed.emit()
	action_applied.emit("place", {"item_id": item_id, "target_id": target_id})
	return ""

func undo() -> bool:
	if completed or undo_stack.is_empty():
		return false
	var previous: Dictionary = undo_stack.pop_back()
	placements.assign(previous["placements"])
	slots.assign(previous["slots"])
	changed.emit()
	action_applied.emit("undo", {})
	return true

func toggle_container(container_id: String) -> bool:
	if completed or not opened.has(container_id):
		return false
	opened[container_id] = not opened[container_id]
	changed.emit()
	action_applied.emit("container", {"container_id": container_id, "opened": opened[container_id]})
	return true

func clean_at(uv: Vector2, previous: Vector2 = Vector2(-1, -1)) -> int:
	if completed or uv.x < 0 or uv.x > 1 or uv.y < 0 or uv.y > 1:
		return 0
	var distance: float = 0.0 if previous.x < 0 else previous.distance_to(uv)
	var steps: int = maxi(1, ceili(distance / (level.tool.brush_radius * 0.35)))
	var added: int = 0
	for step: int in range(steps + 1):
		var point: Vector2 = uv if previous.x < 0 else previous.lerp(uv, float(step) / float(steps))
		added += _brush(point)
	if added > 0:
		cleaned_count += added
		changed.emit()
	return added

func _brush(uv: Vector2) -> int:
	var columns: int = level.cleaning.columns
	var rows: int = level.cleaning.rows
	var radius: float = level.tool.brush_radius
	var added: int = 0
	for y: int in range(maxi(0, floori((uv.y - radius) * rows)), mini(rows, ceili((uv.y + radius) * rows))):
		for x: int in range(maxi(0, floori((uv.x - radius) * columns)), mini(columns, ceili((uv.x + radius) * columns))):
			var cell: Vector2 = Vector2((x + 0.5) / columns, (y + 0.5) / rows)
			# Compensate aspect ratio so the brush is round on the actual surface.
			var delta: Vector2 = cell - uv
			delta.x *= level.cleaning.size.x / level.cleaning.size.y
			var index: int = y * columns + x
			if delta.length() <= radius and cleaned[index] == 0:
				cleaned[index] = 1
				added += 1
	return added

func clean_ratio() -> float:
	return float(cleaned_count) / float(cleaned.size())

func hazard_safe() -> bool:
	return placements.has(level.hazard.blocking_item_id)

func collectible_visible() -> bool:
	return not found and placements.has(level.collectible.reveal_item_id)

func discover() -> bool:
	if not collectible_visible() or completed:
		return false
	found = true
	changed.emit()
	action_applied.emit("collectible", {})
	return true

func objective_done(goal: ObjectiveData) -> bool:
	for dependency: String in goal.dependencies:
		for other: ObjectiveData in level.objectives:
			if other.id == dependency and not objective_done(other):
				return false
	match goal.kind:
		"items":
			return placements.size() == level.items.size()
		"clean":
			return clean_ratio() >= level.cleaning.completion_ratio
		"hazard":
			return hazard_safe()
		"collectible":
			return found
	return false

func can_finish() -> bool:
	for goal: ObjectiveData in level.objectives:
		if goal.required and not objective_done(goal):
			return false
	return true

func finish() -> bool:
	if completed or not can_finish():
		return false
	completed = true
	changed.emit()
	action_applied.emit("finish", {})
	return true

func score() -> int:
	return placements.size() * 100 + roundi(clean_ratio() * 500) + (200 if hazard_safe() else 0) + (250 if found else 0)

func stars() -> int:
	return (3 if found else 2) if completed else 0

func snapshot() -> Dictionary:
	return {
		"schema_version": 1, "content_version": level.content_version, "level_id": level.id,
		"placements": placements.duplicate(), "slots": slots.duplicate(), "opened": opened.duplicate(),
		"cleaned": Marshalls.raw_to_base64(cleaned), "found": found,
		"completed": completed, "move_count": move_count
	}

func restore(data: Dictionary) -> bool:
	var schema: Variant = data.get("schema_version")
	var content: Variant = data.get("content_version")
	var level_id: Variant = data.get("level_id")
	if (not schema is int and not schema is float) or (not content is int and not content is float) or not level_id is String:
		return false
	if schema != 1 or content != level.content_version or level_id != level.id:
		return false
	if not data.get("placements") is Dictionary or not data.get("slots") is Dictionary or not data.get("opened") is Dictionary:
		return false
	if not data.get("found") is bool or not data.get("completed") is bool or not data.get("cleaned") is String:
		return false
	var moves: Variant = data.get("move_count")
	if (not moves is int and not moves is float) or moves < 0 or moves > 1000000 or float(moves) != floorf(float(moves)):
		return false
	var encoded: String = data["cleaned"]
	var format_check: RegEx = RegEx.create_from_string("^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$")
	if encoded.length() != 4 * ceili(float(cleaned.size()) / 3.0) or format_check.search(encoded) == null:
		return false
	var raw: PackedByteArray = Marshalls.base64_to_raw(encoded)
	if raw.size() != cleaned.size():
		return false
	var total: int = 0
	for value: int in raw:
		if value != 0 and value != 1:
			return false
		total += value
	var candidate: GameSession = GameSession.new(level)
	for item_id: Variant in data["placements"]:
		if not item_id is String or not data["placements"][item_id] is String:
			return false
		var rule: ItemPlacementRule = level.placement(data["placements"][item_id])
		var item: ItemData = level.item(item_id)
		var index: Variant = data["slots"].get(item_id)
		if rule == null or item == null or item.category not in rule.categories:
			return false
		if (not index is int and not index is float) or float(index) != floorf(float(index)) or index < 0 or index >= rule.slots.size():
			return false
		for other_id: String in candidate.placements:
			if candidate.placements[other_id] == rule.id and candidate.slots[other_id] == int(index):
				return false
		candidate.placements[item_id] = rule.id
		candidate.slots[item_id] = int(index)
	if data["slots"].size() != candidate.placements.size() or data["opened"].size() != candidate.opened.size():
		return false
	for container_id: Variant in data["opened"]:
		if not container_id is String or not candidate.opened.has(container_id) or not data["opened"][container_id] is bool:
			return false
		candidate.opened[container_id] = data["opened"][container_id]
	candidate.cleaned = raw
	candidate.cleaned_count = total
	candidate.found = data["found"]
	if data["completed"] and not candidate.can_finish():
		return false
	placements.assign(candidate.placements)
	slots.assign(candidate.slots)
	opened.assign(candidate.opened)
	cleaned = raw
	cleaned_count = total
	found = candidate.found
	completed = data["completed"]
	move_count = int(moves)
	undo_stack.clear()
	changed.emit()
	return true
