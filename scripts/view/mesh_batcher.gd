class_name MeshBatcher
extends RefCounted

static func combine_children(parent: Node3D, preserve: Array[Node3D] = []) -> void:
	# Merge only siblings that share a material and move together with their parent.
	# Colliders, labels, doors and interactive pads remain independent.
	var groups: Dictionary[Material, Array] = {}
	for child: Node in parent.get_children():
		if child is not MeshInstance3D or child in preserve or not child.visible or child.mesh == null or child.mesh.get_surface_count() != 1:
			continue
		var mesh: MeshInstance3D = child
		for surface: int in range(mesh.mesh.get_surface_count()):
			var appearance: Material = mesh.get_active_material(surface)
			if not groups.has(appearance):
				groups[appearance] = []
			groups[appearance].append({"node": mesh, "surface": surface})
	var originals: Array[MeshInstance3D] = []
	for appearance: Material in groups:
		var entries: Array = groups[appearance]
		if entries.size() < 2:
			continue
		var tool: SurfaceTool = SurfaceTool.new()
		tool.begin(Mesh.PRIMITIVE_TRIANGLES)
		for entry: Dictionary in entries:
			var original: MeshInstance3D = entry["node"]
			tool.append_from(original.mesh, entry["surface"], original.transform)
			if original not in originals:
				originals.append(original)
		var combined: MeshInstance3D = MeshInstance3D.new()
		combined.mesh = tool.commit()
		combined.material_override = appearance
		parent.add_child(combined)
	for original: MeshInstance3D in originals:
		original.free()
