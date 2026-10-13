class_name BedroomView
extends Node3D

var level: LevelData
var session: GameSession
var item_nodes: Dictionary[String, StaticBody3D] = {}
var target_nodes: Dictionary[String, StaticBody3D] = {}
var door_nodes: Dictionary[String, Node3D] = {}
var labels: Dictionary[String, Label3D] = {}
var materials: Dictionary[String, StandardMaterial3D] = {}
var clean_material: ShaderMaterial
var clean_texture: ImageTexture
var collectible_node: StaticBody3D
var hazard_marker: MeshInstance3D
var mask_dirty: bool = true
var before_mode: bool = false
var animated: bool = true
var motion_tweens: Dictionary[String, Tween] = {}

func _init(definition: LevelData) -> void:
	level = definition

func _ready() -> void:
	_build_room()
	for container: ContainerData in level.containers:
		_build_cabinet(container)
	for rule: ItemPlacementRule in level.placements:
		_build_target(rule)
	for item: ItemData in level.items:
		_build_item(item)
	_build_cleaning()
	_build_collectible()
	refresh_labels()

func bind(state: GameSession) -> void:
	session = state
	session.changed.connect(refresh)
	refresh()

func material(color: Color, unshaded: bool = false) -> StandardMaterial3D:
	var key: String = color.to_html() + str(unshaded)
	if materials.has(key):
		return materials[key]
	var result: StandardMaterial3D = StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.85
	result.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED if unshaded else BaseMaterial3D.SHADING_MODE_PER_PIXEL
	materials[key] = result
	return result

func box(parent: Node3D, position: Vector3, size: Vector3, color: Color) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: BoxMesh = BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = material(color)
	mesh.position = position
	parent.add_child(mesh)
	return mesh

func cylinder(parent: Node3D, position: Vector3, radius: float, height: float, color: Color, top: float = -1.0) -> MeshInstance3D:
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var shape: CylinderMesh = CylinderMesh.new()
	shape.top_radius = radius if top < 0 else top
	shape.bottom_radius = radius
	shape.height = height
	shape.radial_segments = 12
	mesh.mesh = shape
	mesh.material_override = material(color)
	mesh.position = position
	parent.add_child(mesh)
	return mesh

func _body(kind: String, id: String, position: Vector3, size: Vector3, layer: int) -> StaticBody3D:
	var body: StaticBody3D = StaticBody3D.new()
	body.set_meta("kind", kind)
	body.set_meta("id", id)
	body.position = position
	body.collision_layer = layer
	body.collision_mask = 0
	var collision: CollisionShape3D = CollisionShape3D.new()
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)
	return body

func _label(parent: Node3D, text_key: String, position: Vector3) -> Label3D:
	var label: Label3D = Label3D.new()
	label.text = tr(text_key)
	label.position = position
	label.font_size = 46
	label.pixel_size = 0.006
	label.outline_size = 7
	label.modulate = Color(1.0, 0.96, 0.83)
	label.outline_modulate = Color(0.12, 0.23, 0.22)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	parent.add_child(label)
	return label

func _build_room() -> void:
	var environment: WorldEnvironment = WorldEnvironment.new()
	var settings: Environment = Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color("#213f46")
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("#f5dec4")
	settings.ambient_light_energy = 0.55
	settings.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = settings
	add_child(environment)
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-58, -28, 0)
	sun.light_color = Color("#ffe2b9")
	sun.light_energy = 1.25
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
	cylinder(self, Vector3(0.15, 2.16, -2.8), 0.38, 0.5, Color("#6d9673"), 0.04)
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
	hazard_marker = box(self, Vector3(0.2, 0.075, 0), Vector3(0.9, 0.02, 0.85), Color("#d9944b"))

func _build_cabinet(data: ContainerData) -> void:
	var body: StaticBody3D = _body("container", data.id, data.position, data.size, 4)
	box(body, Vector3(0, 0, -data.size.z / 2.0), Vector3(data.size.x, data.size.y, 0.08), Color("#786748"))
	for x: float in [-data.size.x / 2.0, data.size.x / 2.0]:
		box(body, Vector3(x, 0, 0), Vector3(0.1, data.size.y, data.size.z), Color("#a8815c"))
	for height: float in [-data.size.y / 2.0, -0.46, -0.15, data.size.y / 2.0]:
		box(body, Vector3(0, height, 0), Vector3(data.size.x, 0.07, data.size.z), Color("#c8a178"))
	var door: Node3D = Node3D.new()
	door.position = Vector3(-data.size.x / 2.0, -0.3, data.size.z / 2.0 + 0.05)
	body.add_child(door)
	box(door, Vector3(data.size.x / 2.0, 0, 0), Vector3(data.size.x, 1.1, 0.08), Color("#c8a178"))
	cylinder(door, Vector3(data.size.x - 0.18, 0, 0.07), 0.055, 0.11, Color("#e6ca91"))
	door_nodes[data.id] = door
	labels[data.id] = _label(body, data.name_key, Vector3(0, data.size.y / 2.0 + 0.28, 0))

