class_name FeedbackManager
extends Node

var music: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var clips: Dictionary[String, AudioStreamWAV] = {}
var next_voice: int = 0
var haptics_enabled: bool = true

func _ready() -> void:
	for bus_name: String in ["Music", "Effects"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	for _index: int in range(3):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.bus = "Effects"
		add_child(player)
		effects.append(player)
	if DisplayServer.get_name() == "headless":
		return
	music.stream = _sound(110.0, 6.0, true)
	music.play()
	clips["place"] = _sound(520, 0.13)
	clips["container"] = _sound(240, 0.15)
	clips["collectible"] = _sound(880, 0.35)
	clips["finish"] = _sound(660, 0.5)
	clips["undo"] = _sound(370, 0.1)
	clips["invalid"] = _sound(170, 0.1)
	clips["clean"] = _sound(390, 0.12)

func _sound(frequency: float, duration: float, ambient: bool = false) -> AudioStreamWAV:
	var rate: int = 22050
	var count: int = int(duration * rate)
	var bytes: PackedByteArray = []
	bytes.resize(count * 2)
	for index: int in range(count):
		var time: float = float(index) / rate
		var envelope: float = sin(PI * float(index) / count)
		var wave: float = sin(TAU * frequency * time) * 0.5 + sin(TAU * frequency * 1.5 * time) * 0.2
		if ambient:
			wave += sin(TAU * frequency * 1.25 * time) * 0.17
			envelope = 0.08 + 0.04 * sin(TAU * time / duration)
		else:
			envelope *= exp(-time * 8.0)
		bytes.encode_s16(index * 2, clampi(roundi(wave * envelope * 12000), -32767, 32767))
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = bytes
	if ambient:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = count
	return stream

func apply_settings(values: Dictionary) -> void:
	for pair: Array in [["Music", "music"], ["Effects", "effects"]]:
		var amount: float = float(values.get(pair[1], 0.5))
		var index: int = AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_mute(index, amount <= 0.001)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.001, amount)))
	haptics_enabled = values.get("haptics", true)

func play(kind: String) -> void:
	if not clips.has(kind):
		return
	var player: AudioStreamPlayer = effects[next_voice]
	next_voice = (next_voice + 1) % effects.size()
	player.stream = clips[kind]
	player.play()
	if haptics_enabled and OS.get_name() in ["Android", "iOS"] and kind not in ["invalid", "clean"]:
		Input.vibrate_handheld(25)

func pause_music(paused: bool) -> void:
	music.stream_paused = paused

func _exit_tree() -> void:
	stop_all()

func stop_all() -> void:
	if music != null:
		music.stop()
		music.stream = null
	for player: AudioStreamPlayer in effects:
		player.stop()
		player.stream = null
	clips.clear()
