extends SceneTree

const MAIN: PackedScene = preload("res://scenes/app/main.tscn")
var app: GameRoot
var checks: int = 0
var failures: int = 0
var graphical: bool = false
var output_dir: String = "res://build/previews"

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func frames(count: int = 3) -> void:
	for _index: int in range(count):
		await process_frame
	await physics_frame

func _run() -> void:
	graphical = DisplayServer.get_name() != "headless"
	if not graphical:
		push_error("Input integration requires a real display. Use domain_tests.gd for headless rules.")
		quit(2)
		return
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--preview-dir="):
			output_dir = argument.trim_prefix("--preview-dir=")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	app = MAIN.instantiate()
	app.save_directory = "res://build/integration-%d" % Time.get_ticks_usec()
	root.add_child(app)
	current_scene = app
	await frames(30)
	check(app.hud.title.text == "ORGANIZATION HERO", "main scene and HUD start")
	check(not app.session.completed and app.session.placements.is_empty(), "fresh isolated session starts")
	await capture("bedroom-before")
	await touch_tap(item_screen("book_mint"))
	check(app.interaction.selected_item == "book_mint" and app.hud.selected_id == "book_mint" and app.room.destination_guides["shelf"].visible and not app.room.destination_guides["basket"].visible, "touch selects an item and marks only available matching destinations")
	await capture("bedroom-selection")
	await touch_tap(target_screen("toy_box"))
	check(app.session.placements.is_empty() and app.interaction.selected_item == "book_mint" and app.hud.toast.text == app.tr("WRONG_CATEGORY"), "invalid destination tap explains rejection and preserves selection")
	await touch_tap(app.hud.buttons["OVERVIEW"].get_global_rect().get_center())
	check(app.interaction.selected_item.is_empty() and app.hud.buttons["OVERVIEW"].text == app.tr("OVERVIEW"), "contextual touch cancel clears selection without requiring a keyboard")
	await touch_tap(item_screen("book_mint"))
	await touch_tap(target_screen("shelf"))
	await frames(18)
	check(app.session.placements.get("book_mint") == "shelf" and app.interaction.selected_item.is_empty(), "two touch taps place an item and clear selection")
	await click_button("UNDO")
	await frames(18)
	await click_button("HINT")
	check(app.interaction.selected_item == "shirt_gold" and app.room.hovered_target_id == "basket", "hint selects its item and chooses available basket instead of closed wardrobe")
	key_press(KEY_ESCAPE)
	await frames()
	check(app.interaction.selected_item.is_empty() and app.hud.selected_id.is_empty() and not app.room.item_nodes["shirt_gold"].get_node("Selection").visible, "Escape clears both selection and world guidance")

	await drag("book_mint", "toy_box")
	check(app.session.placements.is_empty(), "mouse invalid drop preserves state")
	await drag("shirt_gold", "basket")
	check(app.session.placements.get("shirt_gold") == "basket", "mouse drag snaps to valid alternate target")
	await touch_tap(item_screen("shirt_coral"))
	await touch_tap(target_screen("basket"))
	await frames(18)
	check(app.session.placements.get("shirt_coral") == "basket", "occupied item does not steal second destination tap")
	await touch_tap(item_screen("sock_blue"))
	await touch_tap(target_screen("basket"))
	check(app.session.placements.size() == 2 and app.hud.toast.text == app.tr("TARGET_FULL") and not app.room.destination_guides["basket"].visible, "full basket rejects touch placement and offers no availability guide")
	await click_button("UNDO")
	await click_button("UNDO")
	await frames(18)
	check(not app.session.placements.has("shirt_gold"), "UI undo reverses placement")
	var cancellation_from: Vector2 = app.rig.camera.unproject_position(app.room.item_nodes["shirt_gold"].global_position)
	touch_event(0, cancellation_from, true)
	await frames()
	touch_motion(0, cancellation_from + Vector2(35, 0))
	await frames()
	var cancellation: InputEventScreenTouch = InputEventScreenTouch.new()
	cancellation.index = 0
	cancellation.position = cancellation_from + Vector2(35, 0)
	cancellation.canceled = true
	Input.parse_input_event(cancellation)
	await frames(18)
	check(app.interaction.mode == "idle" and app.session.placements.is_empty(), "canceled touch restores object instead of committing drop")
	check(app.interaction.selected_item.is_empty() and not app.room.destination_guides["basket"].visible, "canceled touch clears stale selection and destination guides")
	var anchor_from: Vector2 = item_screen("shirt_gold") + Vector2(5, 0)
	mouse_button(anchor_from, true)
	await frames()
	mouse_motion(anchor_from + Vector2(15, 0))
	await frames()
	var anchor_error: float = item_screen("shirt_gold").distance_to(anchor_from + Vector2(10, 0))
	check(anchor_error < 1.5, "drag keeps original grab offset without jumping to a higher plane (error %.2f px)" % anchor_error)
	var wheel_release: InputEventMouseButton = InputEventMouseButton.new()
	wheel_release.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel_release.position = anchor_from + Vector2(15, 0)
	Input.parse_input_event(wheel_release)
	await frames()
	check(app.interaction.mode == "drag" and app.session.placements.is_empty(), "unrelated mouse button release cannot commit or cancel active drag")
	key_press(KEY_ESCAPE)
	await frames(18)
	await touch_tap(app.hud.buttons["SETTINGS"].get_global_rect().get_center())
	check(app.hud.settings_overlay.visible, "touch opens settings through native GUI emulation")
	await click_button("CLOSE")
	check(not app.hud.settings_overlay.visible, "settings closes and restores world interaction")

	var cabinet_position: Vector2 = app.rig.camera.unproject_position(app.LEVEL.containers[0].position)
	await touch_tap(cabinet_position)
	check(app.session.opened["cabinet"], "touch tap opens container")
	check(app.room.door_tweens.has("cabinet") and app.room.door_tweens["cabinet"].is_running(), "container opening animates instead of teleporting the door")
	await frames(25)
	await click_button("SETTINGS")
	app.hud.reduced.button_pressed = true
	await frames()
	check(not app.room.animated and not app.rig.animated, "reduced animations setting applies to room and camera")
	await click_button("CLOSE")
	await touch_tap(cabinet_position)
	check(not app.session.opened["cabinet"] and is_zero_approx(app.room.door_nodes["cabinet"].rotation.y), "reduced animations makes container closing immediate")
	await touch_tap(cabinet_position)
	await click_button("SETTINGS")
	app.hud.reduced.button_pressed = false
	await frames()
	await click_button("CLOSE")
	await touch_drag("shirt_gold", "wardrobe")
	check(app.session.placements.get("shirt_gold") == "wardrobe", "touch drag organizes item")

	var old_size: float = app.rig.desired_size
	touch_event(0, Vector2(350, 470), true)
	await frames()
	touch_event(1, Vector2(600, 470), true)
	await frames()
	touch_motion(1, Vector2(700, 470))
	await frames()
	touch_event(1, Vector2(700, 470), false)
	touch_event(0, Vector2(350, 470), false)
	await frames()
	check(app.rig.desired_size < old_size and app.interaction.touches.is_empty(), "pinch zoom and all releases reset gesture")
	app.rig.overview()
	await frames(35)

	for item: ItemData in app.LEVEL.items:
		if app.session.placements.has(item.id):
			continue
		var target: String = ""
		for rule: ItemPlacementRule in app.LEVEL.placements:
			if item.category in rule.categories:
				target = rule.id
				break
		await drag(item.id, target)
		check(app.session.placements.get(item.id) == target, "input placement: " + item.id)
	check(app.session.hazard_safe() and app.room.collectible_node.visible, "cleared walkway reveals golden keepsake")
	await mouse_click(app.rig.camera.unproject_position(app.room.collectible_node.global_position))
	check(app.session.found, "click discovers collectible")
	await touch_tap(app.hud.buttons["CLOTH_TOOL"].get_global_rect().get_center())
	await frames(60)
	check(app.interaction.clean_tool, "touch UI activates cleaning mode without duplicate world input")
	for row: int in range(9):
		var y: float = 0.02 + float(row) * 0.12
		var first: Vector2 = surface_screen(Vector2(0.02, y))
		mouse_button(first, true)
		await frames(2)
		for step: int in range(13):
			mouse_motion(surface_screen(Vector2(0.02 + 0.96 * step / 12.0, y)))
			await frames(1)
		mouse_button(surface_screen(Vector2(0.98, y)), false)
		await frames(2)
		if row == 2:
			await capture("bedroom-cleaning")
	check(app.session.clean_ratio() >= app.LEVEL.cleaning.completion_ratio, "mouse strokes really clean required surface")
	check(app.session.can_finish(), "all mandatory objectives complete through input")
	var loaded: GameSession = SaveStore.new(app.save_directory).load_session(app.LEVEL)
	check(loaded.placements == app.session.placements and loaded.cleaned == app.session.cleaned and loaded.found, "input actions resume from actual saved JSON")
	await click_button("CLOTH_TOOL")
	await frames(45)
	await click_button("INSPECT")
	await frames(30)
	check(app.session.completed and app.hud.results_panel.visible and app.session.stars() == 3, "UI inspection opens genuine result with stars")
	await capture("bedroom-results")
	await click_button("COMPARE")
	await click_button("BEFORE")
	await frames(30)
	check(app.room.before_mode and app.session.completed, "before view reconstructs initial room without changing progress")
	await capture("bedroom-comparison-before")
	await click_button("AFTER")
	await frames(30)
	check(not app.room.before_mode and app.session.completed, "after view returns to completed state")
	await capture("bedroom-after")
	await click_button("BACK_RESULTS")
	check(app.hud.results_panel.visible, "comparison returns to result screen")
	var isolated_save_requested: bool = false
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--save-dir="):
			isolated_save_requested = true
	if isolated_save_requested:
		var old_directory: String = app.save_directory
		await click_button("PLAY_AGAIN")
		await frames(15)
		app = current_scene as GameRoot
		check(app != null and app.save_directory == old_directory and not app.session.completed and app.session.found and app.session.placements.is_empty(), "replay starts fresh while preserving permanent collectible")
	print("INPUT RESULT: %d checks, %d failures" % [checks, failures])
	print("PC RENDER: " + RenderingServer.get_video_adapter_name() + " / " + RenderingServer.get_current_rendering_method())
	print("PC DRAW CALLS: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	app.queue_free()
	await frames(3)
	quit(1 if failures > 0 else 0)

func surface_screen(uv: Vector2) -> Vector2:
	var task: CleaningTaskData = app.LEVEL.cleaning
	var world: Vector3 = task.position + Vector3((uv.x - 0.5) * task.size.x, 0, (uv.y - 0.5) * task.size.y)
	return app.rig.camera.unproject_position(world)

func item_screen(item_id: String) -> Vector2:
	return app.rig.camera.unproject_position(app.room.item_nodes[item_id].global_position)

func target_screen(target_id: String) -> Vector2:
	return app.rig.camera.unproject_position(app.room.target_nodes[target_id].global_position)

func key_press(key: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = key
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.keycode = key
	Input.parse_input_event(event)

func drag(item_id: String, target_id: String) -> void:
	var from: Vector2 = app.rig.camera.unproject_position(app.room.item_nodes[item_id].global_position)
	var to: Vector2 = app.rig.camera.unproject_position(app.room.target_nodes[target_id].global_position)
	mouse_button(from, true)
	await frames()
	mouse_motion(from.lerp(to, 0.25))
	await frames()
	mouse_motion(to)
	await frames()
	mouse_button(to, false)
	await frames(18)

func touch_drag(item_id: String, target_id: String) -> void:
	var from: Vector2 = app.rig.camera.unproject_position(app.room.item_nodes[item_id].global_position)
	var to: Vector2 = app.rig.camera.unproject_position(app.room.target_nodes[target_id].global_position)
	touch_event(0, from, true)
	await frames()
	touch_motion(0, from.lerp(to, 0.2))
	await frames()
	touch_motion(0, to)
	await frames()
	touch_event(0, to, false)
	await frames(18)

func click_button(key: String) -> void:
	await mouse_click(app.hud.buttons[key].get_global_rect().get_center())

func mouse_click(point: Vector2) -> void:
	mouse_button(point, true)
	await frames()
	mouse_button(point, false)
	await frames()

func touch_tap(point: Vector2) -> void:
	touch_event(0, point, true)
	await frames()
	touch_event(0, point, false)
	await frames()

func mouse_button(point: Vector2, pressed: bool) -> void:
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	Input.parse_input_event(event)

func mouse_motion(point: Vector2) -> void:
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(event)

func touch_event(index: int, point: Vector2, pressed: bool) -> void:
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)

func touch_motion(index: int, point: Vector2) -> void:
	var event: InputEventScreenDrag = InputEventScreenDrag.new()
	event.index = index
	event.position = point
	Input.parse_input_event(event)

func capture(name: String) -> void:
	if not graphical:
		return
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(output_dir.path_join(name + ".png"))
	check(error == OK, "render capture: " + name)
