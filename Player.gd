extends Node2D

const SPEED = 800

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += input * SPEED * delta
