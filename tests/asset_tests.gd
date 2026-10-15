extends SceneTree

var checks: int = 0
var failures: int = 0

func _initialize() -> void:
	call_deferred("_run")

func check(condition: bool, description: String) -> void:
	checks += 1
	if condition:
		print("PASS: " + description)
	else:
		failures += 1
		push_error("FAIL: " + description)

func _run() -> void:
	var palette: Dictionary[String, AudioStreamWAV] = SoundPalette.create()
	for key: String in palette:
		var clip: AudioStreamWAV = palette[key]
		var samples: PackedByteArray = clip.data
		var peak: int = 0
		var total: float = 0.0
		var count: int = samples.size() / 2
		for sample: int in range(count):
			var value: int = samples.decode_s16(sample * 2)
			peak = maxi(peak, absi(value))
			total += value
		var boundaries: bool = key == "music" or (samples.decode_s16(0) == 0 and samples.decode_s16((count - 1) * 2) == 0)
		check(clip.format == AudioStreamWAV.FORMAT_16_BITS and clip.mix_rate == 22050 and not clip.stereo and count > 0 and peak > 0 and peak < 20000 and absf(total / count) < 655 and boundaries, "PCM format, headroom, DC and boundary safety: " + key)
	check(palette["place_fabric_0"].data != palette["place_paper_0"].data and palette["place_plastic_0"].data != palette["place_wood_0"].data, "different materials have different waveforms")
	check(palette["place_fabric_0"].data != palette["place_fabric_1"].data, "repeated material has a distinct variant")
	for key: String in ["music", "brush"]:
		var clip: AudioStreamWAV = palette[key]
		var last: int = clip.data.decode_s16(clip.data.size() - 2)
		check(clip.loop_mode == AudioStreamWAV.LOOP_FORWARD and clip.loop_end == clip.data.size() / 2 and absi(last - clip.data.decode_s16(0)) < 400, "loop extent and seam: " + key)
	check(is_equal_approx(palette["music"].get_length(), 40.0), "music contains the complete 16 bar composition")

	var parent: Node3D = Node3D.new()
	var material: StandardMaterial3D = StandardMaterial3D.new()
	for position: float in [-1.0, 1.0]:
		var mesh: MeshInstance3D = MeshInstance3D.new()
		var shape: BoxMesh = BoxMesh.new()
		shape.size = Vector3(0.8, 0.2, 0.5)
		mesh.mesh = shape
		mesh.material_override = material
		mesh.position.x = position
		parent.add_child(mesh)
	var pad: MeshInstance3D = MeshInstance3D.new()
	pad.mesh = BoxMesh.new()
	pad.material_override = material
	pad.position.x = 3
	parent.add_child(pad)
	var collider: StaticBody3D = StaticBody3D.new()
	parent.add_child(collider)
	MeshBatcher.combine_children(parent, [pad])
	var combined: MeshInstance3D = parent.get_child(2)
	check(parent.get_child_count() == 3 and pad.get_parent() == parent and pad.position.x == 3 and collider.get_parent() == parent, "mesh batching preserves interactive pad and collider")
	check(combined.mesh.get_aabb().size.is_equal_approx(Vector3(2.8, 0.2, 0.5)) and combined.material_override == material, "batching preserves transformed geometry bounds and shared material")
	parent.free()
	_write_preview(palette)
	print("ASSET RESULT: %d checks, %d failures" % [checks, failures])
	quit(1 if failures > 0 else 0)

func _write_preview(palette: Dictionary[String, AudioStreamWAV]) -> void:
	# Five placements, door, moving cloth, keepsake and completion, with silence between.
	var bytes: PackedByteArray = []
	var silence: PackedByteArray = []
	silence.resize(roundi(0.25 * SoundPalette.RATE) * 2)
	silence.fill(0)
	for key: String in ["place_fabric_0", "place_paper_0", "place_plastic_0", "place_soft_0", "place_wood_0", "container_open", "brush", "collectible", "finish"]:
		bytes.append_array(palette[key].data)
		bytes.append_array(silence)
	var preview: AudioStreamWAV = AudioStreamWAV.new()
	preview.format = AudioStreamWAV.FORMAT_16_BITS
	preview.mix_rate = 22050
	preview.data = bytes
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://build/audio"))
	check(bytes.size() % 2 == 0 and preview.save_to_wav("res://build/audio/material-preview.wav") == OK, "material sound preview keeps PCM alignment and exports for human listening")
