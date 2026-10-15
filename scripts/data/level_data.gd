class_name LevelData
extends Resource

@export var id: String = ""
@export var name_key: String = "BEDROOM"
@export var chapter_key: String = "CHAPTER_MOBILE"
@export var welcome_key: String = "WELCOME"
@export var content_version: int = 1
@export var items: Array[ItemData] = []
@export var placements: Array[ItemPlacementRule] = []
@export var containers: Array[ContainerData] = []
@export var objectives: Array[ObjectiveData] = []
@export var cleaning: CleaningTaskData
@export var tool: ToolData
@export var hazard: HazardData
@export var collectible: CollectibleData

func item(item_id: String) -> ItemData:
	for entry: ItemData in items:
		if entry.id == item_id:
			return entry
	return null

func placement(target_id: String) -> ItemPlacementRule:
	for entry: ItemPlacementRule in placements:
		if entry.id == target_id:
			return entry
	return null

func validate() -> PackedStringArray:
	var errors: PackedStringArray = []
	if id.is_empty():
		errors.append("Missing level ID")
	var ids: Dictionary[String, bool] = {}
	for group: Array in [items, placements, containers, objectives]:
		for entry: Resource in group:
			if entry == null or entry.id.is_empty() or ids.has(entry.id):
				errors.append("Missing or duplicate resource ID")
			else:
				ids[entry.id] = true
	if not errors.is_empty():
		return errors
	for entry: ItemData in items:
		var has_destination: bool = false
		for rule: ItemPlacementRule in placements:
			if entry.category in rule.categories:
				has_destination = true
		if not has_destination:
			errors.append("No destination: " + entry.id)
	var container_ids: PackedStringArray = []
	for container: ContainerData in containers:
		container_ids.append(container.id)
	for rule: ItemPlacementRule in placements:
		if rule.slots.is_empty() or rule.categories.is_empty() or rule.snap_pixels <= 0:
			errors.append("Invalid placement: " + rule.id)
		if not rule.container_id.is_empty() and rule.container_id not in container_ids:
			errors.append("Unknown container: " + rule.id)
	var resolved: PackedStringArray = []
	var objective_ids: PackedStringArray = []
	for goal: ObjectiveData in objectives:
		objective_ids.append(goal.id)
		if goal.kind not in ["items", "clean", "hazard", "collectible"]:
			errors.append("Unknown objective kind: " + goal.id)
	for goal: ObjectiveData in objectives:
		for dependency: String in goal.dependencies:
			if dependency not in objective_ids:
				errors.append("Unknown dependency: " + dependency)
	for _pass: int in range(objectives.size()):
		for goal: ObjectiveData in objectives:
			if goal.id in resolved:
				continue
			var ready: bool = true
			for dependency: String in goal.dependencies:
				if dependency not in resolved:
					ready = false
			if ready:
				resolved.append(goal.id)
	if resolved.size() != objectives.size():
		errors.append("Objective cycle")
	if cleaning == null or cleaning.columns < 1 or cleaning.rows < 1:
		errors.append("Invalid cleaning task")
	if tool == null or hazard == null or collectible == null:
		errors.append("Missing task resources")
	elif item(hazard.blocking_item_id) == null or item(collectible.reveal_item_id) == null:
		errors.append("Unknown hazard or collectible item")
	return errors
