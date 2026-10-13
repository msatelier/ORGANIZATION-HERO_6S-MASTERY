extends SceneTree

const LEVEL: LevelData = preload("res://resources/levels/bedroom.tres")
var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("FAIL: " + description)
	else:
		print("PASS: " + description)

func _run() -> void:
	TranslationCatalog.install()
	check(LEVEL.validate().is_empty(), "bedroom data validates")
	var state: GameSession = GameSession.new(LEVEL)
	check(not state.finish(), "incomplete room cannot finish")
	check(state.place("book_mint", "basket") == "WRONG_CATEGORY", "wrong category is rejected")
	check(state.placements.is_empty(), "rejection preserves state")
	check(state.place("shirt_gold", "wardrobe") == "OPEN_CONTAINER_FIRST", "closed container rejects placement")
	check(state.place("shirt_gold", "basket").is_empty(), "alternate clothing destination works")
	check(state.place("shirt_coral", "basket").is_empty(), "second clothing slot works")
	check(state.place("sock_blue", "basket") == "TARGET_FULL", "capacity is enforced")
	check(state.toggle_container("cabinet"), "container opens")
	check(state.place("shirt_gold", "wardrobe").is_empty(), "same item can move between valid destinations")
	check(state.undo() and state.placements["shirt_gold"] == "basket", "undo restores prior destination")
	var oriented: ItemPlacementRule = ItemPlacementRule.new()
	oriented.categories = PackedStringArray(["clothing"])
	oriented.slots = PackedVector3Array([Vector3.ZERO])
	oriented.angle_tolerance = 0.2
	check(PlacementRules.validate(LEVEL.item("shirt_gold"), oriented, 0, true, PI) == "WRONG_ORIENTATION", "orientation tolerance is validated")
	check(state.place("unknown", "shelf") == "INVALID_TARGET", "unknown IDs are rejected")
	check(not state.hazard_safe() and not state.collectible_visible(), "risk and hidden collectible reflect initial state")
	check(state.place("plush", "toy_box").is_empty() and state.hazard_safe(), "moving toy clears walkway")
	check(state.collectible_visible() and state.discover(), "moving blocker reveals collectible")
	check(not state.discover(), "collectible cannot be awarded twice")
	check(state.undo() and state.found and not state.hazard_safe(), "undo preserves permanent collectible")
	var added: int = state.clean_at(Vector2(0.4, 0.5))
	check(added > 0 and state.clean_ratio() > 0, "cleaning changes spatial coverage")
	check(state.clean_at(Vector2(0.4, 0.5)) == 0, "repeated area does not count twice")
	check(state.clean_at(Vector2(-0.1, 0.5)) == 0, "outside surface cannot clean")
	var resumed: GameSession = GameSession.new(LEVEL)
	check(resumed.restore(state.snapshot()) and resumed.cleaned == state.cleaned and resumed.placements == state.placements, "snapshot restores positions and exact coverage")
	var corrupt: Dictionary = state.snapshot()
	corrupt["cleaned"] = "!!!!"
	check(not resumed.restore(corrupt), "malformed coverage is rejected without decoding error")
	corrupt = state.snapshot()
	corrupt["slots"]["shirt_coral"] = 0
	check(not resumed.restore(corrupt), "duplicate occupied slot is rejected")
	corrupt = state.snapshot()
	corrupt["completed"] = true
	check(not resumed.restore(corrupt), "fake completion is rejected")
	corrupt = state.snapshot()
	corrupt["move_count"] = -1
	check(not resumed.restore(corrupt), "negative move count is rejected")
	check(resumed.placements == state.placements, "invalid restores do not partially mutate state")

	var playable: GameSession = GameSession.new(LEVEL)
	playable.toggle_container("cabinet")
	for item: ItemData in LEVEL.items:
		for rule: ItemPlacementRule in LEVEL.placements:
			if item.category in rule.categories:
				check(playable.place(item.id, rule.id).is_empty(), "complete placement: " + item.id)
				break
	for y: int in range(9):
		var previous: Vector2 = Vector2(-1, -1)
		for x: int in range(13):
			var point: Vector2 = Vector2(float(x) / 12.0, float(y) / 8.0)
			playable.clean_at(point, previous)
			previous = point
	check(playable.clean_ratio() >= LEVEL.cleaning.completion_ratio, "accessible strokes cover required area")
	check(playable.can_finish() and playable.finish() and playable.stars() == 2, "Relax completes without optional collectible")
	check(playable.place("book_mint", "shelf") == "LEVEL_FINISHED", "completed state is protected")

	var cyclic: LevelData = LEVEL.duplicate(true)
	cyclic.objectives[0].dependencies = PackedStringArray(["find"])
	cyclic.objectives[3].dependencies = PackedStringArray(["sort"])
	check("Objective cycle" in cyclic.validate(), "objective dependency cycles are detected")
	var variant: LevelData = LEVEL.duplicate(true)
	variant.id = "home_bedroom_variant"
	variant.items[0].id = "shirt_variant"
	check(variant.validate().is_empty() and GameSession.new(variant).place("shirt_variant", "basket").is_empty(), "content variant works without changing rules")

	var directory: String = "res://build/test-store-%d" % Time.get_ticks_usec()
	var store: SaveStore = SaveStore.new(directory)
	var persisted: GameSession = GameSession.new(LEVEL)
	persisted.place("book_mint", "shelf")
	check(store.save(persisted) == OK, "first versioned save is written")
	persisted.place("book_cream", "shelf")
	check(store.save(persisted) == OK, "second save retains valid backup")
	var loaded: GameSession = store.load_session(LEVEL)
	check(loaded.placements.size() == 2, "primary JSON resumes progress")
	write_text(directory.path_join("progress.json"), "{ truncated")
	loaded = store.load_session(LEVEL)
	check(loaded.placements.size() == 1 and store.status == "SAVE_RECOVERED", "truncated primary recovers backup")
	var newer: Dictionary = persisted.snapshot()
	newer["schema_version"] = 2
	write_text(directory.path_join("progress.json"), JSON.stringify(newer))
	var protected_store: SaveStore = SaveStore.new(directory)
	protected_store.load_session(LEVEL)
	check(protected_store.locked and protected_store.save(persisted) == ERR_UNAVAILABLE, "future schema is protected from overwrite")
	check(JSON.parse_string(FileAccess.get_file_as_string(directory.path_join("progress.json")))["schema_version"] == 2, "future file remains intact")
	newer = persisted.snapshot()
	newer["schema_version"] = "bad"
	write_text(directory.path_join("progress.json"), JSON.stringify(newer))
	var malformed_store: SaveStore = SaveStore.new(directory)
	check(malformed_store.load_session(LEVEL).placements.size() == 1, "invalid schema type recovers without runtime error")
	newer = persisted.snapshot()
	newer["level_id"] = 3
	write_text(directory.path_join("progress.json"), JSON.stringify(newer))
	check(SaveStore.new(directory).load_session(LEVEL).placements.size() == 1, "invalid level ID type recovers safely")
	newer = persisted.snapshot()
	newer["content_version"] = 2
	write_text(directory.path_join("progress.json"), JSON.stringify(newer))
	var future_content_store: SaveStore = SaveStore.new(directory)
	future_content_store.load_session(LEVEL)
	check(future_content_store.locked and future_content_store.save(persisted) == ERR_UNAVAILABLE, "future content version is preserved")
	var missing_item: LevelData = LEVEL.duplicate(true)
	missing_item.items[0] = null
	check(not missing_item.validate().is_empty(), "null authored resource is reported without dereference error")

	TranslationServer.set_locale("en")
	check(tr("CLOTH_TOOL") == "Use cloth", "native English translation loads before CSV import")
	TranslationServer.set_locale("es")
	check(tr("CLOTH_TOOL") == "Usar paño", "native Spanish translation loads")
	print("DOMAIN RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func write_text(path: String, text: String) -> void:
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(text)
	file.close()
