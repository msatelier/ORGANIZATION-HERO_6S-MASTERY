extends SceneTree

func _initialize() -> void:
	var level: LevelData = load("res://resources/levels/bedroom.tres")
	var failures: int = 0
	if not level.validate().is_empty() or level.items.size() != 8:
		failures += 1
		push_error("Exported level definition is incomplete")
	var wardrobe: ItemPlacementRule = level.placement("wardrobe")
	if wardrobe == null or wardrobe.categories != PackedStringArray(["clothing"]) or wardrobe.slots.size() != 3:
		failures += 1
		push_error("Export lost packed placement data")
	if wardrobe != null and not wardrobe.slots.is_empty() and not wardrobe.slots[0].is_equal_approx(Vector3(2.25, 0.925, -2.38)):
		failures += 1
		push_error("Export changed destination coordinates")
	var state: GameSession = GameSession.new(level)
	if not state.place("shirt_gold", "basket").is_empty():
		failures += 1
		push_error("Exported rules cannot organize an item")
	TranslationCatalog.install()
	TranslationServer.set_locale("en")
	if tr("CLOTH_TOOL") != "Use cloth":
		failures += 1
		push_error("Exported translation missing")
	print("EXPORT DATA RESULT: 5 checks, %d failures" % failures)
	quit(1 if failures > 0 else 0)
