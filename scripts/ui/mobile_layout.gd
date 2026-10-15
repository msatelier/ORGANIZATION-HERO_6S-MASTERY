class_name MobileLayout
extends RefCounted

static func calculate(viewport_size: Vector2, safe_area: Rect2) -> Dictionary[String, Rect2]:
	var area: Rect2 = safe_area.intersection(Rect2(Vector2.ZERO, viewport_size)).grow(-12)
	var portrait: bool = viewport_size.x < viewport_size.y
	var result: Dictionary[String, Rect2] = {}
	result["top"] = Rect2(area.position, Vector2(area.size.x, 68))
	if portrait:
		result["toolbar"] = Rect2(Vector2(area.position.x, area.end.y - 188), Vector2(area.size.x, 188))
		result["goals"] = Rect2(Vector2(area.position.x, result["toolbar"].position.y - 160), Vector2(area.size.x, 152))
		result["toast"] = Rect2(Vector2(area.position.x + 4, result["goals"].position.y - 42), Vector2(area.size.x - 8, 36))
		result["play"] = Rect2(Vector2(area.position.x, result["top"].end.y + 12), Vector2(area.size.x, result["toast"].position.y - result["top"].end.y - 20))
	else:
		var sidebar_width: float = 228
		var right: float = area.end.x - sidebar_width
		var top: float = result["top"].end.y + 8
		var goal_height: float = minf(152, area.end.y - top - 188)
		result["goals"] = Rect2(Vector2(right, top), Vector2(sidebar_width, goal_height))
		result["toolbar"] = Rect2(Vector2(right, top + goal_height + 8), Vector2(sidebar_width, area.end.y - top - goal_height - 8))
		result["toast"] = Rect2(Vector2(area.position.x + 4, area.end.y - 36), Vector2(area.size.x - sidebar_width - 20, 36))
		result["play"] = Rect2(Vector2(area.position.x, top), Vector2(area.size.x - sidebar_width - 12, result["toast"].position.y - top - 8))
	result["comparison"] = Rect2(Vector2(area.position.x, area.end.y - 80), Vector2(area.size.x, 80))
	var result_size: Vector2 = Vector2(minf(520, area.size.x), minf(400, area.size.y))
	result["results"] = Rect2(area.get_center() - result_size * 0.5, result_size)
	var settings_size: Vector2 = Vector2(minf(430, area.size.x), minf(540, area.size.y))
	result["settings"] = Rect2(area.get_center() - settings_size * 0.5, settings_size)
	return result
