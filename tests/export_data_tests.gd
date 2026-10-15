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
	if level.item("shirt_gold").shape != "shirt" or level.item("sock_blue").shape != "socks" or level.item("bottle").sound_profile != "plastic":
		failures += 1
		push_error("Export lost visual or material sound metadata")
	var music: AudioStreamWAV = load("res://assets/audio/bedroom_theme.wav")
	if music == null or music.format != AudioStreamWAV.FORMAT_16_BITS or not is_equal_approx(music.get_length(), 40.0) or music.loop_mode != AudioStreamWAV.LOOP_FORWARD:
		failures += 1
		push_error("Exported music format or complete loop is missing")
	var kitchen: LevelData = load("res://resources/levels/kitchen.tres")
	if not kitchen.validate().is_empty() or kitchen.items.size() != 8 or kitchen.placement("cupboard").slots.size() != 2:
		failures += 1
		push_error("Exported kitchen or destination data missing")
	if kitchen.item("dish_towel").shape != "towel" or tr(kitchen.name_key) != "Kitchen" or not level.placement("basket").is_bin:
		failures += 1
		push_error("Export lost new presentation metadata or localization")
	print("EXPORT DATA RESULT: 9 checks, %d failures" % failures)
	quit(1 if failures > 0 else 0)
