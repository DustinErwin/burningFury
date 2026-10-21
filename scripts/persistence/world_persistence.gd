class_name WorldPersistence
extends RefCounted

const SAVE_PATH := "user://burning_fury_world.json"
const SAVE_VERSION := 1


static func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("Could not open world save: %s" % FileAccess.get_open_error())
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if parsed is not Dictionary or int(parsed.get("version", -1)) != SAVE_VERSION:
		push_warning("World save is invalid or uses an unsupported version.")
		return {}
	return parsed as Dictionary


static func save_world(data: TerrainData) -> bool:
	var payload := {
		"version": SAVE_VERSION,
		"seed": data.seed,
		"width": data.width,
		"height": data.height,
		"modifications": data.get_modifications(),
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Could not write world save: %s" % FileAccess.get_open_error())
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	return true
