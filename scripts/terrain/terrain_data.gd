class_name TerrainData
extends RefCounted

## Chunk-addressable terrain model. It has no dependency on rendering or physics.

enum Block { AIR, GRASS, DIRT, STONE }

const CHUNK_SIZE := Vector2i(16, 16)

var width: int
var height: int
var seed: int
var _chunks: Dictionary = {}
var _generated_blocks: Dictionary = {}
var _modified_blocks: Dictionary = {}


func _init(world_width: int, world_height: int, world_seed: int) -> void:
	width = world_width
	height = world_height
	seed = world_seed


func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height


func get_block(cell: Vector2i) -> int:
	if not is_in_bounds(cell):
		return Block.AIR
	var chunk: Dictionary = _chunks.get(_chunk_position(cell), {})
	return chunk.get(_local_position(cell), Block.AIR)


func set_generated_block(cell: Vector2i, block: int) -> void:
	_set_block(cell, block)
	_generated_blocks[cell] = block


func set_block(cell: Vector2i, block: int, track_modification := true) -> bool:
	if not is_in_bounds(cell) or get_block(cell) == block:
		return false
	_set_block(cell, block)
	if track_modification:
		var generated_block: int = _generated_blocks.get(cell, Block.AIR)
		if block == generated_block:
			_modified_blocks.erase(cell)
		else:
			_modified_blocks[cell] = block
	return true


func get_modifications() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for cell: Vector2i in _modified_blocks:
		result.append({"x": cell.x, "y": cell.y, "block": _modified_blocks[cell]})
	return result


func get_modification_count() -> int:
	return _modified_blocks.size()


func apply_modifications(modifications: Array) -> void:
	for entry: Variant in modifications:
		if entry is Dictionary and entry.has("x") and entry.has("y") and entry.has("block"):
			set_block(Vector2i(int(entry.x), int(entry.y)), int(entry.block), true)


func _set_block(cell: Vector2i, block: int) -> void:
	var chunk_position := _chunk_position(cell)
	if not _chunks.has(chunk_position):
		_chunks[chunk_position] = {}
	var chunk: Dictionary = _chunks[chunk_position]
	var local_position := _local_position(cell)
	if block == Block.AIR:
		chunk.erase(local_position)
	else:
		chunk[local_position] = block


func _chunk_position(cell: Vector2i) -> Vector2i:
	return Vector2i(floori(float(cell.x) / CHUNK_SIZE.x), floori(float(cell.y) / CHUNK_SIZE.y))


func _local_position(cell: Vector2i) -> Vector2i:
	return Vector2i(posmod(cell.x, CHUNK_SIZE.x), posmod(cell.y, CHUNK_SIZE.y))
