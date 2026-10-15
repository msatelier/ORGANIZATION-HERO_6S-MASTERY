class_name GameHUD
extends CanvasLayer

signal request_clean
signal request_undo
signal request_overview
signal request_cancel
signal request_finish
signal request_hint
signal request_restart
signal request_comparison(before: bool)
signal settings_changed(values: Dictionary)
signal settings_opened
signal layout_changed(play_area: Rect2)
signal request_level(id: String)
signal rooms_opened

var session: GameSession
var root_control: Control
var top_panel: PanelContainer
var goals_panel: PanelContainer
var toolbar: PanelContainer
var results_panel: PanelContainer
var comparison_panel: PanelContainer
var settings_overlay: ColorRect
var title: Label
var subtitle: Button
var rooms_overlay: ColorRect
var rooms_panel: PanelContainer
var rooms_title: Label
var rooms_description: Label
var room_buttons: Dictionary[String, Button] = {}
var room_progress: Dictionary = {}
var instruction: Label
var toast: Label
var progress: ProgressBar
var goal_labels: Dictionary[String, Label] = {}
var goal_grid: GridContainer
var settings_panel: PanelContainer
var play_area: Rect2
var safe_area_override: Rect2 = Rect2()
var buttons: Dictionary[String, Button] = {}
var result_title: Label
var result_stars: Label
var result_details: Label
var result_collection: Label
var settings_title: Label
var music_label: Label
var effects_label: Label
var music_slider: HSlider
var effects_slider: HSlider
var reduced: CheckButton
var haptics: CheckButton
var locale_choice: OptionButton
var selected_id: String = ""
var destination_id: String = ""
var destination_reason: String = ""
var using_cloth: bool = false
var comparison_active: bool = false
var message_timer: float = 0.0
var applying_settings: bool = false

func _ready() -> void:
	root_control = Control.new()
	root_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.theme = _theme()
	add_child(root_control)
	_build_top()
	_build_goals()
	_build_toolbar()
	_build_results()
	_build_settings()
	_build_rooms()
	get_viewport().size_changed.connect(_safe_area)
	_safe_area()
	refresh_text()

func _theme() -> Theme:
	var theme: Theme = Theme.new()
	theme.default_font_size = 18
	var panel: StyleBoxFlat = _style(Color("#163c3e"), 18)
	panel.content_margin_left = 14
	panel.content_margin_right = 14
	panel.content_margin_top = 10
	panel.content_margin_bottom = 10
	theme.set_stylebox("panel", "PanelContainer", panel)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var color: Color = Color("#e7d9b9")
		if state == "hover":
			color = Color("#fff0cc")
		elif state == "pressed":
			color = Color("#b9d2bc")
		elif state == "disabled":
			color = Color("#6c8278")
		var style: StyleBoxFlat = _style(color, 12)
		style.content_margin_left = 12
		style.content_margin_right = 12
		style.content_margin_top = 9
		style.content_margin_bottom = 9
		theme.set_stylebox(state, "Button", style)
	theme.set_color("font_color", "Button", Color("#173c3d"))
	theme.set_color("font_hover_color", "Button", Color("#173c3d"))
	theme.set_color("font_pressed_color", "Button", Color("#173c3d"))
	theme.set_color("font_disabled_color", "Button", Color("#bbc6b7"))
	theme.set_color("font_color", "Label", Color("#f3e7cb"))
	theme.set_stylebox("background", "ProgressBar", _style(Color("#335654"), 5))
	theme.set_stylebox("fill", "ProgressBar", _style(Color("#e5b96d"), 5))
	return theme

