extends Node2D

signal player_collide(position, text)

onready var game = get_node("/root/Game") as Node

func _ready() -> void:
	var _r = self.connect("player_collide", game, "on_PlayerCollide")

func _on_Area2D_body_entered(body: Node) -> void:
	emit_signal("player_collide", Vector2(), "example")