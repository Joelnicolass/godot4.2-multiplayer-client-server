extends CharacterBody2D


@export var speed = 200
@export var friction = 0.01
@export var acceleration = 0.1

func _enter_tree():
	set_multiplayer_authority(name.to_int())


func get_input():
	var vertical = Input.get_axis("ui_up", "ui_down")
	var horizontal = Input.get_axis("ui_left", "ui_right")
	return Vector2(horizontal, vertical)


func _physics_process(_delta):
	if not is_multiplayer_authority(): return

	var direction = get_input()
	if direction.length() > 0:
		velocity = velocity.lerp(direction.normalized() * speed, acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, friction)
	
	move_and_slide()