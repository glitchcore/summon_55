extends Node2D

enum State {IDLE, ZOOM_IN, ZOOMED, ZOOM_OUT}

export(float, EASE) var DAMP_EASING = 1.0
export var duration = 0.3
export var zoom_origin = 1
export var zoom_amount = -0.5

var state = State.IDLE
onready var me = $Player
onready var camera = $Player/Camera2
onready var timer = $Timer
onready var label = $Label

func _ready() -> void:
	pass

var current_target
var origin_bg_modulate

func enter_idle():
	state = State.IDLE
func handle_idle():
	pass
func exit_idle():
	pass

func enter_zoom_in(target: Node2D):
	state = State.ZOOM_IN
	current_target = target
	origin_bg_modulate = $Ground.modulate.a
	
	timer.set_wait_time(duration)
	timer.start()
func handle_zoom_in():
	camera.position = (current_target.position - me.position) / 2
	
	var x = ease(timer.time_left / timer.wait_time, DAMP_EASING)
	
	var zoom = zoom_origin + (1.0 - x) * zoom_amount
	camera.zoom = Vector2(zoom, zoom)
	
	$Ground.modulate.a =  x * origin_bg_modulate
func exit_zoom_in():
	enter_zoomed()

func enter_zoom_out():
	state = State.ZOOM_OUT
	camera.position = Vector2()
	timer.set_wait_time(duration)
	timer.start()
func handle_zoom_out():
	var x = ease(timer.time_left / timer.wait_time, DAMP_EASING)
	var zoom = zoom_origin + x * zoom_amount
	camera.zoom = Vector2(zoom, zoom)
	
	$Ground.modulate.a =  (1.0 - x) * origin_bg_modulate
func exit_zoom_out():
	enter_idle()
	
func enter_zoomed():
	state = State.ZOOMED
	timer.set_wait_time(5)
	timer.start()
func handle_zoomed():
	pass
func exit_zoomed():
	enter_zoom_out()

func _process(delta: float) -> void:
	if state == State.IDLE:
		handle_idle()
	elif state == State.ZOOM_IN:
		handle_zoom_in()
	elif state == State.ZOOMED:
		handle_zoomed()
	elif state == State.ZOOM_OUT:
		handle_zoom_out()

func on_PlayerCollide(target: Node):
	enter_zoom_in(target)
	
	for obj in $People.get_children():
		if obj != target:
			pass


func _on_Timer_timeout() -> void:
	if state == State.IDLE:
		exit_idle()
	elif state == State.ZOOM_IN:
		exit_zoom_in()
	elif state == State.ZOOMED:
		exit_zoomed()
	elif state == State.ZOOM_OUT:
		exit_zoom_out()
