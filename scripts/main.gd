extends Node2D

@onready var terrain: TerrainWorld = $TerrainWorld
@onready var player: PlayerMovement = $Player
@onready var hud: PrototypeHUD = $PrototypeHUD


func _ready() -> void:
	terrain.player = player
	hud.setup(terrain, player)
	var spawn_cell_x := 12
	player.global_position = Vector2(
		terrain.cell_to_world_center(Vector2i(spawn_cell_x, 0)).x,
		terrain.get_surface_world_y(spawn_cell_x) - 38.0
	)
	var camera := player.get_node("Camera2D") as Camera2D
	camera.limit_left = 0
	camera.limit_right = terrain.data.width * terrain.block_size
	camera.limit_top = 0
	camera.limit_bottom = terrain.data.height * terrain.block_size


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_instance_valid(terrain):
		terrain.save_if_needed(true)
		get_tree().quit()
