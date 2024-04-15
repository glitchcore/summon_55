extends Node2D

onready var game = get_node("/root/Game") as Node

export(Array, int) var init_colors = []

func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	$Character/PlayerAnimator.play("Idle")
	$Character/PlayerAnimator.playback_speed = rng.randf_range(0.2, 0.4)
	
	for color in init_colors:
		if $Character/Sprite.colors.find(color) == -1:
			$Character/Sprite.colors.append(color)

func _on_Area2D_body_entered(body: Node) -> void:
	game.call("on_PlayerCollide", self)
