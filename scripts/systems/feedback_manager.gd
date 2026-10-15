class_name FeedbackManager
extends Node

var music: AudioStreamPlayer
var brush: AudioStreamPlayer
var effects: Array[AudioStreamPlayer] = []
var clips: Dictionary[String, AudioStreamWAV] = {}
var next_voice: int = 0
var variant_index: int = 0
var haptics_enabled: bool = true
var brush_target: float = 0.0
var brush_gain: float = 0.0
var brush_timer: float = 0.0
var last_clip_key: String = ""

func _ready() -> void:
	for bus_name: String in ["Music", "Effects"]:
		if AudioServer.get_bus_index(bus_name) == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
	_install_limiter()
	music = _player("Music")
	brush = _player("Effects")
	for _index: int in range(3):
		effects.append(_player("Effects"))
	if DisplayServer.get_name() == "headless":
		return
	clips = SoundPalette.create()
	music.stream = clips["ambient"]
	music.volume_db = -40
	music.play()
	create_tween().tween_property(music, "volume_db", 0.0, 0.7)
	brush.stream = clips["brush"]
	brush.volume_db = -60

func _install_limiter() -> void:
	# The audio buses survive replay. Install only once for the combined mix.
	for index: int in range(AudioServer.get_bus_effect_count(0)):
		if AudioServer.get_bus_effect(0, index) is AudioEffectHardLimiter:
			return
	var limiter: AudioEffectHardLimiter = AudioEffectHardLimiter.new()
	limiter.ceiling_db = -1.0
	AudioServer.add_bus_effect(0, limiter)

func _player(bus_name: String) -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = bus_name
	add_child(player)
	return player

func apply_settings(values: Dictionary) -> void:
	for pair: Array in [["Music", "music"], ["Effects", "effects"]]:
		var amount: float = float(values.get(pair[1], 0.5))
		var index: int = AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_mute(index, amount <= 0.001)
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.001, amount)))
	haptics_enabled = values.get("haptics", true)

func play(kind: String, profile: String = "wood") -> void:
	var key: String = kind
	if kind == "place":
		var material_profile: String = profile if profile in SoundPalette.MATERIALS else "wood"
		key = "place_%s_%d" % [material_profile, variant_index]
		variant_index = (variant_index + 1) % 3
	last_clip_key = key
	if not clips.has(key):
		return
	var player: AudioStreamPlayer = effects[next_voice]
	next_voice = (next_voice + 1) % effects.size()
	player.stream = clips[key]
	player.play()
	if haptics_enabled and OS.get_name() in ["Android", "iOS"] and kind != "invalid":
		Input.vibrate_handheld(25)

func cleaning_motion(intensity: float) -> void:
	brush_target = clampf(intensity, 0, 1)
	brush_timer = 0.12 if brush_target > 0 else 0.0

func _process(delta: float) -> void:
	if brush == null or brush.stream == null:
		return
	brush_timer = maxf(0, brush_timer - delta)
	if brush_timer <= 0:
		brush_target = 0.0
	brush_gain = move_toward(brush_gain, brush_target * 0.7, delta * 5.0)
	if brush_gain > 0.005:
		brush.volume_db = linear_to_db(brush_gain)
		if not brush.playing:
			brush.play()
	elif brush.playing:
		brush.stop()

func pause_music(paused: bool) -> void:
	music.stream_paused = paused
	if paused:
		_silence_brush()

func _silence_brush() -> void:
	brush_target = 0
	brush_gain = 0
	brush_timer = 0
	if brush != null:
		brush.stop()

func _exit_tree() -> void:
	stop_all()

func stop_all() -> void:
	_silence_brush()
	if brush != null:
		brush.stream = null
	if music != null:
		music.stop()
		music.stream = null
	for player: AudioStreamPlayer in effects:
		player.stop()
		player.stream = null
	clips.clear()
