extends Node2D

export(Array, int) var init_colors = []
export(float) var speed = 200
export(float) var follow_range = 100

onready var game = get_node("/root/Game") as Node
onready var player = get_node("/root/Game/Y/Player") as Node2D
onready var rng = RandomNumberGenerator.new()
onready var beat_timer = get_node("/root/Game/Beat") as Node

var is_moving = false
var is_owned = false
var move_offset = Vector2()
var request_audio = false

func _ready() -> void:
	rng.randomize()
	$Character/PlayerAnimator.play("Idle")
	$Character/PlayerAnimator.playback_speed = rng.randf_range(0.2, 0.4)
	
	speed -= rng.randf_range(0.0, 100.0)
	
	move_offset = Vector2(
		rng.randf_range(-follow_range, follow_range),
		rng.randf_range(-follow_range, follow_range)
	)
	
	for color in init_colors:
		if $Character/Sprite.colors.find(color) == -1:
			$Character/Sprite.colors.append(color)
	beat_timer.connect("timeout", self, "on_BeatTimeout")

func on_BeatTimeout():
	if request_audio:
		request_audio = false
		$Character/BaseAudio.play(0.0)

func _process(delta: float) -> void:
	if not is_owned:
		$Character/PlayerAnimator.play("Idle")
		return
	
	if is_moving:
		# stop condition
		if player.position.distance_to(position + move_offset) < 20:
			is_moving = false
	else:
		# start condition
		if player.position.distance_to(position + move_offset) > 30:
			is_moving = true
			move_offset = Vector2(
				rng.randf_range(-follow_range, follow_range),
				rng.randf_range(-follow_range, follow_range)
			)
			
	if is_moving:
		position += (player.position - (position + move_offset)) \
			.normalized() * speed * delta
		$Character/PlayerAnimator.play("Walk")
	else:
		$Character/PlayerAnimator.play("Idle")

func _on_Area2D_body_entered(body: Node) -> void:
	if not is_owned:
		game.call("on_PlayerCollide", self)
	
func on_set_owned(value: bool):
	is_owned = value
	
	if is_owned:
		request_audio = true
