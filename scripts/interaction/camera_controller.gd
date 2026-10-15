class_name CameraController
extends Node3D

var camera: Camera3D
var yaw: float = deg_to_rad(38.0)
var pitch: float = deg_to_rad(48.0)
var target: Vector3 = Vector3(0, 0.9, 0)
var desired_target: Vector3 = Vector3(0, 0.9, 0)
var desired_size: float = 13.0
var animated: bool = true
var play_area: Rect2
var zoom_factor: float = 1.0
var fit_size: float = 13.0
var frame_points: Array[Vector3] = []
var room_points: Array[Vector3] = []
var desired_h_offset: float = 0.0
var desired_v_offset: float = 0.0

func _ready() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = desired_size
	camera.near = 0.1
	camera.far = 60.0
	camera.h_offset = 1.0
	camera.current = true
	add_child(camera)
	frame_points = _overview_points()
	_update_camera()
	_fit_frame()

func _process(delta: float) -> void:
	var blend: float = 1.0 - exp(-10.0 * delta) if animated else 1.0
	target = target.lerp(desired_target, blend)
	_update_camera()
	_fit_frame()
	camera.size = lerpf(camera.size, desired_size, blend)
	camera.h_offset = lerpf(camera.h_offset, desired_h_offset, blend)
	camera.v_offset = lerpf(camera.v_offset, desired_v_offset, blend)
	_update_camera()

func _update_camera() -> void:
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 16.0
	camera.look_at(target, Vector3.UP)

func orbit(delta: Vector2) -> void:
	yaw = clampf(yaw - delta.x * 0.006, deg_to_rad(-15), deg_to_rad(78))
	pitch = clampf(pitch + delta.y * 0.004, deg_to_rad(32), deg_to_rad(68))
	_update_camera()

func zoom(amount: float) -> void:
	zoom_factor = clampf(zoom_factor + amount / fit_size, 0.45, 1.6)
	_fit_frame()

func overview() -> void:
	desired_target = Vector3(0, 0.9, 0)
	zoom_factor = 1.0
	frame_points = _overview_points()
	yaw = deg_to_rad(38)
	pitch = deg_to_rad(48)
	_update_camera()
	_fit_frame()

func focus_surface(surface: Vector3, size: Vector2 = Vector2(2.2, 1.2)) -> void:
	desired_target = surface
	zoom_factor = 1.0
	frame_points.clear()
	for x: float in [-size.x * 0.65, size.x * 0.65]:
		for z: float in [-size.y * 0.75, size.y * 0.75]:
			frame_points.append(surface + Vector3(x, 0, z))
	pitch = deg_to_rad(62)
	_update_camera()
	_fit_frame()

func set_play_area(area: Rect2) -> void:
	play_area = area
	_fit_frame()

func set_room_frame(points: Array[Vector3]) -> void:
	room_points = points.duplicate()
	overview()

func _overview_points() -> Array[Vector3]:
	return room_points.duplicate()

func _fit_frame() -> void:
	if camera == null or frame_points.is_empty():
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var area: Rect2 = play_area if play_area.has_area() else Rect2(Vector2.ZERO, viewport_size)
	var minimum: Vector2 = Vector2(INF, INF)
	var maximum: Vector2 = Vector2(-INF, -INF)
	for point: Vector3 in frame_points:
		var delta: Vector3 = point - desired_target
		var projected: Vector2 = Vector2(delta.dot(camera.global_basis.x), delta.dot(camera.global_basis.y))
		minimum = minimum.min(projected)
		maximum = maximum.max(projected)
	var span: Vector2 = maximum - minimum
	fit_size = maxf(span.y * viewport_size.y / maxf(1, area.size.y), span.x * viewport_size.y / maxf(1, area.size.x)) * 1.06
	desired_size = fit_size * zoom_factor
	var center: Vector2 = (minimum + maximum) * 0.5
	desired_h_offset = center.x + (viewport_size.x * 0.5 - area.get_center().x) * desired_size / viewport_size.y
	desired_v_offset = center.y + (area.get_center().y - viewport_size.y * 0.5) * desired_size / viewport_size.y

func project_to_height(screen_position: Vector2, height: float) -> Vector3:
	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var direction: Vector3 = camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.001:
		return Vector3.ZERO
	return origin + direction * ((height - origin.y) / direction.y)
