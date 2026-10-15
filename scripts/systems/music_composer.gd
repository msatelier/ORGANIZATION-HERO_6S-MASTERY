class_name MusicComposer
extends RefCounted

const RATE: int = 22050
const BPM: int = 96
const BARS: int = 16

static func render() -> AudioStreamWAV:
	# Original 4/4 theme: warm plucked melody, broken chords, bass and soft percussion.
	var beat_seconds: float = 60.0 / BPM
	var count: int = roundi(BARS * 4 * beat_seconds * RATE)
	var mix: PackedFloat32Array = []
	mix.resize(count)
	mix.fill(0)
	var chords: Array[Array] = [[48, 64, 67, 72], [45, 60, 64, 69], [41, 60, 65, 69], [43, 62, 67, 71]]
	var melody: Array[Array] = [
		[76, -1, 79, 76, 74, -1, 72, -1],
		[74, -1, 76, 79, 77, 76, 74, -1],
		[72, -1, 76, -1, 79, 81, 79, -1],
		[77, -1, 76, 74, 72, -1, 74, -1]
	]
	for bar: int in range(BARS):
		var chord: Array = chords[bar % 4]
		var phrase: Array = melody[bar % 4]
		for step: int in range(8):
			var beat: float = bar * 4 + step * 0.5
			var note: int = phrase[step]
			if note >= 0:
				var variation: int = 12 if bar in [10, 14] and step == 4 else 0
				_note(mix, note + variation, beat * beat_seconds, 0.52 * beat_seconds, "lead", 0.19 if step % 2 == 0 else 0.16)
			_note(mix, chord[1 + step % 3], (beat + 0.05) * beat_seconds, 0.4 * beat_seconds, "chord", 0.06)
			_percussion(mix, beat * beat_seconds, "shaker", 0.025 if step % 2 else 0.018, bar * 8 + step)
		for beat: int in [0, 2]:
			_note(mix, chord[0], (bar * 4 + beat) * beat_seconds, 1.1 * beat_seconds, "bass", 0.12)
			_percussion(mix, (bar * 4 + beat) * beat_seconds, "kick", 0.10, bar * 4 + beat)
		for beat: int in [1, 3]:
			_percussion(mix, (bar * 4 + beat) * beat_seconds, "brush", 0.045, bar * 4 + beat)
	var peak: float = 0.001
	for sample: float in mix:
		peak = maxf(peak, absf(sample))
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	var gain: float = 0.40 / peak
	for index: int in range(count):
		bytes.encode_s16(index * 2, roundi(clampf(mix[index] * gain, -0.4, 0.4) * 32767))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = count
	return stream

static func _note(mix: PackedFloat32Array, midi: int, start: float, duration: float, voice: String, velocity: float) -> void:
	var frequency: float = 440.0 * pow(2, float(midi - 69) / 12.0)
	var begin: int = roundi(start * RATE)
	var length: int = roundi(duration * RATE)
	for index: int in range(length):
		var time: float = float(index) / RATE
		var envelope: float = minf(1, time / 0.006) * minf(1, (duration - time) / 0.035)
		var fundamental: float = sin(TAU * frequency * time)
		var wave: float
		match voice:
			"bass":
				wave = fundamental * 0.85 + sin(TAU * frequency * 2 * time) * 0.1
				envelope *= exp(-time * 4.0)
			"chord":
				wave = fundamental * 0.75 + sin(TAU * frequency * 2 * time) * 0.15
				envelope *= exp(-time * 12.0)
			_:
				wave = fundamental * 0.72 + sin(TAU * frequency * 2 * time) * 0.18 + sin(TAU * frequency * 3 * time) * 0.04
				envelope *= exp(-time * 8.0)
		var destination: int = (begin + index) % mix.size()
		mix[destination] += wave * envelope * velocity

static func _percussion(mix: PackedFloat32Array, start: float, voice: String, velocity: float, seed_value: int) -> void:
	var random: RandomNumberGenerator = RandomNumberGenerator.new()
	random.seed = 606 + seed_value
	var duration: float = 0.11 if voice == "kick" else 0.045
	var length: int = roundi(duration * RATE)
	var begin: int = roundi(start * RATE)
	var filtered: float = 0.0
	for index: int in range(length):
		var time: float = float(index) / RATE
		var noise: float = random.randf_range(-1, 1)
		filtered = lerpf(filtered, noise, 0.12)
		var wave: float = noise - filtered if voice == "shaker" else filtered
		if voice == "kick":
			wave = sin(TAU * (100 * time - 150 * time * time))
		var envelope: float = minf(1, time / 0.003) * minf(1, (duration - time) / 0.015) * exp(-time * 35)
		mix[(begin + index) % mix.size()] += wave * envelope * velocity