func _style(color: Color, radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	return style

func _panel() -> PanelContainer:
	var panel: PanelContainer = PanelContainer.new()
	root_control.add_child(panel)
	return panel

func _label(parent: Node, size: int = 18) -> Label:
	var label: Label = Label.new()
	label.add_theme_font_size_override("font_size", size)
	parent.add_child(label)
	return label

func _button(parent: Node, key: String, callback: Callable) -> Button:
	var button: Button = Button.new()
	button.text = tr(key)
	button.custom_minimum_size.y = 48
	button.pressed.connect(callback)
	parent.add_child(button)
	buttons[key] = button
	return button

func _build_top() -> void:
	top_panel = _panel()
	top_panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top_panel.offset_left = 22
	top_panel.offset_right = -22
	top_panel.offset_top = 18
	top_panel.offset_bottom = 96
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	top_panel.add_child(row)
	var names: VBoxContainer = VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(names)
	title = _label(names, 20)
	subtitle = _button(names, "ROOMS", _open_rooms)
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.alignment = HORIZONTAL_ALIGNMENT_LEFT
	_button(row, "HINT", func() -> void: request_hint.emit())
	_button(row, "SETTINGS", func() -> void:
		settings_overlay.visible = true
		settings_opened.emit()
	)

func _build_goals() -> void:
	goals_panel = _panel()
	goals_panel.anchor_left = 1
	goals_panel.anchor_right = 1
	goals_panel.offset_left = -300
	goals_panel.offset_right = -22
	goals_panel.offset_top = 115
	goals_panel.offset_bottom = 423
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	goals_panel.add_child(column)
	var heading: Label = _label(column, 14)
	heading.name = "Heading"
	progress = ProgressBar.new()
	progress.custom_minimum_size.y = 7
	progress.show_percentage = false
	column.add_child(progress)
	goal_grid = GridContainer.new()
	goal_grid.add_theme_constant_override("h_separation", 8)
	goal_grid.add_theme_constant_override("v_separation", 4)
	column.add_child(goal_grid)
	if session != null:
		_create_goal_labels()

func _create_goal_labels() -> void:
	for goal: ObjectiveData in session.level.objectives:
		var label: Label = _label(goal_grid, 14)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		goal_labels[goal.id] = label

func _build_toolbar() -> void:
	toolbar = _panel()
	toolbar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar.offset_left = 22
	toolbar.offset_right = -22
	toolbar.offset_top = -126
	toolbar.offset_bottom = -18
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 6)
	toolbar.add_child(column)
	instruction = _label(column, 14)
	instruction.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instruction.custom_minimum_size.y = 34
	var row: GridContainer = GridContainer.new()
	row.columns = 2
	row.add_theme_constant_override("h_separation", 8)
	row.add_theme_constant_override("v_separation", 8)
	column.add_child(row)
	for entry: Array in [
		["CLOTH_TOOL", func() -> void: request_clean.emit()],
		["UNDO", func() -> void: request_undo.emit()],
		["OVERVIEW", _overview_or_cancel],
		["INSPECT", func() -> void: request_finish.emit()]
	]:
		var button: Button = _button(row, entry[0], entry[1])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y = 56
		button.add_theme_font_size_override("font_size", 17)
	toast = _label(root_control, 14)
	toast.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast.max_lines_visible = 2
	toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	toast.offset_left = 32
	toast.offset_right = 950
	toast.offset_top = -171
	toast.offset_bottom = -138
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _overview_or_cancel() -> void:
	if selected_id.is_empty():
		request_overview.emit()
	else:
		request_cancel.emit()

func _build_results() -> void:
	results_panel = _panel()
	results_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	results_panel.offset_left = -305
	results_panel.offset_right = 305
	results_panel.offset_top = -215
	results_panel.offset_bottom = 215
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	results_panel.add_child(column)
	result_title = _label(column, 25)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stars = _label(column, 44)
	result_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stars.modulate = Color("#f0ca76")
	result_details = _label(column, 20)
	result_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_collection = _label(column, 17)
	result_collection.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_collection.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_button(column, "COMPARE", _open_comparison)
	var actions: HBoxContainer = HBoxContainer.new()
	actions.add_theme_constant_override("separation", 10)
	column.add_child(actions)
	_button(actions, "PLAY_AGAIN", func() -> void: request_restart.emit()).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(actions, "ROOMS_RESULTS", _open_rooms).size_flags_horizontal = Control.SIZE_EXPAND_FILL
	results_panel.visible = false
	comparison_panel = _panel()
	comparison_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	comparison_panel.offset_left = 22
	comparison_panel.offset_right = -22
	comparison_panel.offset_top = -94
	comparison_panel.offset_bottom = -18
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	comparison_panel.add_child(row)
	_button(row, "BEFORE", func() -> void: request_comparison.emit(true))
	_button(row, "AFTER", func() -> void: request_comparison.emit(false))
	_button(row, "BACK_RESULTS", func() -> void:
		comparison_active = false
		request_comparison.emit(false)
		refresh()
	)
	comparison_panel.visible = false

