class_name TerrainRenderer
extends Node2D

## Chunk-cullable placeholder visuals and one shared StaticBody2D.

var terrain_data: TerrainData
var block_size := 24
var _collision_body: StaticBody2D
var _chunk_visuals: Dictionary = {}


func setup(data: TerrainData, size: int) -> void:
	terrain_data = data
	block_size = size
	_collision_body = StaticBody2D.new()
	_collision_body.name = "TerrainCollision"
	add_child(_collision_body)
	_create_chunk_visuals()
	_rebuild_collision()


func refresh(changed_cell := Vector2i(-1, -1)) -> void:
	if terrain_data.is_in_bounds(changed_cell):
		var chunk_position := Vector2i(
			changed_cell.x / TerrainData.CHUNK_SIZE.x,
			changed_cell.y / TerrainData.CHUNK_SIZE.y
		)
		var visual := _chunk_visuals.get(chunk_position) as TerrainChunkVisual
		if visual != null:
			visual.queue_redraw()
	else:
		for visual: TerrainChunkVisual in _chunk_visuals.values():
			visual.queue_redraw()
	_rebuild_collision()


func _create_chunk_visuals() -> void:
	var chunk_columns := ceili(float(terrain_data.width) / TerrainData.CHUNK_SIZE.x)
	var chunk_rows := ceili(float(terrain_data.height) / TerrainData.CHUNK_SIZE.y)
	for chunk_y in range(chunk_rows):
		for chunk_x in range(chunk_columns):
			var chunk_position := Vector2i(chunk_x, chunk_y)
			var visual := TerrainChunkVisual.new()
			visual.name = "Chunk_%d_%d" % [chunk_x, chunk_y]
			add_child(visual)
			visual.setup(
				terrain_data,
				chunk_position * TerrainData.CHUNK_SIZE,
				TerrainData.CHUNK_SIZE,
				block_size
			)
			_chunk_visuals[chunk_position] = visual


func _rebuild_collision() -> void:
	if _collision_body == null:
		return
	for child in _collision_body.get_children():
		child.queue_free()

	for y in range(terrain_data.height):
		var run_start := -1
		for x in range(terrain_data.width + 1):
			var solid := x < terrain_data.width and terrain_data.get_block(Vector2i(x, y)) != TerrainData.Block.AIR
			if solid and run_start == -1:
				run_start = x
			elif not solid and run_start != -1:
				_add_collision_run(run_start, x, y)
				run_start = -1


func _add_collision_run(start_x: int, end_x: int, y: int) -> void:
	var run_width := (end_x - start_x) * block_size
	var shape := RectangleShape2D.new()
	shape.size = Vector2(run_width, block_size)
	var collision_shape := CollisionShape2D.new()
	collision_shape.shape = shape
	collision_shape.position = Vector2(start_x * block_size + run_width * 0.5, y * block_size + block_size * 0.5)
	_collision_body.add_child(collision_shape)
