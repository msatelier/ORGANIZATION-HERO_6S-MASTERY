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
var door_tweens: Dictionary[String, Tween] = {}
var item_destinations: Dictionary[String, Vector3] = {}
var door_angles: Dictionary[String, float] = {}
var destination_guides: Dictionary[String, Node3D] = {}
var selected_item_id: String = ""
var hovered_target_id: String = ""
var hovered_allowed: bool = true
var shown_cleaned_count: int = -1
var shown_before_mode: bool = false

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
	shown_cleaned_count = -1
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
	label.pixel_size = 0.009
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
	hazard_marker = box(self, Vector3(0.2, 0.075, 0), Vector3(0.9, 0.02, 0.85), Color("#d9944b"))
	MeshBatcher.combine_children(self, [hazard_marker])

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
	var handle: MeshInstance3D = cylinder(door, Vector3(data.size.x - 0.18, 0, 0.07), 0.055, 0.11, Color("#e6ca91"))
	handle.rotation.x = PI / 2.0
	MeshBatcher.combine_children(body)
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
	var guide: Node3D = Node3D.new()
	guide.name = "Guide"
	body.add_child(guide)
	for x: float in [-0.66, 0.66]:
		box(guide, Vector3(x, 0.03, 0), Vector3(0.045, 0.045, 0.88), Color("#f8d283"))
	for z: float in [-0.44, 0.44]:
		box(guide, Vector3(0, 0.03, z), Vector3(1.36, 0.045, 0.045), Color("#f8d283"))
	guide.visible = false
	destination_guides[rule.id] = guide
	MeshBatcher.combine_children(guide)
	if rule.id in ["basket", "toy_box", "recycling"]:
		box(body, Vector3(0, -0.18, 0), Vector3(1.2, 0.3, 0.78), rule.color.darkened(0.17))
		for x: float in [-0.61, 0.61]:
			box(body, Vector3(x, 0.01, 0), Vector3(0.07, 0.38, 0.82), rule.color)
		for z: float in [-0.4, 0.4]:
			box(body, Vector3(0, 0.01, z), Vector3(1.26, 0.38, 0.07), rule.color)
	labels[rule.id] = _label(body, rule.name_key, Vector3(0, 0.57, 0))
	target_nodes[rule.id] = body
	MeshBatcher.combine_children(body, [pad])

func _build_item(item: ItemData) -> void:
	var body: StaticBody3D = _body("item", item.id, item.start_position, item.size + Vector3(0.12, 0.15, 0.12), 1)
	var visual: Node3D = Node3D.new()
	visual.name = "Visual"
	body.add_child(visual)
	ItemVisuals.build(self, visual, item)
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
		var moving: Tween = motion_tweens.get(item.id)
		if animated and moving != null and moving.is_valid() and moving.is_running() and item_destinations.get(item.id) == position_to:
			continue
		if moving != null and moving.is_valid():
			moving.kill()
		item_destinations[item.id] = position_to
		if animated and body.position.distance_to(position_to) > 0.01:
			var tween: Tween = create_tween()
			tween.tween_property(body, "position", position_to, 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
			motion_tweens[item.id] = tween
		else:
			body.position = position_to
	for container: ContainerData in level.containers:
		var angle: float = deg_to_rad(-100) if session.opened[container.id] and not before_mode else 0.0
		var door: Node3D = door_nodes[container.id]
		var turning: Tween = door_tweens.get(container.id)
		if not (animated and turning != null and turning.is_valid() and turning.is_running() and door_angles.get(container.id) == angle):
			if turning != null and turning.is_valid():
				turning.kill()
			door_angles[container.id] = angle
			if animated and absf(door.rotation.y - angle) > 0.001:
				var tween: Tween = create_tween()
				tween.tween_property(door, "rotation:y", angle, 0.28).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
				door_tweens[container.id] = tween
			else:
				door.rotation.y = angle
		labels[container.id].visible = before_mode or not session.opened[container.id]
	for rule: ItemPlacementRule in level.placements:
		var active: bool = rule.container_id.is_empty() or session.opened[rule.container_id]
		target_nodes[rule.id].visible = active and not before_mode
		target_nodes[rule.id].collision_layer = 2 if active and not before_mode else 0
	collectible_node.visible = session.collectible_visible() and not before_mode
	collectible_node.collision_layer = 16 if collectible_node.visible else 0
	hazard_marker.visible = before_mode or not session.hazard_safe()
	_refresh_destinations()
	if shown_cleaned_count != session.cleaned_count or shown_before_mode != before_mode:
		mask_dirty = true
		shown_cleaned_count = session.cleaned_count
		shown_before_mode = before_mode

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
	_refresh_destinations()

func select(item_id: String) -> void:
	selected_item_id = item_id
	for key: String in item_nodes:
		item_nodes[key].get_node("Selection").visible = key == item_id
	_refresh_destinations()

func highlight(target_id: String, allowed: bool = true) -> void:
	hovered_target_id = target_id
	hovered_allowed = allowed
	_refresh_destinations()

func _refresh_destinations() -> void:
	for key: String in target_nodes:
		var rule: ItemPlacementRule = level.placement(key)
		var pad: MeshInstance3D = target_nodes[key].get_node("Pad")
		var hovered: bool = key == hovered_target_id
		pad.material_override = material((Color("#f8d283") if hovered_allowed else Color("#dc796a")) if hovered else rule.color)
		var available: bool = session != null and not selected_item_id.is_empty() and session.placement_reason(selected_item_id, key).is_empty()
		destination_guides[key].visible = available and not before_mode
		labels[key].text = tr(rule.name_key)
		if available:
			var occupied: int = 0
			for item_id: String in session.placements:
				if session.placements[item_id] == key:
					occupied += 1
			labels[key].text += "\n" + tr("FREE_SLOTS_MOBILE") % (rule.slots.size() - occupied)

func nearest_target(screen_position: Vector2, camera: Camera3D, item_id: String = "") -> String:
	var nearest: String = ""
	var distance: float = INF
	var available: String = ""
	var available_distance: float = INF
	for rule: ItemPlacementRule in level.placements:
		var center: Vector3 = target_nodes[rule.id].global_position
		if camera.is_position_behind(center):
			continue
		var current: float = camera.unproject_position(center).distance_to(screen_position)
		if current < distance and current <= rule.snap_pixels:
			nearest = rule.id
			distance = current
		if not item_id.is_empty() and current < available_distance and current <= rule.snap_pixels and session.placement_reason(item_id, rule.id).is_empty():
			available = rule.id
			available_distance = current
	return available if not available.is_empty() else nearest
