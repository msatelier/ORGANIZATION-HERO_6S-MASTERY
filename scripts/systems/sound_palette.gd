class_name SoundPalette
extends RefCounted

const RATE: int = 22050
const MATERIALS: Array[String] = ["fabric", "paper", "plastic", "soft", "wood"]

static func create() -> Dictionary[String, AudioStreamWAV]:
	var palette: Dictionary[String, AudioStreamWAV] = {}
	for profile: String in MATERIALS:
		for variant: int in range(3):
			palette["place_%s_%d" % [profile, variant]] = _foley(profile, variant)
	palette["container_open"] = _foley("open", 0)
	palette["container_close"] = _foley("wood", 1)
	palette["undo"] = _foley("soft", 2)
	palette["invalid"] = _chime(PackedFloat32Array([146.0]), 0.16, 0.18)
	palette["collectible"] = _chime(PackedFloat32Array([440.0, 550.0, 660.0]), 0.7, 0.28)
	palette["finish"] = _chime(PackedFloat32Array([330.0, 440.0, 550.0, 660.0]), 1.15, 0.25)
	palette["brush"] = _foley("brush", 0)
	var music: AudioStreamWAV = preload("res://assets/audio/bedroom_theme.wav").duplicate()
	music.loop_mode = AudioStreamWAV.LOOP_FORWARD
	music.loop_begin = 0
	music.loop_end = music.data.size() / 2
	palette["music"] = music
	return palette

static func _foley(profile: String, variant: int) -> AudioStreamWAV:
	var duration: float = 1.0 if profile == "brush" else (0.42 if profile == "open" else 0.26)
	var count: int = roundi(duration * RATE)
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 601 + variant * 97 + profile.hash()
	var low: float = 0.0
	var pitch: float = 1.0 + variant * 0.045
	for index: int in range(count):
		var time: float = float(index) / RATE
		var noise: float = random.randf_range(-1, 1)
		low = lerpf(low, noise, 0.08 if profile in ["fabric", "soft", "brush"] else 0.25)
		var wave: float = 0.0
		var envelope: float = minf(1.0, time / 0.007) * minf(1.0, (duration - time) / 0.025)
		match profile:
			"fabric", "brush":
				wave = low * (0.6 + 0.3 * sin(TAU * time * 17))
				if profile != "brush":
					envelope *= exp(-time * 7.0)
			"paper":
				wave = (noise - low) * (0.12 + 0.18 * pow(sin(TAU * time * 23), 2))
				envelope *= exp(-time * 10.0)
			"plastic":
				wave = sin(TAU * 470 * pitch * time) * 0.25 + sin(TAU * 810 * pitch * time) * 0.12 + low * 0.23
				envelope *= exp(-time * 19.0)
			"soft":
				wave = low * 0.7 + sin(TAU * 95 * pitch * time) * 0.15
				envelope *= exp(-time * 16.0)
			"open":
				wave = sin(TAU * (155 * time + 50 * time * time)) * 0.12 + low * 0.26
				envelope *= pow(sin(PI * time / duration), 2)
			_:
				wave = sin(TAU * 145 * pitch * time) * 0.35 + sin(TAU * 280 * pitch * time) * 0.13 + low * 0.15
				envelope *= exp(-time * 21.0)
		bytes.encode_s16(index * 2, roundi(clampf(wave * envelope * 0.8, -0.8, 0.8) * 32767))
	# Exact silence at both ends prevents boundary clicks, including the brush loop.
	bytes.encode_s16(0, 0)
	bytes.encode_s16((count - 1) * 2, 0)
	return _stream(bytes, profile == "brush")

static func _chime(notes: PackedFloat32Array, duration: float, gain: float) -> AudioStreamWAV:
	var count: int = roundi(duration * RATE)
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	for index: int in range(count):
		var time: float = float(index) / RATE
		var wave: float = 0.0
		for note: int in range(notes.size()):
			var age: float = time - note * 0.09
			if age < 0:
				continue
			var envelope: float = minf(1, age / 0.01) * exp(-age * 7.0)
			wave += sin(TAU * notes[note] * age) * envelope / notes.size()
		var end: float = minf(1, (duration - time) / 0.04)
		bytes.encode_s16(index * 2, roundi(wave * gain * end * 32767))
	bytes.encode_s16((count - 1) * 2, 0)
	return _stream(bytes)

static func _stream(bytes: PackedByteArray, looping: bool = false) -> AudioStreamWAV:
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	if looping:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = bytes.size() / 2
	return stream
