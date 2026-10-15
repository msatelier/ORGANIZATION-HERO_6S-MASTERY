class_name GameRoot
extends Node3D

var level: LevelData = RoomCatalog.BEDROOM
var session: GameSession
var store: SaveStore
var sessions: Dictionary[String, GameSession] = {}
var stores: Dictionary[String, SaveStore] = {}
var room: RoomView
var rig: CameraController
var hud: GameHUD
var interaction: InteractionController
var feedback: FeedbackManager
var save_directory: String = "user://"
var saving_enabled: bool = true
var settings: Dictionary = {"music": 0.35, "effects": 0.65, "reduced": false, "haptics": true, "locale": "es", "room": "home_bedroom_01"}
var settings_timer: Timer
var finish_hint_shown: bool = false
var save_error_shown: bool = false
var closing: bool = false

func _ready() -> void:
	for definition: LevelData in RoomCatalog.levels():
		var errors: PackedStringArray = definition.validate()
		if not errors.is_empty():
			push_error("Invalid level data: " + definition.id + str(errors))
			get_tree().quit(1)
			return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-dir="):
			save_directory = argument.trim_prefix("--save-dir=")
		elif argument == "--no-save":
			saving_enabled = false
	TranslationCatalog.install()
	_load_settings()
	TranslationServer.set_locale(settings["locale"])
	rig = CameraController.new()
	add_child(rig)
	rig.animated = not settings["reduced"]
	feedback = FeedbackManager.new()
	add_child(feedback)
	feedback.apply_settings(settings)
	hud = GameHUD.new()
	add_child(hud)
	hud.apply_settings(settings)
	hud.layout_changed.connect(rig.set_play_area)
	get_viewport().size_changed.connect(func() -> void:
		if interaction != null:
			interaction.cancel()
	)
	hud.request_clean.connect(_toggle_clean)
	hud.request_cancel.connect(func() -> void: interaction.cancel())
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
	hud.rooms_opened.connect(_open_rooms)
	hud.request_level.connect(func(id: String) -> void: _switch_level.call_deferred(id))
	settings_timer = Timer.new()
	settings_timer.one_shot = true
	settings_timer.wait_time = 0.35
	settings_timer.timeout.connect(_save_settings)
	add_child(settings_timer)
	get_tree().auto_accept_quit = false
	# Load both summaries from validated sessions; a future-version save stays protected.
	for definition: LevelData in RoomCatalog.levels():
		var room_store: SaveStore = SaveStore.new(RoomCatalog.save_path(save_directory, definition))
		stores[definition.id] = room_store
		sessions[definition.id] = room_store.load_session(definition) if saving_enabled else GameSession.new(definition)
	_activate_level(RoomCatalog.find(settings["room"]))

func _activate_level(definition: LevelData) -> void:
	if interaction != null:
		interaction.cancel()
		interaction.free()
	if session != null:
		session.action_applied.disconnect(_action)
		session.changed.disconnect(_changed)
	if room != null:
		room.free()
	level = definition
	session = sessions[level.id]
	store = stores[level.id]
	finish_hint_shown = false
	save_error_shown = false
	room = RoomCatalog.create_view(level)
	add_child(room)
	room.animated = not settings["reduced"]
	room.bind(session)
	rig.set_room_frame(room.overview_points())
	hud.bind(session)
	interaction = InteractionController.new()
	add_child(interaction)
	interaction.configure(session, room, rig, hud)
	interaction.message.connect(_message)
	interaction.selected.connect(func(id: String) -> void:
		hud.selected_id = id
		hud.destination_id = ""
		hud.destination_reason = ""
		hud.refresh()
	)
	interaction.destination_changed.connect(func(id: String, reason: String) -> void:
		hud.destination_id = id
		hud.destination_reason = reason
		hud.refresh()
	)
	interaction.stroke_finished.connect(_stroke_finished)
	interaction.cleaning_motion.connect(feedback.cleaning_motion)
	session.action_applied.connect(_action)
	session.changed.connect(_changed)
	hud.show_message(store.status if not store.status.is_empty() else level.welcome_key, true)
	_update_room_progress()
	_changed()

