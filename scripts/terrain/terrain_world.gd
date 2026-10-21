class_name TerrainWorld
extends Node2D

signal terrain_changed(cell: Vector2i)
signal block_damaged(cell: Vector2i, damage_ratio: float)
signal block_hit(cell: Vector2i)
signal save_completed(succeeded: bool)

@export var world_seed := 1847
@export var world_width := 256
@export var world_height := 96
@export var block_size := 24
@export var mining_range := 150.0

var data: TerrainData
var player: CharacterBody2D
var _renderer: TerrainRenderer
var _feedback: TerrainFeedback
var _block_damage: Dictionary = {}
var _dirty := false


func _ready() -> void:
	add_to_group("terrain_world")
	var saved := WorldPersistence.load_save()
	var generation_seed := int(saved.get("seed", world_seed))
	var generation_width := int(saved.get("width", world_width))
	var generation_height := int(saved.get("height", world_height))
	data = TerrainGenerator.generate(generation_width, generation_height, generation_seed)
	var saved_modifications: Array = saved.get("modifications", [])
	data.apply_modifications(saved_modifications)

	_renderer = TerrainRenderer.new()
	_renderer.name = "TerrainRenderer"
	add_child(_renderer)
	_renderer.setup(data, block_size)
	_feedback = TerrainFeedback.new()
	_feedback.name = "TerrainFeedback"
	add_child(_feedback)
	_feedback.setup(self)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mine"):
		try_mine_at(get_global_mouse_position())


func try_mine_at(world_position: Vector2) -> bool:
	if player == null or player.global_position.distance_to(world_position) > mining_range:
		return false
	return remove_block(world_to_cell(world_position))


func remove_block(cell: Vector2i) -> bool:
	if data == null or data.get_block(cell) == TerrainData.Block.AIR:
		return false
	_block_damage.erase(cell)
	if not data.set_block(cell, TerrainData.Block.AIR):
		return false
	_after_terrain_changed(cell)
	return true


func damage_block(cell: Vector2i, damage: int) -> bool:
	var block := data.get_block(cell)
	if block == TerrainData.Block.AIR:
		return false
	var durability := 2 if block == TerrainData.Block.STONE else 1
	var accumulated: int = int(_block_damage.get(cell, 0)) + damage
	block_hit.emit(cell)
	if accumulated >= durability:
		return remove_block(cell)
	_block_damage[cell] = accumulated
	block_damaged.emit(cell, float(accumulated) / float(durability))
	return true


func damage_cells_in_rect(world_rect: Rect2, damage: int) -> int:
	var first := world_to_cell(world_rect.position)
	var last := world_to_cell(world_rect.end - Vector2.ONE)
	var hits := 0
	for y in range(first.y, last.y + 1):
		for x in range(first.x, last.x + 1):
			if damage_block(Vector2i(x, y), damage):
				hits += 1
	return hits


func world_to_cell(world_position: Vector2) -> Vector2i:
	var local := to_local(world_position)
	return Vector2i(floori(local.x / block_size), floori(local.y / block_size))


func cell_to_world_center(cell: Vector2i) -> Vector2:
	return to_global((Vector2(cell) + Vector2(0.5, 0.5)) * block_size)


func get_surface_world_y(x_cell: int) -> float:
	for y in range(data.height):
		if data.get_block(Vector2i(clampi(x_cell, 0, data.width - 1), y)) != TerrainData.Block.AIR:
			return to_global(Vector2(0, y * block_size)).y
	return to_global(Vector2(0, data.height * block_size)).y


func save_if_needed(force := false) -> void:
	if force or _dirty:
		var succeeded := WorldPersistence.save_world(data)
		if succeeded:
			_dirty = false
		save_completed.emit(succeeded)


func _after_terrain_changed(cell: Vector2i) -> void:
	_dirty = true
	_renderer.refresh(cell)
	terrain_changed.emit(cell)
	# Persist immediately for a robust prototype; later this can become debounced.
	save_if_needed()
