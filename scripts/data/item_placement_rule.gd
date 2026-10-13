class_name ItemPlacementRule
extends Resource

@export var id: String = ""
@export var name_key: String = ""
@export var categories: PackedStringArray = PackedStringArray()
@export var slots: PackedVector3Array = PackedVector3Array()
@export var container_id: String = ""
@export var yaw: float = 0.0
@export var angle_tolerance: float = PI
@export var snap_pixels: float = 82.0
@export var color: Color = Color(0.4, 0.8, 0.7)
