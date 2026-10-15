class_name ItemData
extends Resource

@export var id: String = ""
@export var name_key: String = ""
@export var category: String = ""
@export var shape: String = "book"
@export_enum("fabric", "paper", "plastic", "soft", "wood") var sound_profile: String = "wood"
@export var color: Color = Color.WHITE
@export var start_position: Vector3 = Vector3.ZERO
@export var size: Vector3 = Vector3(0.5, 0.2, 0.5)
