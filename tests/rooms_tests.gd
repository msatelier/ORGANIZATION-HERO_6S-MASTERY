extends SceneTree

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _run() -> void:
	TranslationCatalog.install()
	var directory: String = "user://room-tests-%d" % Time.get_ticks_usec()
	var bedroom: LevelData = RoomCatalog.BEDROOM
	var kitchen: LevelData = RoomCatalog.KITCHEN
	check(kitchen.validate().is_empty() and kitchen.items.size() == 8, "authored kitchen validates")
	check(RoomCatalog.find(kitchen.id) == kitchen and RoomCatalog.find("unknown") == null, "catalog resolves only known rooms")
	check(RoomCatalog.save_path(directory, bedroom) == directory, "legacy bedroom location remains unchanged")
	var original: GameSession = GameSession.new(bedroom)
	original.place("plush", "toy_box")
	original.discover()
	original.clean_at(Vector2(0.4, 0.5))
	var old_store: SaveStore = SaveStore.new(directory)
	check(old_store.save(original) == OK, "legacy save written")
	var old_bytes: PackedByteArray = FileAccess.get_file_as_bytes(directory.path_join("progress.json"))
	var kitchen_directory: String = RoomCatalog.save_path(directory, kitchen)
	var store: SaveStore = SaveStore.new(kitchen_directory)
	var state: GameSession = store.load_session(kitchen)
	check(state.placements.is_empty() and not state.found, "new kitchen does not inherit bedroom progress")
	check(state.place("mug_sage", "cupboard") == "OPEN_CONTAINER_FIRST", "kitchen storage obeys shared access rule")
	check(state.place("plate_blue", "pantry") == "WRONG_CATEGORY", "kitchen rejects wrong category")
	state.toggle_container("cabinet")
	for item: ItemData in kitchen.items:
		for rule: ItemPlacementRule in kitchen.placements:
			if state.placement_reason(item.id, rule.id).is_empty():
				check(state.place(item.id, rule.id).is_empty(), "kitchen placement: " + item.id)
				break
	check(state.hazard_safe() and state.discover(), "cleared kitchen path reveals its own collectible")
	for y: int in range(12):
		for x: int in range(20):
			state.clean_at(Vector2(float(x) / 19.0, float(y) / 11.0))
	check(state.can_finish() and state.finish() and state.stars() == 3, "shared objectives complete kitchen with three stars")
	check(store.save(state) == OK and store.save(state) == OK, "kitchen writes progress and backup in its own directory")
	var resumed: GameSession = SaveStore.new(kitchen_directory).load_session(kitchen)
	check(resumed.snapshot() == state.snapshot(), "kitchen resumes exact completed state")
	check(FileAccess.get_file_as_bytes(directory.path_join("progress.json")) == old_bytes, "kitchen never rewrites legacy bedroom bytes")
	var old_resumed: GameSession = SaveStore.new(directory).load_session(bedroom)
	check(old_resumed.snapshot() == original.snapshot(), "old bedroom progress remains readable")
	_write(kitchen_directory.path_join("progress.json"), "{broken")
	check(SaveStore.new(kitchen_directory).load_session(kitchen).completed, "kitchen recovers its own backup")
	var newer: Dictionary = state.snapshot()
	newer["content_version"] = 999
	_write(kitchen_directory.path_join("progress.json"), JSON.stringify(newer))
	var newer_store: SaveStore = SaveStore.new(kitchen_directory)
	newer_store.load_session(kitchen)
	check(newer_store.locked and newer_store.save(state) == ERR_UNAVAILABLE, "future kitchen data stays protected")
	check(SaveStore.new(directory).load_session(bedroom).found, "future kitchen cannot block bedroom loading")
	for language: String in ["es", "en"]:
		TranslationServer.set_locale(language)
		var translated: bool = true
		for level: LevelData in RoomCatalog.levels():
			for key: String in [level.name_key, level.chapter_key, level.welcome_key]:
				translated = translated and tr(key) != key
			for goal: ObjectiveData in level.objectives:
				translated = translated and tr(goal.name_key) != goal.name_key and tr(goal.name_key + "_SHORT") != goal.name_key + "_SHORT"
			for item: ItemData in level.items:
				translated = translated and tr(item.name_key) != item.name_key
			for rule: ItemPlacementRule in level.placements:
				translated = translated and tr(rule.name_key) != rule.name_key
		check(translated, "both rooms have localized content: " + language)
	print("ROOMS RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _write(path: String, value: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()
