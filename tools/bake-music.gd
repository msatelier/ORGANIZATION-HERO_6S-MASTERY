extends SceneTree

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/audio"))
	var theme: AudioStreamWAV = MusicComposer.render()
	var result: Error = theme.save_to_wav("res://assets/audio/bedroom_theme.wav")
	print("MUSIC BAKE: %d BPM, %d bars, %.1f seconds, result %d" % [MusicComposer.BPM, MusicComposer.BARS, theme.get_length(), result])
	quit(0 if result == OK else 1)