func _build_target(rule: ItemPlacementRule) -> void:
	var center: Vector3 = Vector3.ZERO
	for slot: Vector3 in rule.slots:
		center += slot
	center /= rule.slots.size()
	var body: StaticBody3D = _body("target", rule.id, center - Vector3(0, 0.12, 0), Vector3(1.25, 0.22, 0.78), 2)
	var pad: MeshInstance3D = box(body, Vector3.ZERO, Vector3(1.18, 0.03, 0.7), rule.color)
	pad.name = "Pad"
	if rule.id in ["basket", "toy_box", "recycling"]:
		box(body, Vector3(0, -0.18, 0), Vector3(1.2, 0.3, 0.78), rule.color.darkened(0.17))
		for x: float in [-0.61, 0.61]:
			box(body, Vector3(x, 0.01, 0), Vector3(0.07, 0.38, 0.82), rule.color)
		for z: float in [-0.4, 0.4]:
			box(body, Vector3(0, 0.01, z), Vector3(1.26, 0.38, 0.07), rule.color)
	labels[rule.id] = _label(body, rule.name_key, Vector3(0, 0.57, 0))
	target_nodes[rule.id] = body

func _build_item(item: ItemData) -> void:
	var body: StaticBody3D = _body("item", item.id, item.start_position, item.size + Vector3(0.12, 0.15, 0.12), 1)
	var visual: Node3D = Node3D.new()
	visual.name = "Visual"
	body.add_child(visual)
	match item.shape:
		"cloth":
			box(visual, Vector3.ZERO, item.size, item.color)
			box(visual, Vector3(0, 0.015, -0.04), item.size * Vector3(0.65, 1.12, 0.75), item.color.lightened(0.08))
		"book":
			box(visual, Vector3.ZERO, item.size, item.color)
			box(visual, Vector3(0, 0.002, 0.04), item.size * Vector3(0.84, 0.72, 0.86), Color("#f0e7cc"))
			box(visual, Vector3(0, item.size.y / 2.0, 0), item.size * Vector3(1, 0.15, 1), item.color)
		"bottle":
			cylinder(visual, Vector3.ZERO, 0.14, 0.5, item.color)
			cylinder(visual, Vector3(0, 0.28, 0), 0.08, 0.13, item.color.darkened(0.3))
			cylinder(visual, Vector3(0, -0.02, 0), 0.145, 0.14, Color("#d7ddc6"))
		"plush":
			cylinder(visual, Vector3.ZERO, 0.25, 0.45, item.color, 0.18)
			cylinder(visual, Vector3(0, 0.27, 0), 0.25, 0.27, item.color, 0.18)
			for x: float in [-0.19, 0.19]:
				cylinder(visual, Vector3(x, 0.42, 0), 0.09, 0.11, item.color)
			for x: float in [-0.09, 0.09]:
				box(visual, Vector3(x, 0.3, 0.23), Vector3(0.035, 0.04, 0.035), Color("#433d32"))
		_:
			box(visual, Vector3.ZERO, item.size, item.color)
	var ring: MeshInstance3D = cylinder(body, Vector3(0, -item.size.y / 2.0 + 0.01, 0), maxf(item.size.x, item.size.z) * 0.7, 0.025, Color("#f4c977"))
	ring.name = "Selection"
	ring.visible = false
	item_nodes[item.id] = body

func _build_cleaning() -> void:
	var task: CleaningTaskData = level.cleaning
	var body: StaticBody3D = _body("clean", task.id, task.position, Vector3(task.size.x, 0.05, task.size.y), 8)
	var mesh: MeshInstance3D = MeshInstance3D.new()
	var plane: PlaneMesh = PlaneMesh.new()
	plane.size = task.size
	mesh.mesh = plane
	clean_material = ShaderMaterial.new()
	clean_material.shader = load("res://assets/shaders/dirt.gdshader")
	clean_texture = ImageTexture.create_from_image(Image.create(task.columns, task.rows, false, Image.FORMAT_RGBA8))
	clean_material.set_shader_parameter("dirt_mask", clean_texture)
	mesh.material_override = clean_material
	body.add_child(mesh)