func _switch_level(id: String) -> void:
	var definition: LevelData = RoomCatalog.find(id)
	if definition == null:
		return
	if definition == level:
		hud.rooms_overlay.visible = false
		return
	interaction.cancel()
	if not store.locked and not _save():
		hud.rooms_overlay.visible = false
		return
	_activate_level(definition)
	settings["room"] = id
	_save_settings()

func _open_rooms() -> void:
	interaction.cancel()
	_update_room_progress()

func _update_room_progress() -> void:
	var summary: Dictionary = {}
	for id: String in sessions:
		var state: GameSession = sessions[id]
		summary[id] = {"completed": state.completed, "stars": state.stars(), "started": state.move_count > 0 or state.cleaned_count > 0 or state.found}
	hud.set_room_progress(summary)

func _toggle_clean() -> void:
	if session.completed or hud.settings_overlay.visible or hud.rooms_overlay.visible:
		return
	interaction.cancel()
	interaction.clean_tool = not interaction.clean_tool
	hud.using_cloth = interaction.clean_tool
	hud.selected_id = ""
	room.select("")
	if interaction.clean_tool:
		rig.focus_surface(level.cleaning.position, level.cleaning.size)
	else:
		rig.overview()
	hud.refresh()

func _message(key: String, positive: bool) -> void:
	hud.show_message(key, positive)
	if not positive:
		feedback.play("invalid")

func _action(kind: String, context: Dictionary) -> void:
	if kind == "place":
		var item: ItemData = level.item(context["item_id"])
		feedback.play(kind, item.sound_profile)
	elif kind == "container":
		feedback.play("container_open" if context["opened"] else "container_close")
	else:
		feedback.play(kind)
	_save()

func _changed() -> void:
	if session.can_finish() and not session.completed and not finish_hint_shown:
		finish_hint_shown = true
		hud.show_message("READY_TO_INSPECT")

func _stroke_finished() -> void:
	_save()

func _save() -> bool:
	if not saving_enabled:
		return true
	var result: Error = store.save(session)
	if result != OK:
		if not save_error_shown:
			save_error_shown = true
			hud.show_message("SAVE_NEWER" if store.locked else "SAVE_FAILED", false)
		return false
	return true

func _hint() -> void:
	interaction.cancel()
	if interaction.clean_tool:
		_toggle_clean()
	if session.completed:
		hud.show_message("ROOM_COMPLETE")
		return
	for item: ItemData in level.items:
		if not session.placements.has(item.id):
			var closed_target: ItemPlacementRule
			for rule: ItemPlacementRule in level.placements:
				var reason: String = session.placement_reason(item.id, rule.id)
				if reason.is_empty():
					interaction.select_item(item.id)
					room.highlight(rule.id)
					hud.show_message(tr("HINT_PLACE") % [tr(item.name_key), tr(rule.name_key)])
					return
				if reason == "OPEN_CONTAINER_FIRST":
					closed_target = rule
			if closed_target != null:
				interaction.select_item(item.id)
				hud.show_message("HINT_OPEN")
				return
	if session.clean_ratio() < level.cleaning.completion_ratio:
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
	var next: GameSession = GameSession.new(level)
	next.found = session.found
	if saving_enabled and store.save(next) != OK:
		hud.show_message("SAVE_NEWER" if store.locked else "SAVE_FAILED", false)
		return
	sessions[level.id] = next
	_activate_level(level)

func _settings_changed(values: Dictionary) -> void:
	interaction.cancel()
	values["room"] = level.id
	settings = values
	TranslationServer.set_locale(settings["locale"])
	feedback.apply_settings(settings)
	room.animated = not settings["reduced"]
	room.refresh()
	rig.animated = not settings["reduced"]
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

	var last_room: Variant = config.get_value("player", "room", RoomCatalog.BEDROOM.id)
	if last_room is String and RoomCatalog.find(last_room) != null:
		settings["room"] = last_room

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
