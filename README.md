# Burning Fury

A Godot 4 prototype for a persistent, destructible 2D martial-arts sandbox.

## Run

Open `project.godot` in Godot 4.7 and press **F6/F5** to run the main scene/project.

## Controls

- **A / D**: Move
- **Space**: Jump
- **Left mouse**: Remove a block within reach
- **Right mouse / F**: Melee attack terrain in the facing direction

The world is generated deterministically and terrain edits are saved to
`user://burning_fury_world.json`. To start a fresh world, delete that file from
Godot's **Project > Open User Data Folder** location.

The white circle shows mining reach. A green block outline is a valid mining
target; red means the block is empty or out of range. Damaged stone displays
cracks before breaking, and the HUD reports save status and terrain edit count.

## Architecture

- `TerrainData` owns chunk-addressable block state and recorded edits.
- `TerrainGenerator` creates the seeded base world.
- `TerrainRenderer` draws blocks and builds consolidated collision runs.
- `TerrainChunkVisual` merges block runs and allows off-screen chunk culling.
- `TerrainWorld` is the public API used by mining and combat.
- `WorldPersistence` stores a versioned seed plus terrain modifications.
- `PlayerMovement` and `MeleeCombat` are independent player behaviors.