func _build_collectible() -> void:
	collectible_node = _body("collectible", level.collectible.id, level.collectible.position, Vector3(0.45, 0.4, 0.45), 16)
	var token: MeshInstance3D = cylinder(collectible_node, Vector3.ZERO, 0.2, 0.08, Color("#f8ce66"))
	token.rotation_degrees.x = 30
	box(collectible_node, Vector3(0, 0.08, 0), Vector3(0.16, 0.04, 0.05), Color("#fff0bf"))

func refresh() -> void:
	if session == null:
		return
	for item: ItemData in level.items:
		var body: StaticBody3D = item_nodes[item.id]
		var position_to: Vector3 = item.start_position
		var visible_now: bool = true
		if session.placements.has(item.id) and not before_mode:
			var rule: ItemPlacementRule = level.placement(session.placements[item.id])
			position_to = rule.slots[session.slots[item.id]]
			visible_now = rule.container_id.is_empty() or session.opened[rule.container_id]
		body.visible = visible_now
		body.collision_layer = 1 if visible_now and not before_mode else 0
		if motion_tweens.has(item.id) and motion_tweens[item.id].is_valid():
			motion_tweens[item.id].kill()
		if animated and body.position.distance_to(position_to) > 0.01:
			var tween: Tween = create_tween()
			tween.tween_property(body, "position", position_to, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			motion_tweens[item.id] = tween
		else:
			body.position = position_to
	for container: ContainerData in level.containers:
		door_nodes[container.id].rotation.y = deg_to_rad(-100) if session.opened[container.id] and not before_mode else 0.0
		labels[container.id].visible = before_mode or not session.opened[container.id]
	for rule: ItemPlacementRule in level.placements:
		var active: bool = rule.container_id.is_empty() or session.opened[rule.container_id]
		target_nodes[rule.id].visible = active and not before_mode
		target_nodes[rule.id].collision_layer = 2 if active and not before_mode else 0
	collectible_node.visible = session.collectible_visible() and not before_mode
	collectible_node.collision_layer = 16 if collectible_node.visible else 0
	hazard_marker.visible = before_mode or not session.hazard_safe()
	mask_dirty = true

func _process(_delta: float) -> void:
	if mask_dirty and session != null:
		_update_mask()
		mask_dirty = false

func _update_mask() -> void:
	var task: CleaningTaskData = level.cleaning
	var image: Image = Image.create(task.columns, task.rows, false, Image.FORMAT_RGBA8)
	for y: int in range(task.rows):
		for x: int in range(task.columns):
			var dirty: bool = before_mode or session.cleaned[y * task.columns + x] == 0
			var noise: float = 0.52 + float((x * 17 + y * 31) % 11) * 0.035
			image.set_pixel(x, y, Color(noise, noise, noise, 1.0 if dirty else 0.0))
	clean_texture.update(image)

func refresh_labels() -> void:
	for key: String in labels:
		var rule: ItemPlacementRule = level.placement(key)
		if rule != null:
			labels[key].text = tr(rule.name_key)
		else:
			for container: ContainerData in level.containers:
				if container.id == key:
					labels[key].text = tr(container.name_key)

func select(item_id: String) -> void:
	for key: String in item_nodes:
		item_nodes[key].get_node("Selection").visible = key == item_id

func highlight(target_id: String, allowed: bool = true) -> void:
	for key: String in target_nodes:
		var rule: ItemPlacementRule = level.placement(key)
		var pad: MeshInstance3D = target_nodes[key].get_node("Pad")
		pad.material_override = material((Color("#f8d283") if allowed else Color("#dc796a")) if key == target_id else rule.color)

func nearest_target(screen_position: Vector2, camera: Camera3D) -> String:
	var nearest: String = ""
	var distance: float = INF
	for rule: ItemPlacementRule in level.placements:
		var center: Vector3 = target_nodes[rule.id].global_position
		if camera.is_position_behind(center):
			continue
		var current: float = camera.unproject_position(center).distance_to(screen_position)
		if current < distance and current <= rule.snap_pixels:
			nearest = rule.id
			distance = current
	return nearest
