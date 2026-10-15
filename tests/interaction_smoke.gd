extends SceneTree

const MAIN: PackedScene = preload("res://scenes/app/main.tscn")
var app: GameRoot
var checks: int = 0
var failures: int = 0
var graphical: bool = false
var kitchen_test: bool = false
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
		if argument == "--test-room=kitchen":
			kitchen_test = true
		elif argument.begins_with("--preview-dir="):
			output_dir = argument.trim_prefix("--preview-dir=")
		elif argument.begins_with("--test-size="):
			var dimensions: PackedStringArray = argument.trim_prefix("--test-size=").split("x")
			root.size = Vector2i(dimensions[0].to_int(), dimensions[1].to_int())
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	print("TEST VIEW: %s / screen transform %s" % [root.get_visible_rect().size, root.get_final_transform()])
	app = MAIN.instantiate()
	app.save_directory = "res://build/integration-%d" % Time.get_ticks_usec()
	root.add_child(app)
	current_scene = app
	await frames(30)
	await create_timer(0.6).timeout
	if kitchen_test:
		await _run_kitchen()
		await _finish()
		return
	check(app.hud.title.text == "ORGANIZATION HERO", "main scene and HUD start")
	check(not app.session.completed and app.session.placements.is_empty(), "fresh isolated session starts")
	var fitted: bool = true
	for point: Vector3 in app.rig.frame_points:
		fitted = fitted and app.hud.play_area.grow(3).has_point(app.rig.camera.unproject_position(point))
	check(fitted, "overview framing keeps the room inside the mobile play area")
	await capture("bedroom-before")
	await touch_tap(item_screen("book_mint"))
	check(app.interaction.selected_item == "book_mint" and app.hud.selected_id == "book_mint" and app.room.destination_guides["shelf"].visible and not app.room.destination_guides["basket"].visible, "touch selects an item and marks only available matching destinations")
	await capture("bedroom-selection")
	await touch_tap(target_screen("toy_box"))
	check(app.session.placements.is_empty() and app.interaction.selected_item == "book_mint" and app.hud.toast.text == app.tr("WRONG_CATEGORY"), "invalid destination tap explains rejection and preserves selection")
	await touch_tap(app.hud.buttons["OVERVIEW"].get_global_rect().get_center())
	check(app.interaction.selected_item.is_empty() and app.hud.buttons["OVERVIEW"].text == app.tr("VIEW_SHORT"), "contextual touch cancel clears selection without requiring a keyboard")
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
	check(app.feedback.last_clip_key.begins_with("place_fabric_"), "clothing placement routes to fabric sound")
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
	cancellation.position = input_point(cancellation_from + Vector2(35, 0))
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
	wheel_release.position = input_point(anchor_from + Vector2(15, 0))
	Input.parse_input_event(wheel_release)
	await frames()
	check(app.interaction.mode == "drag" and app.session.placements.is_empty(), "unrelated mouse button release cannot commit or cancel active drag")
	key_press(KEY_ESCAPE)
	await frames(18)
	await touch_tap(app.hud.buttons["SETTINGS"].get_global_rect().get_center())
	check(app.hud.settings_overlay.visible, "touch opens settings through native GUI emulation")
	await click_button("CLOSE")
	check(not app.hud.settings_overlay.visible, "settings closes and restores world interaction")

	var cabinet_position: Vector2 = app.rig.camera.unproject_position(app.level.containers[0].position)
	await touch_tap(cabinet_position)
	check(app.session.opened["cabinet"], "touch tap opens container")
	check(app.feedback.last_clip_key == "container_open", "opening container routes to opening sound")
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
	var pinch_left: Vector2 = app.hud.play_area.position + app.hud.play_area.size * Vector2(0.25, 0.8)
	var pinch_right: Vector2 = app.hud.play_area.position + app.hud.play_area.size * Vector2(0.6, 0.8)
	var pinch_expanded: Vector2 = app.hud.play_area.position + app.hud.play_area.size * Vector2(0.8, 0.8)
	touch_event(0, pinch_left, true)
	await frames()
	touch_event(1, pinch_right, true)
	await frames()
	touch_motion(1, pinch_expanded)
	await frames()
	touch_event(1, pinch_expanded, false)
	touch_event(0, pinch_left, false)
	await frames()
	check(app.rig.desired_size < old_size and app.interaction.touches.is_empty(), "pinch zoom and all releases reset gesture")
	app.rig.overview()
	await frames(35)

	for item: ItemData in app.level.items:
		if app.session.placements.has(item.id):
			continue
		var target: String = ""
		for rule: ItemPlacementRule in app.level.placements:
			if item.category in rule.categories:
				target = rule.id
				break
		await drag(item.id, target)
		check(app.session.placements.get(item.id) == target, "input placement: " + item.id)
		check(app.feedback.last_clip_key.begins_with("place_" + item.sound_profile + "_"), "placement sound matches material: " + item.id)
	check(app.session.hazard_safe() and app.room.collectible_node.visible, "cleared walkway reveals golden keepsake")
	await mouse_click(app.rig.camera.unproject_position(app.room.collectible_node.global_position))
	check(app.session.found, "click discovers collectible")
	await touch_tap(app.hud.buttons["CLOTH_TOOL"].get_global_rect().get_center())
	await frames(60)
	check(app.interaction.clean_tool, "touch UI activates cleaning mode without duplicate world input")
	var audio_point: Vector2 = surface_screen(Vector2(0.25, 0.5))
	mouse_button(audio_point, true)
	await frames(2)
	check(app.feedback.brush_target == 0, "stationary cloth press has no continuous sound")
	mouse_motion(surface_screen(Vector2(0.65, 0.5)))
	await frames(2)
	check(app.feedback.brush_target > 0 and app.feedback.brush.playing, "cloth movement drives audible surface feedback")
	await create_timer(0.35).timeout
	check(not app.feedback.brush.playing and app.feedback.brush_gain == 0, "stationary cloth fades to silence without new motion")
	mouse_motion(surface_screen(Vector2(0.8, 0.5)))
	await frames(2)
	key_press(KEY_ESCAPE)
	await create_timer(0.2).timeout
	check(not app.feedback.brush.playing and app.interaction.mode == "idle", "canceling cleaning stops continuous sound")
	await click_button("SETTINGS")
	app.hud.effects_slider.value = 0
	await frames()
	check(AudioServer.is_bus_mute(AudioServer.get_bus_index("Effects")), "zero effects volume mutes all material and cleaning audio")
	app.hud.effects_slider.value = 65
	await frames()
	await click_button("CLOSE")
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
	check(app.session.clean_ratio() >= app.level.cleaning.completion_ratio, "mouse strokes really clean required surface")
	check(app.session.can_finish(), "all mandatory objectives complete through input")
	var loaded: GameSession = SaveStore.new(app.save_directory).load_session(app.level)
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
	var limiters: int = 0
	for index: int in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0, index) is AudioEffectHardLimiter:
			limiters += 1
	check(limiters == 1, "audio limiter remains single after replay")
	await _finish()

