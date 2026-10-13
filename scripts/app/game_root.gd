class_name GameRoot
extends Node3D

const LEVEL: LevelData = preload("res://resources/levels/bedroom.tres")

var session: GameSession
var store: SaveStore
var room: BedroomView
var rig: CameraController
var hud: GameHUD
var interaction: InteractionController
var feedback: FeedbackManager
var save_directory: String = "user://"
var saving_enabled: bool = true
var settings: Dictionary = {"music": 0.35, "effects": 0.65, "reduced": false, "haptics": true, "locale": "es"}
var settings_timer: Timer
var finish_hint_shown: bool = false
var save_error_shown: bool = false
var closing: bool = false

func _ready() -> void:
	var errors: PackedStringArray = LEVEL.validate()
	if not errors.is_empty():
		push_error("Invalid level data: " + str(errors))
		get_tree().quit(1)
		return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-dir="):
			save_directory = argument.trim_prefix("--save-dir=")
		elif argument == "--no-save":
			saving_enabled = false
	store = SaveStore.new(save_directory)
	TranslationCatalog.install()
	_load_settings()
	TranslationServer.set_locale(settings["locale"])
	session = store.load_session(LEVEL) if saving_enabled else GameSession.new(LEVEL)
	room = BedroomView.new(LEVEL)
	add_child(room)
	room.animated = not settings["reduced"]
	room.bind(session)
	rig = CameraController.new()
	add_child(rig)
	feedback = FeedbackManager.new()
	add_child(feedback)
	feedback.apply_settings(settings)
	hud = GameHUD.new()
	add_child(hud)
	hud.bind(session)
	hud.apply_settings(settings)
	interaction = InteractionController.new()
	add_child(interaction)
	interaction.configure(session, room, rig, hud)
	interaction.message.connect(_message)
	interaction.selected.connect(func(id: String) -> void:
		hud.selected_id = id
		hud.refresh()
	)
	interaction.stroke_finished.connect(_stroke_finished)
	session.action_applied.connect(_action)
	session.changed.connect(_changed)
	hud.request_clean.connect(_toggle_clean)
	hud.request_undo.connect(func() -> void:
		interaction.cancel()
		if session.undo():
			_message("UNDONE", true)
	)
	hud.request_overview.connect(func() -> void:
		interaction.cancel()
		rig.overview()
	)
	hud.request_finish.connect(func() -> void:
		interaction.cancel()
		if session.finish():
			rig.overview()
	)
	hud.request_hint.connect(_hint)
	hud.request_restart.connect(_restart)
	hud.request_comparison.connect(_compare)
	hud.settings_changed.connect(_settings_changed)
	hud.settings_opened.connect(func() -> void: interaction.cancel())
	settings_timer = Timer.new()
	settings_timer.one_shot = true
	settings_timer.wait_time = 0.35
	settings_timer.timeout.connect(_save_settings)
	add_child(settings_timer)
	get_tree().auto_accept_quit = false
	hud.show_message(store.status if not store.status.is_empty() else "WELCOME", true)
	_changed()

func _toggle_clean() -> void:
	if session.completed or hud.settings_overlay.visible:
		return
	interaction.cancel()
	interaction.clean_tool = not interaction.clean_tool
	hud.using_cloth = interaction.clean_tool
	hud.selected_id = ""
	room.select("")
	if interaction.clean_tool:
		rig.focus_surface(LEVEL.cleaning.position)
	else:
		rig.overview()
	hud.refresh()

func _message(key: String, positive: bool) -> void:
	hud.show_message(key, positive)
	if not positive:
		feedback.play("invalid")

func _action(kind: String) -> void:
	feedback.play(kind)
	_save()

func _changed() -> void:
	if session.can_finish() and not session.completed and not finish_hint_shown:
		finish_hint_shown = true
		hud.show_message("READY_TO_INSPECT")

func _stroke_finished() -> void:
	_save()
	feedback.play("clean")

func _save() -> void:
	if not saving_enabled:
		return
	var result: Error = store.save(session)
	if result != OK and not save_error_shown:
		save_error_shown = true
		hud.show_message("SAVE_NEWER" if store.locked else "SAVE_FAILED", false)

func _hint() -> void:
	interaction.cancel()
	if session.completed:
		hud.show_message("ROOM_COMPLETE")
		return
	for item: ItemData in LEVEL.items:
		if not session.placements.has(item.id):
			for rule: ItemPlacementRule in LEVEL.placements:
				if item.category in rule.categories:
					room.select(item.id)
					room.highlight(rule.id)
					if not rule.container_id.is_empty() and not session.opened[rule.container_id]:
						hud.show_message("HINT_OPEN")
					else:
						hud.show_message(tr("HINT_PLACE") % [tr(item.name_key), tr(rule.name_key)])
					return
	if session.clean_ratio() < LEVEL.cleaning.completion_ratio:
		hud.show_message("CLEAN_HINT")
	elif not session.found:
		hud.show_message("HINT_COLLECTIBLE")
	else:
		hud.show_message("READY_TO_INSPECT")

func _compare(before: bool) -> void:
	interaction.cancel()
	room.before_mode = before
	room.animated = false
	room.refresh()
	room.animated = not settings["reduced"]
	rig.overview()

func _restart() -> void:
	interaction.cancel()
	var next: GameSession = GameSession.new(LEVEL)
	next.found = session.found
	var result: Error = store.save(next) if saving_enabled else ERR_UNAVAILABLE
	if result != OK:
		hud.show_message("SAVE_FAILED", false)
		return
	get_tree().reload_current_scene()

func _settings_changed(values: Dictionary) -> void:
	interaction.cancel()
	settings = values
	TranslationServer.set_locale(settings["locale"])
	feedback.apply_settings(settings)
	room.animated = not settings["reduced"]
	room.refresh_labels()
	hud.refresh_text()
	settings_timer.start()

func _load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	if config.load(save_directory.path_join("settings.cfg")) != OK:
		return
	for key: String in ["music", "effects"]:
		var value: Variant = config.get_value("player", key, settings[key])
		if (value is float or value is int) and is_finite(float(value)):
			settings[key] = clampf(float(value), 0, 1)
	for key: String in ["reduced", "haptics"]:
		var value: Variant = config.get_value("player", key, settings[key])
		if value is bool:
			settings[key] = value
	var language: Variant = config.get_value("player", "locale", "es")
	if language in ["es", "en"]:
		settings["locale"] = language

func _save_settings() -> void:
	if not saving_enabled:
		return
	if DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(save_directory)) != OK:
		hud.show_message("SAVE_FAILED", false)
		return
	var config: ConfigFile = ConfigFile.new()
	for key: String in settings:
		config.set_value("player", key, settings[key])
	if config.save(save_directory.path_join("settings.cfg")) != OK:
		hud.show_message("SAVE_FAILED", false)

func _notification(what: int) -> void:
	if interaction == null:
		return
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		interaction.cancel()
		_save()
		_save_settings()
		feedback.pause_music(true)
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		feedback.pause_music(false)
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		_shutdown()

func _shutdown() -> void:
	if closing:
		return
	closing = true
	interaction.cancel()
	_save()
	_save_settings()
	feedback.stop_all()
	await get_tree().process_frame
	await get_tree().process_frame
	get_tree().quit()
