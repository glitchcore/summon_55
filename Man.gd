extends Node2D

signal player_collide(object)

onready var game = get_node("/root/Game") as Node

func _ready() -> void:
	var _r = self.connect("player_collide", game, "on_PlayerCollide")
	
	var rng = RandomNumberGenerator.new()
	
	rng.randomize()
	$Character/PlayerAnimator.play("Idle")
	$Character/PlayerAnimator.playback_speed = rng.randf_range(0.2, 0.4)

func _on_Area2D_body_entered(body: Node) -> void:
	emit_signal("player_collide", self)