func _finish() -> void:
	print("INPUT RESULT: %d checks, %d failures" % [checks, failures])
	print("PC RENDER: " + RenderingServer.get_video_adapter_name() + " / " + RenderingServer.get_current_rendering_method())
	print("PC DRAW CALLS: " + str(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	app.queue_free()
	await frames(3)
	quit(1 if failures > 0 else 0)

func _run_kitchen() -> void:
	await touch_tap(item_screen("book_mint"))
	await touch_tap(target_screen("shelf"))
	await frames(18)
	check(app.session.placements.get("book_mint") == "shelf", "bedroom progress exists before navigation")
	var original: Dictionary = app.session.snapshot()
	var old_bytes: PackedByteArray = FileAccess.get_file_as_bytes(app.save_directory.path_join("progress.json"))
	var music_id: int = app.feedback.music.get_instance_id()
	await touch_tap(item_screen("shirt_gold"))
	await click_button("ROOMS")
	check(app.hud.rooms_overlay.visible and app.interaction.selected_item.is_empty(), "room picker cancels active selection")
	check(app.hud.blocks(app.hud.play_area.get_center()), "room picker blocks world gestures")
	await capture("home-rooms")
	await touch_tap(app.hud.room_buttons[RoomCatalog.KITCHEN.id].get_global_rect().get_center())
	await frames(60)
	check(app.level == RoomCatalog.KITCHEN and not app.hud.rooms_overlay.visible and app.room is KitchenView, "touch room choice opens kitchen")
	check(app.feedback.music.get_instance_id() == music_id and app.feedback.music.playing, "room change keeps the same music player running")
	var fitted: bool = true
	for point: Vector3 in app.rig.frame_points:
		fitted = fitted and app.hud.play_area.grow(3).has_point(app.rig.camera.unproject_position(point))
	check(fitted, "kitchen fits the phone play area")
	await capture("kitchen-before")
	await click_button("HINT")
	check(app.interaction.selected_item == "mug_sage" and app.hud.toast.text == app.tr("HINT_OPEN"), "kitchen hint identifies closed storage")
	await touch_tap(target_screen("dish_rack"))
	check(app.session.placements.is_empty() and app.hud.toast.text == app.tr("WRONG_CATEGORY"), "kitchen rejects incorrect destination through touch")
	await touch_tap(app.rig.camera.unproject_position(Vector3(2.6, 1.25, -2.2)))
	await frames(25)
	check(app.session.opened["cabinet"], "kitchen cupboard opens through touch")
	await touch_tap(item_screen("mug_sage"))
	await capture("kitchen-selection")
	await touch_tap(target_screen("cupboard"))
	await frames(18)
	check(app.session.placements.get("mug_sage") == "cupboard", "two taps store a kitchen mug")
	await click_button("UNDO")
	await frames(18)
	check(not app.session.placements.has("mug_sage"), "kitchen undo restores the mug")
	for item: ItemData in app.level.items:
		var target: String = ""
		for rule: ItemPlacementRule in app.level.placements:
			if app.session.placement_reason(item.id, rule.id).is_empty():
				target = rule.id
				break
		await touch_tap(item_screen(item.id))
		await touch_tap(target_screen(target))
		await frames(18)
		check(app.session.placements.get(item.id) == target, "kitchen touch placement: " + item.id)
	await touch_tap(app.rig.camera.unproject_position(app.room.collectible_node.global_position))
	check(app.session.found and app.session.hazard_safe(), "kitchen path clears and own keepsake is collected")
	await click_button("CLOTH_TOOL")
	await frames(60)
	for row: int in range(9):
		var y: float = 0.02 + float(row) * 0.12
		touch_event(0, surface_screen(Vector2(0.02, y)), true)
		await frames(2)
		for step: int in range(13):
			touch_motion(0, surface_screen(Vector2(0.02 + 0.96 * step / 12.0, y)))
			await frames(1)
		touch_event(0, surface_screen(Vector2(0.98, y)), false)
		await frames(2)
		if row == 2:
			await capture("kitchen-cleaning")
	check(app.session.can_finish(), "touch strokes clean the kitchen island and complete mandatory tasks")
	await click_button("CLOTH_TOOL")
	await frames(45)
	await click_button("INSPECT")
	await frames(30)
	check(app.session.completed and app.session.stars() == 3 and app.hud.results_panel.visible, "kitchen inspection awards three stars")
	await capture("kitchen-results")
	await click_button("COMPARE")
	await click_button("BEFORE")
	check(app.room.before_mode and app.session.completed, "kitchen comparison does not alter progress")
	await click_button("AFTER")
	await frames(30)
	await capture("kitchen-after")
	await click_button("BACK_RESULTS")
	var completed: Dictionary = app.session.snapshot()
	check(FileAccess.get_file_as_bytes(app.save_directory.path_join("progress.json")) == old_bytes, "full kitchen cycle leaves original bedroom save byte-identical")
	await click_button("ROOMS_RESULTS")
	check(app.hud.room_buttons[RoomCatalog.KITCHEN.id].text.contains("★★★"), "picker displays completed kitchen stars")
	await touch_tap(app.hud.room_buttons[RoomCatalog.BEDROOM.id].get_global_rect().get_center())
	await frames(35)
	check(app.session.snapshot() == original and app.room is BedroomView, "returning restores independent bedroom state")
	await click_button("ROOMS")
	await touch_tap(app.hud.room_buttons[RoomCatalog.KITCHEN.id].get_global_rect().get_center())
	await frames(35)
	check(app.session.snapshot() == completed and app.hud.results_panel.visible, "returning restores completed kitchen")
	var directory: String = app.save_directory
	app.free()
	await frames(3)
	app = MAIN.instantiate()
	app.save_directory = directory
	root.add_child(app)
	current_scene = app
	await frames(45)
	check(app.level == RoomCatalog.KITCHEN and app.session.snapshot() == completed, "application restart resumes last chosen room from disk")
	check(app.sessions[RoomCatalog.BEDROOM.id].snapshot() == original, "application restart also restores bedroom progress")
	await click_button("PLAY_AGAIN")
	await frames(30)
	check(app.level == RoomCatalog.KITCHEN and not app.session.completed and app.session.found and app.session.placements.is_empty(), "replay resets only kitchen and keeps its collectible")
	check(app.sessions[RoomCatalog.BEDROOM.id].snapshot() == original, "kitchen replay preserves bedroom progress")
	var limiters: int = 0
	for index: int in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0, index) is AudioEffectHardLimiter:
			limiters += 1
	check(limiters == 1, "navigation and application restart do not duplicate audio limiter")

func surface_screen(uv: Vector2) -> Vector2:
	var task: CleaningTaskData = app.level.cleaning
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
	point = input_point(point)
	var event: InputEventMouseButton = InputEventMouseButton.new()
	event.position = point
	event.global_position = point
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	Input.parse_input_event(event)

func mouse_motion(point: Vector2) -> void:
	point = input_point(point)
	var event: InputEventMouseMotion = InputEventMouseMotion.new()
	event.position = point
	event.global_position = point
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	Input.parse_input_event(event)

func touch_event(index: int, point: Vector2, pressed: bool) -> void:
	point = input_point(point)
	var event: InputEventScreenTouch = InputEventScreenTouch.new()
	event.index = index
	event.position = point
	event.pressed = pressed
	Input.parse_input_event(event)

func touch_motion(index: int, point: Vector2) -> void:
	point = input_point(point)
	var event: InputEventScreenDrag = InputEventScreenDrag.new()
	event.index = index
	event.position = point
	Input.parse_input_event(event)

func input_point(point: Vector2) -> Vector2:
	# Native events enter in window pixels; the engine applies the content scale.
	return root.get_final_transform() * point

func capture(name: String) -> void:
	if not graphical:
		return
	await RenderingServer.frame_post_draw
	var image: Image = root.get_texture().get_image()
	var error: Error = image.save_png(output_dir.path_join(name + ".png"))
	check(error == OK, "render capture: " + name)
