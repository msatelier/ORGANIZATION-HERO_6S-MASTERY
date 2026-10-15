class_name KitchenView
extends RoomView

func _init(definition: LevelData) -> void:
	super(definition)

func _build_room() -> void:
	var world: WorldEnvironment = WorldEnvironment.new()
	var environment: Environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#213f46")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#f5e8ce")
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world.environment = environment
	add_child(world)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -28, 0)
	sun.light_color = Color("#ffe2b9")
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30
	add_child(sun)
	box(self, Vector3(0, -0.14, 0), Vector3(8.4, 0.3, 7.2), Color("#c8b99b"))
	for x: int in range(10):
		for z: int in range(9):
			box(self, Vector3(-3.78 + x * 0.84, 0.025, -3.2 + z * 0.8), Vector3(0.82, 0.035, 0.78), Color("#e7dcca") if (x + z) % 2 == 0 else Color("#d5c9b4"))
	box(self, Vector3(-4.14, 1.65, 0), Vector3(0.18, 3.3, 7.2), Color("#94b5a0"))
	box(self, Vector3(0, 1.65, -3.56), Vector3(8.4, 3.3, 0.18), Color("#cbd5b9"))
	box(self, Vector3(0, 1.15, -3.42), Vector3(8.2, 0.52, 0.06), Color("#f1e7d0"))
	# Refrigerator, with a note and separate freezer door.
	box(self, Vector3(-3.1, 1.3, -2.65), Vector3(1.25, 2.5, 1.18), Color("#e6e3cd"))
	for height: float in [0.95, 2.15]:
		box(self, Vector3(-3.1, height, -2.02), Vector3(1.15, 0.95 if height < 2 else 0.65, 0.08), Color("#f3eedc"))
		box(self, Vector3(-2.68, height, -1.95), Vector3(0.055, 0.35, 0.07), Color("#79978a"))
	box(self, Vector3(-3.22, 1.38, -1.96), Vector3(0.35, 0.38, 0.015), Color("#e9bb6d"))
	# Rear counter and sink. The dish rack remains a live placement target.
	box(self, Vector3(-0.65, 0.51, -2.8), Vector3(2.6, 0.94, 1.12), Color("#699387"))
	box(self, Vector3(-0.65, 1.02, -2.8), Vector3(2.75, 0.12, 1.22), Color("#f1dfbb"))
	box(self, Vector3(-1.38, 1.09, -2.8), Vector3(0.8, 0.04, 0.8), Color("#a1b5ab"))
	box(self, Vector3(-1.38, 1.12, -2.8), Vector3(0.6, 0.02, 0.57), Color("#557c78"))
	cylinder(self, Vector3(-1.38, 1.3, -3.15), 0.035, 0.4, Color("#bfc7b7"))
	box(self, Vector3(-1.38, 1.48, -3.02), Vector3(0.07, 0.07, 0.3), Color("#bfc7b7"))
	for x: float in [-1.25, -0.05]:
		box(self, Vector3(x, 0.55, -2.21), Vector3(1.12, 0.8, 0.06), Color("#83aa97"))
		box(self, Vector3(x, 0.87, -2.16), Vector3(0.33, 0.04, 0.04), Color("#e9d5a8"))
	# Left pantry counter and low recipe stand.
	box(self, Vector3(-2.9, 0.46, -0.7), Vector3(1.5, 0.85, 1.1), Color("#bc9270"))
	box(self, Vector3(-2.9, 0.93, -0.7), Vector3(1.65, 0.12, 1.2), Color("#efdfbd"))
	box(self, Vector3(-0.85, 0.27, 2.7), Vector3(1.4, 0.42, 0.9), Color("#bd9670"))
	# Preparation island: only this broad top is cleaned.
	box(self, Vector3(2.05, 0.54, 0.6), Vector3(2.12, 1.0, 1.12), Color("#739f90"))
	box(self, Vector3(2.05, 1.1, 0.6), Vector3(2.3, 0.16, 1.3), Color("#e5c598"))
	box(self, Vector3(2.05, 0.75, 1.19), Vector3(1.85, 0.04, 0.05), Color("#d4b479"))
	# Bright window and herb pots, away from interactive regions.
	box(self, Vector3(-0.5, 2.4, -3.4), Vector3(2.1, 1.15, 0.12), Color("#f6e8c9"))
	box(self, Vector3(-0.5, 2.4, -3.3), Vector3(1.85, 0.92, 0.05), Color("#8cbabd"))
	box(self, Vector3(-0.5, 2.4, -3.23), Vector3(0.07, 0.94, 0.07), Color("#f6e8c9"))
	for x: float in [-1.15, 0.1]:
		cylinder(self, Vector3(x, 1.86, -3.1), 0.14, 0.22, Color("#c2875d"))
		for offset: float in [-0.08, 0, 0.08]:
			cylinder(self, Vector3(x + offset, 2.06, -3.1), 0.045, 0.25, Color("#779660"), 0.015)
	MeshBatcher.combine_children(self)
