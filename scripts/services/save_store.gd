class_name SaveStore
extends RefCounted

var directory: String
var locked: bool = false
var status: String = ""

func _init(save_directory: String = "user://") -> void:
	directory = save_directory

func load_session(level: LevelData) -> GameSession:
	var fresh: GameSession = GameSession.new(level)
	for suffix: String in ["progress.json", "progress.json.bak", "progress.json.tmp"]:
		var path: String = directory.path_join(suffix)
		if not FileAccess.file_exists(path):
			continue
		var decoded: Variant = _decode(FileAccess.get_file_as_string(path))
		if not decoded is Dictionary:
			status = "SAVE_RECOVERED"
			continue
		var schema: Variant = decoded.get("schema_version", 0)
		var content: Variant = decoded.get("content_version", 0)
		var stored_id: Variant = decoded.get("level_id")
		var newer_schema: bool = (schema is int or schema is float) and schema > 1
		var newer_content: bool = stored_id is String and stored_id == level.id and (content is int or content is float) and content > level.content_version
		if suffix == "progress.json" and (newer_schema or newer_content):
			locked = true
			status = "SAVE_NEWER"
			return fresh
		if fresh.restore(decoded):
			status = "SAVE_RECOVERED" if suffix != "progress.json" else "SAVE_LOADED"
			return fresh
		status = "SAVE_RECOVERED"
	return fresh

func save(session: GameSession) -> Error:
	if locked:
		return ERR_UNAVAILABLE
	var absolute_dir: String = ProjectSettings.globalize_path(directory)
	var result: Error = DirAccess.make_dir_recursive_absolute(absolute_dir)
	if result != OK:
		return result
	var path: String = directory.path_join("progress.json")
	var temporary: String = path + ".tmp"
	var backup: String = path + ".bak"
	var file: FileAccess = FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(session.snapshot()))
	file.flush()
	result = file.get_error()
	file.close()
	if result != OK:
		return result
	var check: GameSession = GameSession.new(session.level)
	var written: Variant = _decode(FileAccess.get_file_as_string(temporary))
	if not written is Dictionary or not check.restore(written):
		return ERR_FILE_CORRUPT
	if FileAccess.file_exists(path):
		var previous: Variant = _decode(FileAccess.get_file_as_string(path))
		if previous is Dictionary and check.restore(previous):
			result = DirAccess.copy_absolute(ProjectSettings.globalize_path(path), ProjectSettings.globalize_path(backup))
			if result != OK:
				return result
		result = DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		if result != OK:
			return result
	# Replacement is backed up; portability of atomic rename is not assumed.
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path))

func _decode(text: String) -> Variant:
	var parser: JSON = JSON.new()
	return parser.data if parser.parse(text) == OK else null
