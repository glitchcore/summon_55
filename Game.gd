extends Node2D

enum State {IDLE, ZOOM_IN, IDLE_TEXT, EXPOSITION, EXPANSION, CONTRACTION, HOLD, ZOOM_OUT}

export(float, EASE) var ZOOM_EASING = 1.0
export(float, EASE) var EXPAND_EASING = 1.0
export(float, EASE) var AMOUNT_EASING = 1.0

export var zoom_time = 0.3
export var zoom_origin = 1
export var zoom_amount = -0.5
export var expand_time = 2
export var contract_time = 1
export var idle_text_time = 1
export var exposition_time = 3
export var hold_time = 1

onready var me = $Y/Player
onready var camera = $Y/Player/Camera2
onready var timer = $Timer
onready var label = $LabelContainer/Label
onready var label_container = $LabelContainer

var state = State.IDLE
var current_target
var origin_bg_modulate
var materials = Array()
var color_challenge = Array()
var is_owned = false

func handle_default():
	pass

func enter_idle():
	state = State.IDLE
func exit_idle():
	var color_challenge_container = get_color_challenge(
		me.find_node("Character").find_node("Sprite").call("get_colors"),
		current_target.find_node("Character").find_node("Sprite").call("get_colors")
	)
	
	color_challenge = color_challenge_container[0]
	is_owned = color_challenge_container[1]
	
	if color_challenge.size() > 0:
		enter_zoom_in()
	else:
		enter_idle_text()

func enter_idle_text():
	state = State.IDLE_TEXT
	
	timer.set_wait_time(idle_text_time)
	timer.start()
func exit_idle_text():
	enter_idle()
	
func enter_zoom_in():
	state = State.ZOOM_IN
	origin_bg_modulate = $Ground.modulate.a
	materials = [
		me.find_node("Character").find_node("Sprite").material,
		current_target.find_node("Character").find_node("Sprite").material
	]
	
	timer.set_wait_time(zoom_time)
	timer.start()
func handle_zoom_in():
	camera.position = (current_target.position - me.position) / 2
	
	var x = ease(timer.time_left / timer.wait_time, ZOOM_EASING)
	
	var zoom = zoom_origin + (1.0 - x) * zoom_amount
	camera.zoom = Vector2(zoom, zoom)
	
	$Ground.modulate.a =  x * origin_bg_modulate
func exit_zoom_in():
	enter_exposition()

func enter_exposition():
	state = State.EXPOSITION
	
	var actor = color_challenge[0][0]
	
	label.visible = true
	label_container.position = \
		(current_target.position + me.position) / 2 + Vector2(0.0, -100.0)
	label.text = "let's try to explore you"
	
	timer.set_wait_time(exposition_time)
	timer.start()
func exit_exposition():
	label.visible = false
	enter_expansion()

func enter_expansion():
	state = State.EXPANSION
	
	var actor = color_challenge[0][0]
	var color = color_challenge[0][1]
	materials[1 - actor].set_shader_param("expand", 1.0)
	materials[1 - actor].set_shader_param("cloud_amount", 0.0)
	
	me.find_node("Character").find_node("Sprite").call("on_add_color", color)
	current_target.find_node("Character").find_node("Sprite").call("on_add_color", color)
	
	timer.set_wait_time(expand_time)
	timer.start()
func handle_expansion():
	var x = 1.0 - timer.time_left / timer.wait_time
	var actor = color_challenge[0][0]
	materials[actor].set_shader_param("expand", ease(x, EXPAND_EASING))
	materials[actor].set_shader_param("cloud_amount", ease(x, EXPAND_EASING))
	materials[1 - actor].set_shader_param("cloud_amount", ease(x, AMOUNT_EASING))
func exit_expansion():
	enter_contraction()
	
func enter_contraction():
	state = State.CONTRACTION
	
	timer.set_wait_time(contract_time)
	timer.start()
func handle_contraction():
	var x = timer.time_left / timer.wait_time
	materials[0].set_shader_param("expand", x)
	materials[1].set_shader_param("expand", x)
func exit_contraction():
	enter_hold()

func enter_hold():
	state = State.HOLD
	
	timer.set_wait_time(hold_time)
	timer.start()
func exit_hold():
	color_challenge.pop_front()
	if color_challenge.size() > 0:
		enter_exposition()
	else:
		enter_zoom_out()

func enter_zoom_out():
	state = State.ZOOM_OUT
	
	me.find_node("Character").find_node("Sprite").call("on_free_mode")
	current_target.find_node("Character").find_node("Sprite").call("on_free_mode")
	
	if is_owned:
		current_target.call("on_set_owned", true)
	
	camera.position = Vector2()
	timer.set_wait_time(zoom_time)
	timer.start()
func handle_zoom_out():
	var x = ease(timer.time_left / timer.wait_time, ZOOM_EASING)
	var zoom = zoom_origin + x * zoom_amount
	camera.zoom = Vector2(zoom, zoom)
	
	$Ground.modulate.a =  (1.0 - x) * origin_bg_modulate
func exit_zoom_out():
	enter_idle()

func _process(delta: float) -> void:
	if state == State.IDLE:
		handle_default()
	elif state == State.IDLE_TEXT:
		handle_default()
	elif state == State.EXPOSITION:
		handle_default()
	elif state == State.ZOOM_IN:
		handle_zoom_in()
	elif state == State.EXPANSION:
		handle_expansion()
	elif state == State.CONTRACTION:
		handle_contraction()
	elif state == State.HOLD:
		handle_default()
	elif state == State.ZOOM_OUT:
		handle_zoom_out()

func on_PlayerCollide(target: Node):
	current_target = target
	
	me.call("on_PlayerCollide")
	
	if state == State.IDLE:
		exit_idle()
	
	for obj in $Y.get_children():
		if obj != target:
			pass

func _on_Timer_timeout() -> void:
	if state == State.IDLE:
		exit_idle()
	elif state == State.IDLE_TEXT:
		exit_idle_text()
	elif state == State.EXPOSITION:
		exit_exposition()
	elif state == State.ZOOM_IN:
		exit_zoom_in()
	elif state == State.EXPANSION:
		exit_expansion()
	elif state == State.CONTRACTION:
		exit_contraction()
	elif state == State.HOLD:
		exit_hold()
	elif state == State.ZOOM_OUT:
		exit_zoom_out()

func get_color_challenge(a, b):
	var res = Array()
	
	var a_count = 0
	var b_count = 0
	
	for x in a:
		if b.find(x) == -1:
			res.append([0, x])
			a_count += 1
	
	for x in b:
		if a.find(x) == -1:
			res.append([1, x])
			b_count += 1
			
	var owned = a_count > b_count
	
	res.shuffle()
	return [res, owned]
