class_name PlayerMovement
extends CharacterBody2D

@export var move_speed := 220.0
@export var acceleration := 1400.0
@export var air_acceleration := 850.0
@export var jump_velocity := -430.0

var facing := 1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity", 980.0)


func _ready() -> void:
	queue_redraw()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction := Input.get_axis("move_left", "move_right")
	if not is_zero_approx(direction):
		facing = 1 if direction > 0.0 else -1
	var current_acceleration := acceleration if is_on_floor() else air_acceleration
	velocity.x = move_toward(velocity.x, direction * move_speed, current_acceleration * delta)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
	queue_redraw()


func _draw() -> void:
	# Code-generated placeholder fighter silhouette.
	draw_circle(Vector2(0, -20), 9.0, Color("#f2c49b"))
	draw_rect(Rect2(-9, -11, 18, 27), Color("#d94848"))
	draw_line(Vector2(-6, 16), Vector2(-9, 29), Color("#26384a"), 6.0)
	draw_line(Vector2(6, 16), Vector2(9, 29), Color("#26384a"), 6.0)
	draw_line(Vector2(0, -5), Vector2(15 * facing, 3), Color("#f2c49b"), 5.0)
