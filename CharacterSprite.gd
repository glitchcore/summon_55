extends Sprite

export var COLORS = [
	Color(0, 0, 0),
	Color(1, 0, 0),
	Color(0, 1, 0),
	Color(0, 0, 1),
	Color(1, 0, 1)
]

var free_mode = true
var colors = Array()
var current_colors = [0, 0] # pair of color index

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
	
	material.set_shader_param("thickness", 0.2)

func _process(delta: float) -> void:
	if free_mode:
		var x = 1.0 - $ColorChanger.time_left / $ColorChanger.wait_time
		x = 1.0 - pow(cos(x * PI), 16.0)
		material.set_shader_param("cloud_amount", x)
	
	var a = COLORS[current_colors[0]]
	var b = COLORS[current_colors[1]]
	material.set_shader_param("color_1", Vector3(a.r, a.g, a.b))
	material.set_shader_param("color_2", Vector3(b.r, b.g, b.b))


# add color and select it
func on_add_color(color: int):
	free_mode = false
	current_colors = [color, 0]
	
	if colors.find(color) == -1:
		colors.append(color)

func get_colors():
	return colors

func on_free_mode():
	free_mode = true

func _on_ColorChanger_timeout() -> void:
	if free_mode:
		colors.shuffle()
		if colors.size() > 0:
			current_colors[0] = colors[0]
		if colors.size() > 1:
			current_colors[1] = colors[1]
