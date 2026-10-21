class_name PrototypeHUD
extends CanvasLayer

var terrain: TerrainWorld
var player: PlayerMovement
var _save_message := "No changes"
var _refresh_accumulator := 0.0

@onready var info_label: Label = $Panel/Info


func setup(terrain_world: TerrainWorld, player_body: PlayerMovement) -> void:
	terrain = terrain_world
	player = player_body
	terrain.save_completed.connect(_on_save_completed)


func _process(delta: float) -> void:
	if terrain == null or player == null or terrain.data == null:
		return
	_refresh_accumulator += delta
	if _refresh_accumulator < 0.2:
		return
	_refresh_accumulator = 0.0
	var target_cell := terrain.world_to_cell(terrain.get_global_mouse_position())
	var target_distance := player.global_position.distance_to(terrain.get_global_mouse_position())
	var target_state := "IN RANGE" if target_distance <= terrain.mining_range else "OUT OF RANGE"
	info_label.text = (
		"BURNING FURY — TECHNICAL PROTOTYPE\n"
		+ "A/D Move   Space Jump   LMB Mine   RMB/F Melee\n"
		+ "Seed: %d   Position: (%d, %d)   Target: (%d, %d) %s\n"
		+ "Terrain edits: %d   Save: %s   FPS: %d"
	) % [
		terrain.data.seed,
		roundi(player.global_position.x), roundi(player.global_position.y),
		target_cell.x, target_cell.y, target_state,
		terrain.data.get_modification_count(), _save_message,
		Engine.get_frames_per_second(),
	]


func _on_save_completed(succeeded: bool) -> void:
	_save_message = "Saved" if succeeded else "SAVE FAILED"
