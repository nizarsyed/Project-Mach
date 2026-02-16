extends Node

enum QualityTier { MOBILE, LOW, MEDIUM, HIGH }

var current_tier: QualityTier = QualityTier.HIGH

func _ready():
	_detect_platform()
	_apply_tier_settings()

func _detect_platform():
	if OS.has_feature("android") or OS.has_feature("ios"):
		current_tier = QualityTier.MOBILE
	else:
		current_tier = QualityTier.HIGH
	
	print("PlatformManager: Tier set to ", QualityTier.keys()[current_tier])

func _apply_tier_settings():
	var viewport_rid = get_viewport().get_viewport_rid()
	match current_tier:
		QualityTier.MOBILE:
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_DISABLED)
		QualityTier.HIGH:
			RenderingServer.viewport_set_msaa_3d(viewport_rid, RenderingServer.VIEWPORT_MSAA_4X)

func is_mobile() -> bool:
	return current_tier == QualityTier.MOBILE
