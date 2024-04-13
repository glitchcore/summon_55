extends Node2D

func _ready() -> void:
	pass

var counter = 0

func _process(delta: float) -> void:
	pass

func on_PlayerCollide(position: Vector2, text: String):
	var label = load("LabelNode.tscn").instance()
	add_child(label)
	label.position = get_global_mouse_position()
	label.find_node("Text").text = "1"
