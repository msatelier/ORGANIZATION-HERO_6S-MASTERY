class_name TranslationCatalog
extends RefCounted

# Register text Resources after the engine has initialized its resource loaders.
# This also avoids missing generated translations on a clean first import.
static func install() -> void:
	TranslationServer.add_translation(preload("res://localization/es.tres"))
	TranslationServer.add_translation(preload("res://localization/en.tres"))
