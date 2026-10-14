class_name CameraController
extends Node3D

var camera: Camera3D
var yaw: float = deg_to_rad(38.0)
var pitch: float = deg_to_rad(48.0)
var target: Vector3 = Vector3(0, 0.9, 0)
var desired_target: Vector3 = Vector3(0, 0.9, 0)
var desired_size: float = 13.0
var animated: bool = true

func _ready() -> void:
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = desired_size
	camera.near = 0.1
	camera.far = 60.0
	camera.h_offset = 1.0
	camera.current = true
	add_child(camera)
	_update_camera()

func _process(delta: float) -> void:
	var blend: float = 1.0 - exp(-10.0 * delta) if animated else 1.0
	target = target.lerp(desired_target, blend)
	camera.size = lerpf(camera.size, desired_size, blend)
	_update_camera()

func _update_camera() -> void:
	camera.position = target + Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * 16.0
	camera.look_at(target, Vector3.UP)

func orbit(delta: Vector2) -> void:
	yaw = clampf(yaw - delta.x * 0.006, deg_to_rad(-15), deg_to_rad(78))
	pitch = clampf(pitch + delta.y * 0.004, deg_to_rad(32), deg_to_rad(68))
	_update_camera()

func zoom(amount: float) -> void:
	desired_size = clampf(desired_size + amount, 4.0, 15.0)

func overview() -> void:
	desired_target = Vector3(0, 0.9, 0)
	desired_size = 13.0
	yaw = deg_to_rad(38)
	pitch = deg_to_rad(48)

func focus_surface(surface: Vector3) -> void:
	desired_target = surface
	desired_size = 5.0
	pitch = deg_to_rad(62)

func project_to_height(screen_position: Vector2, height: float) -> Vector3:
	var origin: Vector3 = camera.project_ray_origin(screen_position)
	var direction: Vector3 = camera.project_ray_normal(screen_position)
	if absf(direction.y) < 0.001:
		return Vector3.ZERO
	return origin + direction * ((height - origin.y) / direction.y)
