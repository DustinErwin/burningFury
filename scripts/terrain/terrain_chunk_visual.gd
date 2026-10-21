class_name TerrainChunkVisual
extends Node2D

## Draws one small terrain region so Godot can cull off-screen chunks.
## Adjacent blocks of the same material are merged into one rectangle.

const BLOCK_COLORS := {
	TerrainData.Block.GRASS: Color("#4fba55"),
	TerrainData.Block.DIRT: Color("#8a5535"),
	TerrainData.Block.STONE: Color("#68717a"),
}

var terrain_data: TerrainData
var chunk_cell_origin: Vector2i
var chunk_size: Vector2i
var block_size: int


func setup(data: TerrainData, cell_origin: Vector2i, cells_per_chunk: Vector2i, size: int) -> void:
	terrain_data = data
	chunk_cell_origin = cell_origin
	chunk_size = cells_per_chunk
	block_size = size
	position = Vector2(chunk_cell_origin) * block_size
	queue_redraw()


func _draw() -> void:
	if terrain_data == null:
		return
	var max_x := mini(chunk_cell_origin.x + chunk_size.x, terrain_data.width)
	var max_y := mini(chunk_cell_origin.y + chunk_size.y, terrain_data.height)
	for world_y in range(chunk_cell_origin.y, max_y):
		var run_start := chunk_cell_origin.x
		var run_block := terrain_data.get_block(Vector2i(run_start, world_y))
		for world_x in range(chunk_cell_origin.x + 1, max_x + 1):
			var block := TerrainData.Block.AIR
			if world_x < max_x:
				block = terrain_data.get_block(Vector2i(world_x, world_y))
			if block != run_block:
				_draw_run(run_start, world_x, world_y, run_block)
				run_start = world_x
				run_block = block


func _draw_run(start_x: int, end_x: int, world_y: int, block: int) -> void:
	if block == TerrainData.Block.AIR:
		return
	var local_x := (start_x - chunk_cell_origin.x) * block_size
	var local_y := (world_y - chunk_cell_origin.y) * block_size
	var width := (end_x - start_x) * block_size
	var rect := Rect2(local_x, local_y, width, block_size)
	draw_rect(rect, BLOCK_COLORS[block])
	draw_line(rect.position, rect.position + Vector2(width, 0), Color(1, 1, 1, 0.08), 1.0)
