class_name GameHUD
extends CanvasLayer

signal request_clean
signal request_undo
signal request_overview
signal request_finish
signal request_hint
signal request_restart
signal request_comparison(before: bool)
signal settings_changed(values: Dictionary)
signal settings_opened

var session: GameSession
var root_control: Control
var top_panel: PanelContainer
var goals_panel: PanelContainer
var toolbar: PanelContainer
var results_panel: PanelContainer
var comparison_panel: PanelContainer
var settings_overlay: ColorRect
var title: Label
var subtitle: Label
var instruction: Label
var toast: Label
var progress: ProgressBar
var goal_labels: Dictionary[String, Label] = {}
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
	get_viewport().size_changed.connect(_safe_area)
	_safe_area()
	refresh_text()

func _theme() -> Theme:
	var theme: Theme = Theme.new()
	theme.default_font_size = 18
	var panel: StyleBoxFlat = _style(Color("#163c3e"), 18)
	panel.content_margin_left = 20
	panel.content_margin_right = 20
	panel.content_margin_top = 16
	panel.content_margin_bottom = 16
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
		style.content_margin_left = 16
		style.content_margin_right = 16
		style.content_margin_top = 11
		style.content_margin_bottom = 11
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
	button.custom_minimum_size.y = 44
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
	row.add_theme_constant_override("separation", 16)
	top_panel.add_child(row)
	var names: VBoxContainer = VBoxContainer.new()
	names.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(names)
	title = _label(names, 25)
	subtitle = _label(names, 14)
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
	column.add_theme_constant_override("separation", 14)
	goals_panel.add_child(column)
	var heading: Label = _label(column, 15)
	heading.name = "Heading"
	progress = ProgressBar.new()
	progress.custom_minimum_size.y = 7
	progress.show_percentage = false
	column.add_child(progress)
	if session != null:
		_create_goal_labels(column)

func _create_goal_labels(column: VBoxContainer) -> void:
	for goal: ObjectiveData in session.level.objectives:
		var label: Label = _label(column, 17)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size.x = 230
		goal_labels[goal.id] = label

func _build_toolbar() -> void:
	toolbar = _panel()
	toolbar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	toolbar.offset_left = 22
	toolbar.offset_right = -22
	toolbar.offset_top = -126
	toolbar.offset_bottom = -18
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 10)
	toolbar.add_child(column)
	instruction = _label(column, 17)
	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	column.add_child(row)
	for entry: Array in [
		["CLOTH_TOOL", func() -> void: request_clean.emit()],
		["UNDO", func() -> void: request_undo.emit()],
		["OVERVIEW", func() -> void: request_overview.emit()],
		["INSPECT", func() -> void: request_finish.emit()]
	]:
		var button: Button = _button(row, entry[0], entry[1])
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toast = _label(root_control, 17)
	toast.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	toast.offset_left = 32
	toast.offset_right = 950
	toast.offset_top = -171
	toast.offset_bottom = -138
	toast.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _build_results() -> void:
	results_panel = _panel()
	results_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	results_panel.offset_left = -305
	results_panel.offset_right = 305
	results_panel.offset_top = -215
	results_panel.offset_bottom = 215
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 15)
	results_panel.add_child(column)
	result_title = _label(column, 29)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stars = _label(column, 44)
	result_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_stars.modulate = Color("#f0ca76")
	result_details = _label(column, 20)
	result_details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_collection = _label(column, 17)
	result_collection.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_button(column, "COMPARE", _open_comparison)
	_button(column, "PLAY_AGAIN", func() -> void: request_restart.emit())
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
	var panel: PanelContainer = PanelContainer.new()
	settings_overlay.add_child(panel)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_right = 250
	panel.offset_top = -260
	panel.offset_bottom = 260
	var column: VBoxContainer = VBoxContainer.new()
	column.add_theme_constant_override("separation", 15)
	panel.add_child(column)
	settings_title = _label(column, 25)
	music_label = _label(column, 17)
	music_slider = HSlider.new()
	music_slider.max_value = 100
	music_slider.custom_minimum_size.y = 32
	column.add_child(music_slider)
	music_slider.value_changed.connect(_setting_value)
	effects_label = _label(column, 17)
	effects_slider = HSlider.new()
	effects_slider.max_value = 100
	effects_slider.custom_minimum_size.y = 32
	column.add_child(effects_slider)
	effects_slider.value_changed.connect(_setting_value)
	reduced = CheckButton.new()
	column.add_child(reduced)
	reduced.toggled.connect(_setting_value)
	haptics = CheckButton.new()
	column.add_child(haptics)
	haptics.toggled.connect(_setting_value)
	locale_choice = OptionButton.new()
	locale_choice.add_item("Español")
	locale_choice.add_item("English")
	column.add_child(locale_choice)
	locale_choice.item_selected.connect(_setting_value)
	_button(column, "CLOSE", close_settings)
	settings_overlay.visible = false