func _open_comparison() -> void:
	comparison_active = true
	request_comparison.emit(false)
	refresh()

func _build_settings() -> void:
	settings_overlay = ColorRect.new()
	settings_overlay.color = Color(0.05, 0.12, 0.13, 0.78)
	settings_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(settings_overlay)
	settings_panel = PanelContainer.new()
	settings_overlay.add_child(settings_panel)
	var outer: VBoxContainer = VBoxContainer.new()
	outer.add_theme_constant_override("separation", 12)
	settings_panel.add_child(outer)
	var header: HBoxContainer = HBoxContainer.new()
	outer.add_child(header)
	settings_title = _label(header, 24)
	settings_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_button(header, "CLOSE", close_settings)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)
	var column: VBoxContainer = VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 10)
	scroll.add_child(column)
	music_label = _label(column, 17)
	music_slider = HSlider.new()
	music_slider.max_value = 100
	music_slider.custom_minimum_size.y = 48
	column.add_child(music_slider)
	music_slider.value_changed.connect(_setting_value)
	effects_label = _label(column, 17)
	effects_slider = HSlider.new()
	effects_slider.max_value = 100
	effects_slider.custom_minimum_size.y = 48
	column.add_child(effects_slider)
	effects_slider.value_changed.connect(_setting_value)
	reduced = CheckButton.new()
	reduced.custom_minimum_size.y = 48
	column.add_child(reduced)
	reduced.toggled.connect(_setting_value)
	haptics = CheckButton.new()
	haptics.custom_minimum_size.y = 48
	column.add_child(haptics)
	haptics.toggled.connect(_setting_value)
	locale_choice = OptionButton.new()
	locale_choice.custom_minimum_size.y = 48
	locale_choice.add_item("Español")
	locale_choice.add_item("English")
	column.add_child(locale_choice)
	locale_choice.item_selected.connect(_setting_value)
	settings_overlay.visible = false

func _setting_value(_value: Variant) -> void:
	if applying_settings:
		return
	settings_changed.emit({
		"music": music_slider.value / 100.0, "effects": effects_slider.value / 100.0,
		"reduced": reduced.button_pressed, "haptics": haptics.button_pressed,
		"locale": "es" if locale_choice.selected == 0 else "en"
	})

func _build_rooms() -> void:
	rooms_overlay = ColorRect.new()
	rooms_overlay.color = Color(0.05, 0.12, 0.13, 0.85)
	rooms_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_control.add_child(rooms_overlay)
	rooms_panel = PanelContainer.new()
	rooms_overlay.add_child(rooms_panel)
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	rooms_panel.add_child(column)
	rooms_title = _label(column, 26)
	rooms_description = _label(column, 16)
	for level: LevelData in RoomCatalog.levels():
		var button: Button = Button.new()
		button.custom_minimum_size.y = 88
		button.add_theme_font_size_override("font_size", 18)
		button.pressed.connect(func() -> void: request_level.emit(level.id))
		column.add_child(button)
		room_buttons[level.id] = button
	_button(column, "ROOMS_CLOSE", func() -> void: rooms_overlay.visible = false)
	rooms_overlay.visible = false

func _open_rooms() -> void:
	rooms_overlay.visible = true
	rooms_opened.emit()
	_safe_area()

func set_room_progress(values: Dictionary) -> void:
	room_progress = values
	_refresh_rooms()

