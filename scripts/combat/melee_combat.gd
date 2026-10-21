class_name MeleeCombat
extends Node2D

@export var reach := 58.0
@export var attack_height := 52.0
@export var cooldown := 0.32
@export var damage := 1

var _cooldown_remaining := 0.0
var _flash_remaining := 0.0


func _physics_process(delta: float) -> void:
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)
	_flash_remaining = maxf(0.0, _flash_remaining - delta)
	if Input.is_action_just_pressed("melee_attack") and _cooldown_remaining <= 0.0:
		_attack()
	queue_redraw()


func _attack() -> void:
	var player := get_parent() as PlayerMovement
	var terrain := get_tree().get_first_node_in_group("terrain_world") as TerrainWorld
	if player == null or terrain == null:
		return
	var offset_x := 6.0 if player.facing > 0 else -reach - 6.0
	var attack_rect := Rect2(player.global_position + Vector2(offset_x, -attack_height * 0.5), Vector2(reach, attack_height))
	terrain.damage_cells_in_rect(attack_rect, damage)
	_cooldown_remaining = cooldown
	_flash_remaining = 0.12


func _draw() -> void:
	if _flash_remaining <= 0.0:
		return
	var player := get_parent() as PlayerMovement
	if player == null:
		return
	var offset_x := 6.0 if player.facing > 0 else -reach - 6.0
	draw_arc(Vector2(offset_x + reach * 0.5, 0), reach * 0.55, -1.2, 1.2, 12, Color("#ffe28a"), 5.0)
