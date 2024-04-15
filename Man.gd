extends Node2D

export(Array, int) var init_colors = []
export(float) var speed = 200

onready var game = get_node("/root/Game") as Node
onready var player = get_node("/root/Game/Player") as Node2D

var allow_move = false
var is_owned = false

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	$Character/PlayerAnimator.play("Idle")
	$Character/PlayerAnimator.playback_speed = rng.randf_range(0.2, 0.4)
	
	for color in init_colors:
		if $Character/Sprite.colors.find(color) == -1:
			$Character/Sprite.colors.append(color)

func _process(delta: float) -> void:
	if allow_move and is_owned:
		position += (player.position - position).normalized() * speed * delta
		$Character/PlayerAnimator.play("Walk")
	else:
		$Character/PlayerAnimator.play("Idle")

func _on_Area2D_body_entered(body: Node) -> void:
	allow_move = false
	if not is_owned:
		game.call("on_PlayerCollide", self)

func _on_Area2D_body_exited(body: Node) -> void:
	allow_move = true
	
func on_set_owned(value: bool):
	is_owned = value