func _refresh_rooms() -> void:
	if rooms_title == null:
		return
	rooms_title.text = tr("ROOMS")
	rooms_description.text = tr("ROOMS_DESCRIPTION")
	for level: LevelData in RoomCatalog.levels():
		var detail: String = tr("ROOM_NEW")
		var state: Dictionary = room_progress.get(level.id, {})
		if state.get("completed", false):
			detail = "★".repeat(int(state.get("stars", 2))) + " · " + tr("ROOM_DONE")
		elif state.get("started", false):
			detail = tr("ROOM_IN_PROGRESS")
		var current: bool = session != null and session.level.id == level.id
		room_buttons[level.id].text = tr(level.name_key) + (" · " + tr("ROOM_CURRENT") if current else "") + "\n" + detail

func apply_settings(values: Dictionary) -> void:
	applying_settings = true
	music_slider.value = float(values.get("music", 0.35)) * 100.0
	effects_slider.value = float(values.get("effects", 0.65)) * 100.0
	reduced.button_pressed = values.get("reduced", false)
	haptics.button_pressed = values.get("haptics", true)
	locale_choice.selected = 0 if values.get("locale", "es") == "es" else 1
	applying_settings = false
	refresh_text()

func bind(state: GameSession) -> void:
	if session != null and session.changed.is_connected(refresh):
		session.changed.disconnect(refresh)
	for label: Label in goal_labels.values():
		label.free()
	goal_labels.clear()
	session = state
	_create_goal_labels()
	selected_id = ""
	destination_id = ""
	destination_reason = ""
	using_cloth = false
	comparison_active = false
	settings_overlay.visible = false
	rooms_overlay.visible = false
	session.changed.connect(refresh)
	refresh_text()
	_safe_area()

func refresh_text() -> void:
	if title == null:
		return
	title.text = "ORGANIZATION HERO"
	for key: String in buttons:
		buttons[key].text = tr(key)
	subtitle.text = tr(session.level.chapter_key if session != null else "CHAPTER_MOBILE") + " ▾"
	_refresh_rooms()
	_safe_area.call_deferred()
	settings_title.text = tr("SETTINGS")
	music_label.text = tr("MUSIC")
	effects_label.text = tr("SOUND")
	reduced.text = tr("REDUCED_EFFECTS")
	haptics.text = tr("HAPTICS")
	var heading: Label = goals_panel.get_child(0).get_node("Heading")
	heading.text = tr("GOALS_MOBILE")
	refresh()

func refresh() -> void:
	if session == null:
		return
	var completed_goals: int = 0
	var required_goals: int = 0
	var portrait: bool = get_viewport().get_visible_rect().size.x < get_viewport().get_visible_rect().size.y
	for goal: ObjectiveData in session.level.objectives:
		var done: bool = session.objective_done(goal)
		if goal.required:
			required_goals += 1
			if done:
				completed_goals += 1
		var detail: String = goal.dimension
		if goal.kind == "items":
			detail += "  ·  %d / %d" % [session.placements.size(), session.level.items.size()]
		elif goal.kind == "clean":
			detail += "  ·  %d%% / %d%%" % [roundi(session.clean_ratio() * 100), roundi(session.level.cleaning.completion_ratio * 100)]
		elif not goal.required:
			detail = tr("OPTIONAL")
		if not portrait:
			if goal.kind == "items":
				detail = "S1·S2 %d/%d" % [session.placements.size(), session.level.items.size()]
			elif goal.kind == "clean":
				detail = "S3 %d/%d%%" % [roundi(session.clean_ratio() * 100), roundi(session.level.cleaning.completion_ratio * 100)]
			elif not goal.required:
				detail = tr("OPTIONAL_SHORT")
		goal_labels[goal.id].text = ("✓  " if done else "○  ") + tr(goal.name_key if portrait else goal.name_key + "_SHORT") + "\n" + detail
		goal_labels[goal.id].modulate = Color("#b0d8b9") if done else Color("#f3e7cb")
	progress.value = float(completed_goals) / maxi(1, required_goals) * 100
	buttons["UNDO"].disabled = session.undo_stack.is_empty() or session.completed
	buttons["INSPECT"].disabled = not session.can_finish() or session.completed
	buttons["CLOTH_TOOL"].text = tr("PUT_CLOTH_SHORT") if using_cloth else tr("CLOTH_SHORT")
	buttons["UNDO"].text = tr("UNDO_SHORT")
	buttons["INSPECT"].text = tr("INSPECT_SHORT")
	buttons["OVERVIEW"].text = tr("CANCEL_SHORT") if not selected_id.is_empty() else tr("VIEW_SHORT")
	if using_cloth:
		instruction.text = tr("CLEAN_MOBILE") % roundi(session.level.cleaning.completion_ratio * 100)
	elif not selected_id.is_empty():
		if destination_id.is_empty():
			instruction.text = tr(session.level.item(selected_id).name_key) + "\n" + tr("SELECT_MOBILE")
		else:
			instruction.text = tr(session.level.placement(destination_id).name_key) + "\n"
			instruction.text += tr("READY_SHORT" if destination_reason.is_empty() else destination_reason + "_SHORT")
	else:
		instruction.text = tr("CONTROLS_MOBILE")
	toolbar.visible = not session.completed
	results_panel.visible = session.completed and not comparison_active
	comparison_panel.visible = session.completed and comparison_active
	if session.completed:
		toast.text = ""
		result_title.text = tr("ROOM_COMPLETE")
		result_stars.text = "★".repeat(session.stars()) + "☆".repeat(3 - session.stars())
		result_details.text = tr("RESULT_DETAIL") % [session.score(), session.move_count]
		result_collection.text = tr("COLLECTIBLE_FOUND") if session.found else tr("COLLECTIBLE_MISSED")

