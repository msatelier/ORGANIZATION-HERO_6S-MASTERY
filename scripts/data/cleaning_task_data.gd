class_name CleaningTaskData
extends Resource

@export var id: String = ""
@export var position: Vector3 = Vector3.ZERO
@export var size: Vector2 = Vector2(2.2, 1.2)
@export var columns: int = 64
@export var rows: int = 40
@export_range(0.1, 1.0) var completion_ratio: float = 0.85
