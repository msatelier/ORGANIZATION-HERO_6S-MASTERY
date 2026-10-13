class_name PlacementRules
extends RefCounted

static func validate(item: ItemData, rule: ItemPlacementRule, occupied: int, opened: bool, yaw: float = 0.0) -> String:
	if item == null or rule == null:
		return "INVALID_TARGET"
	if item.category not in rule.categories:
		return "WRONG_CATEGORY"
	if not rule.container_id.is_empty() and not opened:
		return "OPEN_CONTAINER_FIRST"
	if occupied >= rule.slots.size():
		return "TARGET_FULL"
	if absf(wrapf(yaw - rule.yaw, -PI, PI)) > rule.angle_tolerance:
		return "WRONG_ORIENTATION"
	return ""
