extends Sprite


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
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
	var time_seed = rng.randf_range(0.0, 1000.0)
	material.set_shader_param("time_seed", time_seed)
	
	material.set_shader_param("color_1", Vector3(0, 0, 1))
	material.set_shader_param("color_2", Vector3(0, 1, 0))
	material.set_shader_param("thickness", 0.2)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