func _setting_value(_value: Variant) -> void:
	if applying_settings:
		return
	settings_changed.emit({
		"music": music_slider.value / 100.0, "effects": effects_slider.value / 100.0,
		"reduced": reduced.button_pressed, "haptics": haptics.button_pressed,
		"locale": "es" if locale_choice.selected == 0 else "en"
	})

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
	session = state
	var column: VBoxContainer = goals_panel.get_child(0)
	if goal_labels.is_empty():
		_create_goal_labels(column)
	session.changed.connect(refresh)
	refresh_text()

func refresh_text() -> void:
	if title == null:
		return
	title.text = "ORGANIZATION HERO"
	subtitle.text = tr("CHAPTER")
	for key: String in buttons:
		buttons[key].text = tr(key)
	settings_title.text = tr("SETTINGS")
	music_label.text = tr("MUSIC")
	effects_label.text = tr("SOUND")
	reduced.text = tr("REDUCED_EFFECTS")
	haptics.text = tr("HAPTICS")
	var heading: Label = goals_panel.get_child(0).get_node("Heading")
	heading.text = tr("YOUR_GOALS")
	refresh()

func refresh() -> void:
	if session == null:
		return
	var completed_goals: int = 0
	var required_goals: int = 0
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
		goal_labels[goal.id].text = ("✓  " if done else "○  ") + tr(goal.name_key) + "\n    " + detail
		goal_labels[goal.id].modulate = Color("#b0d8b9") if done else Color("#f3e7cb")
	progress.value = float(completed_goals) / maxi(1, required_goals) * 100
	buttons["UNDO"].disabled = session.undo_stack.is_empty() or session.completed
	buttons["INSPECT"].disabled = not session.can_finish() or session.completed
	buttons["CLOTH_TOOL"].text = tr("PUT_CLOTH_AWAY") if using_cloth else tr("CLOTH_TOOL")
	if using_cloth:
		instruction.text = tr("CLEAN_HINT") % roundi(session.level.cleaning.completion_ratio * 100)
	elif not selected_id.is_empty():
		instruction.text = tr(session.level.item(selected_id).name_key) + "  ·  " + tr("DRAG_HINT")
	else:
		instruction.text = tr("CONTROLS_HINT")
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
	if settings_overlay.visible:
		return true
	for panel: PanelContainer in [top_panel, goals_panel, toolbar, results_panel, comparison_panel]:
		if panel.visible and panel.get_global_rect().has_point(point):
			return true
	return false

func _safe_area() -> void:
	if OS.get_name() not in ["Android", "iOS"]:
		return
	var safe: Rect2i = DisplayServer.get_display_safe_area()
	var window: Vector2i = DisplayServer.window_get_size()
	if window.x < 1 or window.y < 1:
		return
	var scale: Vector2 = get_viewport().get_visible_rect().size / Vector2(window)
	var left: float = safe.position.x * scale.x + 22
	var right: float = -(window.x - safe.end.x) * scale.x - 22
	top_panel.offset_left = left
	top_panel.offset_right = right
	toolbar.offset_left = left
	toolbar.offset_right = right
	goals_panel.offset_right = right
	goals_panel.offset_left = right - 278
