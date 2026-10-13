class_name InteractionController
extends Node

signal message(key: String, positive: bool)
signal selected(item_id: String)
signal stroke_finished

var session: GameSession
var view: BedroomView
var rig: CameraController
var hud: GameHUD
var clean_tool: bool = false
var mode: String = "idle"
var active_pointer: int = -2
var touches: Dictionary[int, Vector2] = {}
var press_position: Vector2
var last_position: Vector2
var selected_item: String = ""
var tap_kind: String = ""
var tap_id: String = ""
var previous_uv: Vector2 = Vector2(-1, -1)
var brush: MeshInstance3D

func configure(state: GameSession, room: BedroomView, camera_rig: CameraController, interface: GameHUD) -> void:
	session = state
	view = room
	rig = camera_rig
	hud = interface
	brush = view.box(view, Vector3.ZERO, Vector3(0.34, 0.045, 0.34), Color("#f1e9d2"))
	brush.visible = false

func _input(event: InputEvent) -> void:
	# Continuing gestures own their release even when crossing a UI panel.
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventMouseButton and not event.pressed and active_pointer == -1:
		_release(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and active_pointer == -1:
		_move(event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch:
		if event.canceled and touches.has(event.index):
			cancel()
			get_viewport().set_input_as_handled()
			return
		if event.pressed and not touches.is_empty() and not hud.blocks(event.position):
			cancel(false)
			touches[event.index] = event.position
			mode = "pinch"
			get_viewport().set_input_as_handled()
		elif not event.pressed and touches.has(event.index):
			if mode == "pinch" or mode == "wait_release":
				touches.erase(event.index)
				mode = "idle" if touches.is_empty() else "wait_release"
				active_pointer = -2
			elif event.index == active_pointer:
				_release(event.position)
				touches.erase(event.index)
			get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag and touches.has(event.index):
		if mode == "pinch" and touches.size() == 2:
			var values: Array = touches.values()
			var old_distance: float = values[0].distance_to(values[1])
			var old_center: Vector2 = (values[0] + values[1]) * 0.5
			touches[event.index] = event.position
			values = touches.values()
			var new_distance: float = values[0].distance_to(values[1])
			var new_center: Vector2 = (values[0] + values[1]) * 0.5
			if old_distance > 1 and new_distance > 1:
				rig.zoom(rig.desired_size * (old_distance / new_distance - 1.0))
			rig.orbit(new_center - old_center)
		elif event.index == active_pointer and mode != "wait_release":
			touches[event.index] = event.position
			_move(event.position)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_ESCAPE:
				cancel()
				hud.close_settings()
			KEY_C:
				hud.request_clean.emit()
			KEY_U:
				hud.request_undo.emit()
			KEY_SPACE:
				hud.request_overview.emit()
		return
	if event is InputEventMouseButton and event.pressed:
		if hud.blocks(event.position):
			return
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			rig.zoom(-0.6)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			rig.zoom(0.6)
		elif event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and active_pointer == -2:
			active_pointer = -1
			_press(event.position, event.button_index == MOUSE_BUTTON_RIGHT)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed and touches.is_empty() and not hud.blocks(event.position):
		touches[event.index] = event.position
		active_pointer = event.index
		_press(event.position)
		get_viewport().set_input_as_handled()

func _press(position: Vector2, orbit_only: bool = false) -> void:
	press_position = position
	last_position = position
	mode = "camera"
	if orbit_only or session.completed:
		return
	var origin: Vector3 = rig.camera.project_ray_origin(position)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, origin + rig.camera.project_ray_normal(position) * 50.0, 31)
	var hit: Dictionary = view.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var body: StaticBody3D = hit["collider"]
	var kind: String = body.get_meta("kind", "")
	var id: String = body.get_meta("id", "")
	if clean_tool:
		if kind == "clean":
			mode = "clean"
			previous_uv = Vector2(-1, -1)
			_clean(position)
		else:
			message.emit("CLEAN_HINT", false)
		return
	match kind:
		"item":
			selected_item = id
			mode = "selected"
			view.select(id)
			selected.emit(id)
		"container", "collectible":
			tap_kind = kind
			tap_id = id
			mode = "tap"

func _move(position: Vector2) -> void:
	if mode in ["selected", "tap"] and position.distance_to(press_position) > 7.0:
		mode = "drag" if mode == "selected" else "camera"
		if mode == "drag":
			if view.motion_tweens.has(selected_item) and view.motion_tweens[selected_item].is_valid():
				view.motion_tweens[selected_item].kill()
			view.item_nodes[selected_item].collision_layer = 0
	if mode == "drag":
		view.item_nodes[selected_item].global_position = rig.project_to_height(position, 1.5)
		var target_id: String = view.nearest_target(position, rig.camera)
		var valid: bool = false
		if not target_id.is_empty():
			valid = session.level.item(selected_item).category in session.level.placement(target_id).categories
		view.highlight(target_id, valid)
	elif mode == "camera":
		rig.orbit(position - last_position)
	elif mode == "clean":
		_clean(position)
	last_position = position

func _clean(position: Vector2) -> void:
	var task: CleaningTaskData = session.level.cleaning
	var point: Vector3 = rig.project_to_height(position, task.position.y)
	var uv: Vector2 = Vector2((point.x - task.position.x) / task.size.x + 0.5, (point.z - task.position.z) / task.size.y + 0.5)
	if uv.x < 0 or uv.x > 1 or uv.y < 0 or uv.y > 1:
		previous_uv = Vector2(-1, -1)
		brush.visible = false
		return
	brush.position = point + Vector3(0, 0.045, 0)
	brush.visible = true
	session.clean_at(uv, previous_uv)
	previous_uv = uv

func _release(position: Vector2) -> void:
	if mode == "drag":
		var target_id: String = view.nearest_target(position, rig.camera)
		var reason: String = session.place(selected_item, target_id)
		view.refresh()
		message.emit("PLACED" if reason.is_empty() else reason, reason.is_empty())
		view.select("")
		selected.emit("")
	elif mode == "tap":
		if tap_kind == "container":
			if session.toggle_container(tap_id):
				message.emit("CONTAINER_OPEN" if session.opened[tap_id] else "CONTAINER_CLOSED", true)
		elif tap_kind == "collectible" and session.discover():
			message.emit("COLLECTIBLE_FOUND", true)
	elif mode == "clean":
		stroke_finished.emit()
		if session.clean_ratio() >= session.level.cleaning.completion_ratio:
			message.emit("CLEAN_DONE", true)
	_cancel_state()

func cancel(clear_touches: bool = true) -> void:
	if mode == "drag":
		view.refresh()
	if mode == "clean":
		stroke_finished.emit()
	if clear_touches:
		touches.clear()
	_cancel_state()

func _cancel_state() -> void:
	mode = "idle"
	active_pointer = -2
	previous_uv = Vector2(-1, -1)
	if brush != null:
		brush.visible = false
	view.highlight("")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and session != null:
		cancel()
