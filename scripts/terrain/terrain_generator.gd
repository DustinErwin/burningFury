class_name TerrainGenerator
extends RefCounted

## Creates the reproducible base layer. Saved edits are applied afterward.


static func generate(width: int, height: int, world_seed: int) -> TerrainData:
	var data := TerrainData.new(width, height, world_seed)
	var noise := FastNoiseLite.new()
	noise.seed = world_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.035
	noise.fractal_octaves = 3
	noise.fractal_gain = 0.45

	var base_surface := height / 3
	for x in range(width):
		var surface := base_surface + roundi(noise.get_noise_1d(float(x)) * 8.0)
		surface = clampi(surface, 8, height - 20)
		for y in range(surface, height):
			var block := TerrainData.Block.STONE
			if y == surface:
				block = TerrainData.Block.GRASS
			elif y < surface + 5:
				block = TerrainData.Block.DIRT
			data.set_generated_block(Vector2i(x, y), block)
	return data
