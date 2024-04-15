extends Node2D

const SPEED = 250

var target_position = Vector2()

export(float) var expand = 0.0

export(Array, int) var init_colors = []

func _ready() -> void:
	target_position = position
	$Character/PlayerAnimator.play("Idle")
	$Character/Sprite.material.set_shader_param("thickness", 0.8)
	
	for color in init_colors:
		if $Character/Sprite.colors.find(color) == -1:
			$Character/Sprite.colors.append(color)

func _process(delta: float) -> void:
	var is_moving = false
	# handle keyboard movement
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input.length() > 0:
		position += input * SPEED * delta
		target_position = position
		is_moving = true
	
	# handle mouse click
	if Input.is_action_just_pressed("ui_click"):
		var click_position = get_global_mouse_position()
		if position.distance_to(click_position) > 1:
			target_position = click_position
	
	# handle mouse movement
	if position.distance_to(target_position) > 10:
		position += (target_position - position).normalized() * SPEED * delta
		is_moving = true
	
	if is_moving:
		$Character/PlayerAnimator.play("Walk")
	else:
		$Character/PlayerAnimator.play("Idle")
		
func on_PlayerCollide():
	# stop on collide
	target_position = position
