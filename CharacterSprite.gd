extends Sprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sheet_columns = hframes
	var sheet_rows = vframes
	var sprite_sheet_width = texture.get_width()
	var sprite_sheet_height = texture.get_height()
	
	var frame_size = Vector2(
		sprite_sheet_width/float(sheet_columns),
		sprite_sheet_height/float(sheet_rows)
	)

	var sprite_sheet_size = Vector2(sprite_sheet_width, sprite_sheet_height);
	
	material.set_shader_param("frame_size", frame_size);
	material.set_shader_param("sprite_sheet_size", sprite_sheet_size);

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
