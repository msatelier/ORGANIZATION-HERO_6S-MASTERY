extends SceneTree

const MAIN: PackedScene = preload("res://scenes/app/main.tscn")
var app: GameRoot
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

func settle() -> void:
	for _frame: int in range(6):
		await process_frame

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		quit(2)
		return
	app = MAIN.instantiate()
	app.saving_enabled = false
	root.add_child(app)
	await settle()
	app.rig.animated = false
	for size: Vector2i in [Vector2i(432, 960), Vector2i(450, 800), Vector2i(960, 432), Vector2i(800, 600)]:
		root.size = size
		await settle()
		for language: String in ["es", "en"]:
			TranslationServer.set_locale(language)
			app.hud.refresh_text()
			app.hud._safe_area()
			await settle()
			var viewport: Rect2 = root.get_visible_rect()
			var panels: bool = true
			for panel: Control in [app.hud.top_panel, app.hud.goals_panel, app.hud.toolbar, app.hud.results_panel, app.hud.settings_panel, app.hud.rooms_panel, app.hud.comparison_panel]:
				panels = panels and viewport.encloses(panel.get_global_rect())
				if not viewport.encloses(panel.get_global_rect()):
					print("OUTSIDE PANEL: %s / %s / minimum %s" % [panel.name, panel.get_global_rect(), panel.get_combined_minimum_size()])
			check(panels, "panels remain within %s / %s" % [size, language])
			var controls: bool = true
			for key: String in ["CLOTH_TOOL", "UNDO", "OVERVIEW", "INSPECT"]:
				var button: Button = app.hud.buttons[key]
				controls = controls and app.hud.toolbar.get_global_rect().encloses(button.get_global_rect()) and button.size.y >= 48
			check(controls, "toolbar controls fit and keep touch height: %s / %s" % [size, language])
			check(not app.hud.toolbar.get_global_rect().intersects(app.hud.goals_panel.get_global_rect()), "objectives and actions do not overlap: %s / %s" % [size, language])
			var framing: bool = true
			for point: Vector3 in app.rig.frame_points:
				framing = framing and app.hud.play_area.grow(2).has_point(app.rig.camera.unproject_position(point))
			check(framing, "room fits around the interface: %s / %s" % [size, language])
			var room_controls: bool = app.hud.top_panel.get_global_rect().encloses(app.hud.subtitle.get_global_rect()) and app.hud.subtitle.size.y >= 48
			for button: Button in app.hud.room_buttons.values():
				room_controls = room_controls and app.hud.rooms_panel.get_global_rect().encloses(button.get_global_rect()) and button.size.y >= 48
			for key: String in ["COMPARE", "PLAY_AGAIN", "ROOMS_RESULTS"]:
				room_controls = room_controls and app.hud.results_panel.get_global_rect().encloses(app.hud.buttons[key].get_global_rect())
			check(room_controls, "room navigation controls fit: %s / %s" % [size, language])
		# Simulate a cutout and the bottom gesture region in logical coordinates.
		var logical: Vector2 = root.get_visible_rect().size
		var safe: Rect2 = Rect2(Vector2(24, 24), logical - Vector2(48, 48))
		app.hud.safe_area_override = safe
		app.hud._safe_area()
		await settle()
		var safe_panels: bool = true
		for panel: Control in [app.hud.top_panel, app.hud.goals_panel, app.hud.toolbar, app.hud.results_panel, app.hud.settings_panel, app.hud.rooms_panel, app.hud.comparison_panel]:
			safe_panels = safe_panels and safe.encloses(panel.get_global_rect())
		check(safe_panels, "safe insets respected on all edges: " + str(size))
		app.hud.safe_area_override = Rect2()
		app.hud._safe_area()
	print("LAYOUT RESULT: %d checks, %d failures" % [checks, failures])
	app.queue_free()
	await settle()
	quit(1 if failures > 0 else 0)
