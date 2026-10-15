class_name ItemVisuals
extends RefCounted

static func build(room: Node3D, parent: Node3D, item: ItemData) -> void:
	var color: Color = item.color
	var size: Vector3 = item.size
	match item.shape:
		"shirt":
			var outline: PackedVector2Array = PackedVector2Array([
				Vector2(-0.5, -0.22), Vector2(-0.32, -0.5), Vector2(-0.16, -0.44),
				Vector2(-0.1, -0.32), Vector2(0.1, -0.32), Vector2(0.16, -0.44),
				Vector2(0.32, -0.5), Vector2(0.5, -0.22), Vector2(0.33, -0.11),
				Vector2(0.27, -0.22), Vector2(0.27, 0.5), Vector2(-0.27, 0.5),
				Vector2(-0.27, -0.22), Vector2(-0.33, -0.11)
			])
			_outline(room, parent, outline, size, color)
			room.box(parent, Vector3(0, size.y * 0.25 + 0.006, 0.1), Vector3(size.x * 0.4, 0.01, 0.027), color.lightened(0.25))
		"socks":
			var outline: PackedVector2Array = PackedVector2Array([
				Vector2(-0.25, -0.5), Vector2(0.25, -0.5), Vector2(0.25, 0.05),
				Vector2(0.5, 0.22), Vector2(0.5, 0.42), Vector2(0.27, 0.5), Vector2(-0.25, 0.3)
			])
			_outline(room, parent, outline, size, color)
			room.box(parent, Vector3(0, size.y * 0.25 + 0.006, -size.z * 0.37), Vector3(size.x * 0.52, 0.012, size.z * 0.15), color.lightened(0.38))
		"book":
			room.box(parent, Vector3.ZERO, size * Vector3(0.91, 0.74, 0.95), Color("#f1e7cc"))
			for height: float in [-0.46, 0.46]:
				room.box(parent, Vector3(0, size.y * height, 0), size * Vector3(1, 0.14, 1), color)
			room.box(parent, Vector3(-size.x * 0.46, 0, 0), Vector3(size.x * 0.08, size.y, size.z), color.darkened(0.13))
			room.box(parent, Vector3(0.04, size.y * 0.55, -0.05), Vector3(size.x * 0.52, 0.01, size.z * 0.07), Color("#ebdab1"))
			room.box(parent, Vector3(size.x * 0.22, 0, size.z * 0.47), Vector3(0.04, 0.025, 0.1), Color("#b46246"))
		"bottle":
			room.cylinder(parent, Vector3(0, -0.04, 0), 0.135, 0.42, color)
			room.cylinder(parent, Vector3(0, 0.19, 0), 0.135, 0.08, color, 0.065)
			room.cylinder(parent, Vector3(0, 0.26, 0), 0.07, 0.07, color.darkened(0.3))
			room.cylinder(parent, Vector3(0, -0.05, 0), 0.138, 0.14, Color("#ede7cd"))
			room.box(parent, Vector3(0, -0.045, 0.14), Vector3(0.1, 0.07, 0.015), color.darkened(0.12))
		"plush":
			_sphere(room, parent, Vector3(0, -0.045, 0), Vector3(0.37, 0.39, 0.31), color)
			_sphere(room, parent, Vector3(0, 0.19, 0), Vector3(0.38, 0.31, 0.31), color)
			for side: float in [-1.0, 1.0]:
				_sphere(room, parent, Vector3(side * 0.15, 0.32, 0), Vector3(0.13, 0.14, 0.11), color)
				_sphere(room, parent, Vector3(side * 0.18, -0.04, 0.015), Vector3(0.14, 0.22, 0.14), color)
				_sphere(room, parent, Vector3(side * 0.11, -0.2, 0.055), Vector3(0.16, 0.14, 0.18), color)
				_sphere(room, parent, Vector3(side * 0.073, 0.22, 0.145), Vector3(0.037, 0.039, 0.025), Color("#41392e"))
			_sphere(room, parent, Vector3(0, 0.14, 0.16), Vector3(0.15, 0.1, 0.065), color.lightened(0.25))
			_sphere(room, parent, Vector3(0, 0.16, 0.195), Vector3(0.047, 0.033, 0.02), Color("#41392e"))
			room.box(parent, Vector3(0, 0.045, 0.165), Vector3(0.17, 0.048, 0.025), Color("#719b88"))
		"paper":
			room.box(parent, Vector3(0, -0.025, 0), size * Vector3(0.94, 0.13, 0.98), color.darkened(0.08))
			room.box(parent, Vector3(0.015, 0, -0.025), size * Vector3(0.9, 0.13, 0.93), color)
			for index: int in range(3):
				room.box(parent, Vector3(0, 0.011, -0.12 + index * 0.07), Vector3(size.x * 0.52, 0.004, 0.012), color.darkened(0.25))
		_:
			room.box(parent, Vector3.ZERO, size, color)
	MeshBatcher.combine_children(parent)

static func _sphere(room: Node3D, parent: Node3D, position: Vector3, size: Vector3, color: Color) -> void:
	var shape: SphereMesh = SphereMesh.new()
	shape.radius = 0.5
	shape.height = 1.0
	shape.radial_segments = 12
	shape.rings = 6
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = shape
	mesh.material_override = room.material(color)
	mesh.position = position
	mesh.scale = size
	parent.add_child(mesh)

static func _outline(room: Node3D, parent: Node3D, polygon: PackedVector2Array, size: Vector3, color: Color) -> void:
	var tool: SurfaceTool = SurfaceTool.new()
	tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	var indices: PackedInt32Array = Geometry2D.triangulate_polygon(polygon)
	var height: float = size.y * 0.25
	for index: int in range(0, indices.size(), 3):
		var points: Array[Vector3] = []
		for corner: int in range(3):
			var point: Vector2 = polygon[indices[index + corner]]
			points.append(Vector3(point.x * size.x, height, point.y * size.z))
		_triangle(tool, points[0], points[1], points[2], Vector3.UP)
		_triangle(tool, points[2] - Vector3(0, height * 2, 0), points[1] - Vector3(0, height * 2, 0), points[0] - Vector3(0, height * 2, 0), Vector3.DOWN)
	for index: int in range(polygon.size()):
		var from: Vector2 = polygon[index] * Vector2(size.x, size.z)
		var to: Vector2 = polygon[(index + 1) % polygon.size()] * Vector2(size.x, size.z)
		var edge: Vector2 = to - from
		var normal: Vector3 = Vector3(edge.y, 0, -edge.x).normalized()
		var a: Vector3 = Vector3(from.x, -height, from.y)
		var b: Vector3 = Vector3(to.x, -height, to.y)
		var c: Vector3 = b + Vector3(0, height * 2, 0)
		var d: Vector3 = a + Vector3(0, height * 2, 0)
		_triangle(tool, a, c, d, normal)
		_triangle(tool, a, b, c, normal)
	tool.generate_tangents()
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = tool.commit()
	mesh.material_override = room.material(color)
	parent.add_child(mesh)

static func _triangle(tool: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, normal: Vector3) -> void:
	for vertex: Vector3 in [a, b, c]:
		tool.set_normal(normal)
		tool.set_uv(Vector2(vertex.x, vertex.z))
		tool.add_vertex(vertex)
