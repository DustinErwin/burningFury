class_name TerrainFeedback
extends Node2D

## Transient interaction visuals. No gameplay or terrain state is stored here.

const TARGET_VALID := Color("#84f58e")
const TARGET_INVALID := Color("#f06b62")
const CRACK_COLOR := Color(0.12, 0.10, 0.09, 0.82)

var terrain: TerrainWorld
var _damage_ratios: Dictionary = {}
var _bursts: Array[Dictionary] = []


func setup(terrain_world: TerrainWorld) -> void:
	terrain = terrain_world
	terrain.block_damaged.connect(_on_block_damaged)
	terrain.block_hit.connect(_on_block_hit)
	terrain.terrain_changed.connect(_on_terrain_changed)
	queue_redraw()


func _process(delta: float) -> void:
	for index in range(_bursts.size() - 1, -1, -1):
		_bursts[index].time = float(_bursts[index].time) - delta
		if float(_bursts[index].time) <= 0.0:
			_bursts.remove_at(index)
	queue_redraw()


func _draw() -> void:
	if terrain == null or terrain.data == null:
		return
	_draw_mining_range()
	_draw_target()
	_draw_cracks()
	_draw_bursts()


func _draw_mining_range() -> void:
	if terrain.player == null:
		return
	var player_position := to_local(terrain.player.global_position)
	draw_arc(player_position, terrain.mining_range, 0.0, TAU, 64, Color(1, 1, 1, 0.10), 1.5)


func _draw_target() -> void:
	if terrain.player == null:
		return
	var mouse_position := get_global_mouse_position()
	var cell := terrain.world_to_cell(mouse_position)
	if not terrain.data.is_in_bounds(cell):
		return
	var in_range := terrain.player.global_position.distance_to(mouse_position) <= terrain.mining_range
	var has_block := terrain.data.get_block(cell) != TerrainData.Block.AIR
	var color := TARGET_VALID if in_range and has_block else TARGET_INVALID
	var rect := Rect2(Vector2(cell) * terrain.block_size + Vector2.ONE, Vector2.ONE * (terrain.block_size - 2))
	draw_rect(rect, Color(color, 0.12), true)
	draw_rect(rect, color, false, 2.0)


func _draw_cracks() -> void:
	for cell: Vector2i in _damage_ratios:
		if terrain.data.get_block(cell) == TerrainData.Block.AIR:
			continue
		var ratio: float = _damage_ratios[cell]
		var center := (Vector2(cell) + Vector2(0.5, 0.5)) * terrain.block_size
		var radius := terrain.block_size * (0.18 + ratio * 0.18)
		for direction in [Vector2(-1, -0.6), Vector2(0.8, -1), Vector2(1, 0.35), Vector2(-0.4, 1)]:
			var endpoint: Vector2 = center + direction.normalized() * radius
			draw_line(center, endpoint, CRACK_COLOR, 1.5 + ratio)


func _draw_bursts() -> void:
	for burst: Dictionary in _bursts:
		var life: float = float(burst.time) / float(burst.duration)
		var center: Vector2 = burst.position
		var radius := lerpf(4.0, 20.0, 1.0 - life)
		for index in range(8):
			var direction := Vector2.from_angle(float(index) * TAU / 8.0)
			draw_line(center + direction * radius * 0.35, center + direction * radius, Color(1.0, 0.88, 0.48, life), 2.0)


func _on_block_damaged(cell: Vector2i, damage_ratio: float) -> void:
	_damage_ratios[cell] = damage_ratio


func _on_block_hit(cell: Vector2i) -> void:
	_add_burst(cell)


func _on_terrain_changed(cell: Vector2i) -> void:
	_damage_ratios.erase(cell)
	_add_burst(cell)


func _add_burst(cell: Vector2i) -> void:
	_bursts.append({
		"position": (Vector2(cell) + Vector2(0.5, 0.5)) * terrain.block_size,
		"time": 0.20,
		"duration": 0.20,
	})