func show_message(key: String, positive: bool = true) -> void:
	toast.text = tr(key)
	if key == "CLEAN_HINT" and session != null:
		toast.text = toast.text % roundi(session.level.cleaning.completion_ratio * 100)
	toast.modulate = Color("#d6edca") if positive else Color("#ffcdac")
	message_timer = 4.5

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			toast.text = ""

func close_settings() -> void:
	settings_overlay.visible = false

func blocks(point: Vector2) -> bool:
	if settings_overlay.visible or rooms_overlay.visible:
		return true
	for panel: PanelContainer in [top_panel, goals_panel, toolbar, results_panel, comparison_panel]:
		if panel.visible and panel.get_global_rect().has_point(point):
			return true
	return false

func _safe_area() -> void:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x < 1 or viewport_size.y < 1:
		return
	var safe: Rect2 = Rect2(Vector2.ZERO, viewport_size)
	if safe_area_override.has_area():
		safe = safe_area_override
	elif OS.get_name() in ["Android", "iOS"]:
		var physical: Rect2i = DisplayServer.get_display_safe_area()
		var window: Vector2i = DisplayServer.window_get_size()
		if physical.has_area() and window.x > 0 and window.y > 0:
			var scale: Vector2 = viewport_size / Vector2(window)
			safe = Rect2(Vector2(physical.position) * scale, Vector2(physical.size) * scale)
	var layout: Dictionary[String, Rect2] = MobileLayout.calculate(viewport_size, safe)
	goal_grid.columns = 2
	for label: Label in goal_labels.values():
		label.add_theme_font_size_override("font_size", 14 if viewport_size.x < viewport_size.y else 13)
		label.custom_minimum_size.x = (layout["goals"].size.x - 28 - 8 * (goal_grid.columns - 1)) / goal_grid.columns
	for pair: Array in [[top_panel, "top"], [goals_panel, "goals"], [toolbar, "toolbar"], [toast, "toast"], [results_panel, "results"], [comparison_panel, "comparison"], [settings_panel, "settings"], [rooms_panel, "rooms"]]:
		_place(pair[0], layout[pair[1]])
	play_area = layout["play"]
	refresh()
	layout_changed.emit(play_area)

func _place(control: Control, area: Rect2) -> void:
	control.set_anchors_preset(Control.PRESET_TOP_LEFT)
	control.position = area.position
	control.size = area.size
