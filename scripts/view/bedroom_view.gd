class_name BedroomView
extends RoomView

func _init(definition: LevelData) -> void:
	super(definition)

func _build_room() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var settings: Environment = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("#213f46")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("#f5dec4")
	settings.ambient_light_energy = 0.62
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -28, 0)
	sun.light_color = Color("#ffe2b9")
	sun.light_energy = 1.0
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 30.0
	add_child(sun)
	box(self, Vector3(0, -0.14, 0), Vector3(8.4, 0.3, 7.2), Color("#b88f63"))
	for index: int in range(12):
		box(self, Vector3(-3.85 + index * 0.7, 0.025, 0), Vector3(0.685, 0.035, 7), Color("#d9b98a") if index % 2 == 0 else Color("#cfad7f"))
	box(self, Vector3(-4.14, 1.65, 0), Vector3(0.18, 3.3, 7.2), Color("#dcb9a7"))
	box(self, Vector3(0, 1.65, -3.56), Vector3(8.4, 3.3, 0.18), Color("#e8cfb5"))
	box(self, Vector3(-4.0, 0.17, 0), Vector3(0.1, 0.28, 7), Color("#f1debf"))
	box(self, Vector3(0, 0.17, -3.42), Vector3(8.2, 0.28, 0.1), Color("#f1debf"))
	# Window and its broad frame keep the silhouette readable at phone scale.
	box(self, Vector3(-2.05, 2.05, -3.4), Vector3(1.8, 1.45, 0.12), Color("#faf0d5"))
	box(self, Vector3(-2.05, 2.05, -3.31), Vector3(1.56, 1.2, 0.05), Color("#8bb9b8"))
	box(self, Vector3(-2.05, 2.05, -3.25), Vector3(0.08, 1.2, 0.08), Color("#faf0d5"))
	box(self, Vector3(-2.05, 2.05, -3.25), Vector3(1.56, 0.08, 0.08), Color("#faf0d5"))
	box(self, Vector3(-2.35, 0.32, -0.1), Vector3(2.15, 0.5, 3.45), Color("#956e50"))
	box(self, Vector3(-2.35, 0.67, -0.1), Vector3(2.1, 0.28, 3.4), Color("#f4e5cc"))
	box(self, Vector3(-2.35, 0.81, 0.35), Vector3(2.04, 0.08, 2.35), Color("#46867a"))
	for index: int in range(6):
		box(self, Vector3(-3.23 + index * 0.35, 0.86, 0.35), Vector3(0.025, 0.015, 2.35), Color("#66a294"))
	box(self, Vector3(-2.35, 0.95, -1.17), Vector3(1.45, 0.25, 0.5), Color("#eee3ca"))
	box(self, Vector3(-2.35, 0.95, -1.87), Vector3(2.2, 1.6, 0.12), Color("#ad8060"))
	box(self, Vector3(0.0, 0.06, 0.9), Vector3(2.3, 0.04, 3.3), Color("#c6ceba"))
	# Book shelf.
	for height: float in [0.43, 1.0, 1.65]:
		box(self, Vector3(-0.1, height, -2.8), Vector3(1.8, 0.12, 0.7), Color("#a47e59"))
	for x: float in [-0.95, 0.75]:
		box(self, Vector3(x, 0.85, -2.8), Vector3(0.1, 1.7, 0.7), Color("#b68b63"))
	cylinder(self, Vector3(0.15, 1.86, -2.8), 0.18, 0.3, Color("#cb8b64"))
	cylinder(self, Vector3(0.15, 2.1, -2.8), 0.025, 0.44, Color("#588469"))
	for index: int in range(6):
		var side: float = -1.0 if index % 2 == 0 else 1.0
		var leaf: MeshInstance3D = _leaf(Vector3(0.15 + side * 0.12, 2.02 + index * 0.043, -2.8), Vector3(0.3, 0.06, 0.14), Color("#6d9673"))
		leaf.rotation.z = side * 0.48
	# Desk and stool.
	box(self, Vector3(2.05, 1.1, 0.6), Vector3(2.3, 0.16, 1.3), Color("#ae815c"))
	for x: float in [1.1, 3.0]:
		for z: float in [0.1, 1.1]:
			box(self, Vector3(x, 0.53, z), Vector3(0.13, 1.0, 0.13), Color("#956c4d"))
	cylinder(self, Vector3(2.2, 0.55, 1.7), 0.34, 0.13, Color("#cfaa72"))
	for x: float in [2.0, 2.4]:
		box(self, Vector3(x, 0.26, 1.7), Vector3(0.09, 0.52, 0.09), Color("#a57c56"))
	box(self, Vector3(3.6, 1.85, -3.35), Vector3(0.48, 0.72, 0.1), Color("#a07850"))
	box(self, Vector3(3.6, 1.85, -3.26), Vector3(0.35, 0.59, 0.04), Color("#f0d5a3"))
	_build_details()
	MeshBatcher.combine_children(self)

func _leaf(position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: SphereMesh = SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 10
	shape.rings = 4
	mesh.mesh = shape
	mesh.scale = size
	mesh.position = position
	mesh.material_override = material(color)
	add_child(mesh)
	return mesh

func _build_details() -> void:
	# Decorations stay outside the item and cleaning interaction regions.
	box(self, Vector3(-2.05, 2.86, -3.17), Vector3(2.22, 0.07, 0.08), Color("#aa815c"))
	for x: float in [-3.03, -1.07]:
		for fold: int in range(3):
			cylinder(self, Vector3(x + (fold - 1) * 0.075, 2.06, -3.18), 0.055, 1.48, Color("#87a997") if fold % 2 == 0 else Color("#719988"))
	# Blanket fold and a woven border on the rug.
	box(self, Vector3(-2.35, 0.865, 1.35), Vector3(2.03, 0.04, 0.32), Color("#39776e"))
	for x: float in [-1.04, 1.04]:
		box(self, Vector3(x, 0.085, 0.9), Vector3(0.08, 0.008, 3.08), Color("#aab9a2"))
	for z: float in [-0.6, 2.4]:
		box(self, Vector3(0, 0.085, z), Vector3(2.16, 0.008, 0.08), Color("#aab9a2"))
	# Small lamp on top of the wardrobe, away from the playable desk.
	cylinder(self, Vector3(2.95, 2.49, -2.78), 0.18, 0.07, Color("#b18957"))
	cylinder(self, Vector3(2.95, 2.67, -2.78), 0.025, 0.32, Color("#b18957"))
	cylinder(self, Vector3(2.95, 2.91, -2.78), 0.28, 0.3, Color("#ead7ad"), 0.18)
	# A tiny landscape inside the existing wall frame.
	box(self, Vector3(3.6, 1.94, -3.23), Vector3(0.31, 0.23, 0.015), Color("#89b4ad"))
	box(self, Vector3(3.6, 1.72, -3.23), Vector3(0.31, 0.17, 0.015), Color("#809475"))
