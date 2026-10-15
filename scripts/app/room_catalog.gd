class_name RoomCatalog
extends RefCounted

const BEDROOM: LevelData = preload("res://resources/levels/bedroom.tres")
const KITCHEN: LevelData = preload("res://resources/levels/kitchen.tres")

static func levels() -> Array[LevelData]:
	return [BEDROOM, KITCHEN]

static func find(id: String) -> LevelData:
	for level: LevelData in levels():
		if level.id == id:
			return level
	return null

static func create_view(level: LevelData) -> RoomView:
	return KitchenView.new(level) if level.id == KITCHEN.id else BedroomView.new(level)

static func save_path(directory: String, level: LevelData) -> String:
	# Keep the original bedroom save in place; no destructive migration.
	return directory if level.id == BEDROOM.id else directory.path_join("rooms").path_join(level.id)
