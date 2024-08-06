extends Node


const LEVEL_1 = preload("res://levels/Level1.tscn")
const LEVEL_2 = preload("res://levels/Level2.tscn")
const LEVEL_3 = preload("res://levels/Level3.tscn")


const SFX_LEVEL_FINISHED = preload("res://assets/audio/sfx/level_finished.wav")
const SFX_LIGHT_SWITCH = preload("res://assets/audio/sfx/light_switch.wav")
const SFX_PAUSE = preload("res://assets/audio/sfx/pause.wav")


onready var fx_light = $World/Light
onready var fx_dark = $World/Dark
onready var game_paused_modal = $CanvasLayer/UI/GamePausedModal
onready var game_reset_modal = $CanvasLayer/UI/GameResetModal
onready var level_finished_modal = $CanvasLayer/UI/LevelFinishedModal
onready var game_finished_modal = $CanvasLayer/UI/GameFinishedModal


var time_timer = 0
var is_paused = false
var is_started = false
var level = null
var phases = null
var world_light = null
var world_dark = null
var levels = [LEVEL_1, LEVEL_2, LEVEL_3]
var current_level = 0
var initial_volume = 0


func _ready():
	level = $World/Level
	phases = level.get_node("Phases")
	world_light = phases.get_node("Light")
	world_dark = phases.get_node("Dark")
	
	initial_volume = $BGM.volume_db
	
	_start_game()
	
	var _error = EventBus.connect("light_state_changed", self, "_on_EventBus_light_state_changed")
	_error = EventBus.connect("player_started", self, "_on_EventBus_player_started")
	_error = EventBus.connect("player_finished", self, "_on_EventBus_player_finished")
	_error = EventBus.connect("level_loaded", self, "_on_EventBus_level_loaded")


func _on_EventBus_light_state_changed():
	SFX.play(SFX_LIGHT_SWITCH)
	_switch_light()


func _on_EventBus_player_started():
	is_started = true


func _on_EventBus_player_finished():
	is_started = false
	_pause_game(true)
	
	_fade_out_music()
	SFX.play(SFX_LEVEL_FINISHED)
	
	if current_level >= levels.size() - 1:
		game_finished_modal.visible = true
		return
	
	level_finished_modal.set_text()
	level_finished_modal.visible = true
	SFX.enabled(false)


func _fade_out_music():
	initial_volume = $BGM.volume_db
	$Tween.interpolate_property($BGM, "volume_db", initial_volume, -80, 1.0, 1, Tween.EASE_IN, 0)
	$Tween.start()


func _on_Tween_tween_completed(object, _key):
	object.stop()
	$BGM.volume_db = initial_volume


func _on_EventBus_level_loaded(new_level):
	level = new_level
	phases = level.get_node("Phases")
	world_light = phases.get_node("Light")
	world_dark = phases.get_node("Dark")
	
	_start_game()


func _switch_light():
	var state = Globals.get_light_state()
	if state == Globals.LightState.Dark:
		fx_light.visible = false
		fx_dark.visible = true
		$BGM.pitch_scale = 0.95
	else:
		fx_light.visible = true
		fx_dark.visible = false
		$BGM.pitch_scale = 1
	call_deferred("_switch_worlds")


func _switch_worlds():
	var state = Globals.get_light_state()
	if state == Globals.LightState.Dark:
		world_dark.visible = true
		if phases.get_child(0) != world_dark:
			phases.add_child(world_dark)
		if phases.get_children().has(world_light):
			phases.remove_child(world_light)
	else:
		world_light.visible = true
		if phases.get_child(0) != world_light:
			phases.add_child(world_light)
		if phases.get_children().has(world_dark):
			phases.remove_child(world_dark)


func _input(event):
	var is_game_finished = game_finished_modal.visible
	var is_level_finished = level_finished_modal.visible
	var is_game_paused = game_paused_modal.visible
	var is_game_reset = game_reset_modal.visible
	
	if event.is_action_pressed("ui_cancel") and OS.get_name() != "HTML5":
		get_tree().quit()
	
	if is_game_finished:
		if event.is_action_pressed("ui_accept"):
			game_finished_modal.visible = false
			_next_level()
	elif is_level_finished:
		if event.is_action_pressed("ui_accept"):
			level_finished_modal.visible = false
			_next_level()
	else:
		if event.is_action_pressed("ui_pause"):
			if is_game_reset:
				game_reset_modal.visible = false
				_pause_game(false)
			else:
				game_paused_modal.visible = !is_game_paused
				_pause_game(!is_game_paused)
		elif event.is_action_pressed("ui_reset"):
			if is_game_reset:
				_reset_level()
				game_reset_modal.visible = false
			else:
				game_reset_modal.visible = true
				_pause_game(true)
	
	if OS.is_debug_build():
		if !is_paused and event.is_action_released("ui_debug"):
			var new_state = Globals.LightState.Light
			if Globals.get_light_state() == Globals.LightState.Light:
				new_state = Globals.LightState.Dark
			Globals.set_light_state(new_state)
			_switch_light()


func _process(delta):
	if is_paused:
		return
	
	if is_started:
		time_timer += delta
		if time_timer > 1:
			Globals.increase_time()
			time_timer = 0
	
	$World/Camera2D.position = $World/Player.position


func _reset_level():
	current_level -= 1
	_next_level()


func _next_level():
	current_level += 1
	if current_level >= levels.size():
		current_level = 0
	
	# disable player collision to collision in the new level before resetting position
	$World/Player.set_collision(false)
	$World/Player.reset(Vector2(-128, -128))
	
	# remove the level
	$World.remove_child(level)
	level.queue_free()
	
	# add the next level
	var new_level = levels[current_level].instance()
	new_level.name = "Level"
	$World.add_child_below_node($World/OuterWalls, new_level)
	
	Globals.set_light_state(Globals.LightState.Light)


func _start_game():
	# reset everything
	$World/Player.reset(level.get_node("Start").position)
	$World/Camera2D.position = $World/Player.position
	$World/Camera2D.current = true
	Globals.reset()
	_switch_light()
	
	# wait before enabling collision to avoid overlap
	yield(get_tree().create_timer(0.1), "timeout")
	$World/Player.set_collision(true)
	
	_pause_game(false)
	SFX.enabled(true)
	
	# start BGM
	$Tween.stop_all()
	$BGM.volume_db = initial_volume
	$BGM.pitch_scale = 1
	$BGM.play()


func _pause_game(paused):
	is_paused = paused
	$World/Player.pause(paused)
	SFX.play(SFX_PAUSE)

