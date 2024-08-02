extends Node


const LEVEL_1 = preload("res://levels/TestLevel3.tscn")
const LEVEL_2 = preload("res://levels/TestLevel1.tscn")
const LEVEL_3 = preload("res://levels/TestLevel2.tscn")


onready var world_light = $World/Level/Phases/Light
onready var world_dark = $World/Level/Phases/Dark
onready var phases = $World/Level/Phases
onready var fx_light = $World/Light
onready var fx_dark = $World/Dark
onready var game_paused_modal = $CanvasLayer/UI/GamePausedModal
onready var level_finished_modal = $CanvasLayer/UI/LevelFinishedModal


var time_timer = 0
var is_paused = false
var is_started = false


func _ready():
	_start_game()
	var _error = EventBus.connect("light_state_changed", self, "_on_EventBus_light_state_changed")
	_error = EventBus.connect("player_started", self, "_on_EventBus_player_started")
	_error = EventBus.connect("player_finished", self, "_on_EventBus_player_finished")


func _on_EventBus_light_state_changed():
	_switch_light()


func _on_EventBus_player_started():
	is_started = true


func _on_EventBus_player_finished():
	is_started = false
	_pause_game(true)
	level_finished_modal.set_text()
	level_finished_modal.visible = true


func _switch_light():
	var state = Globals.get_light_state()
	if state == Globals.LightState.Dark:
		fx_light.visible = false
		fx_dark.visible = true
	else:
		fx_light.visible = true
		fx_dark.visible = false
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
	var is_level_finished = level_finished_modal.visible
	var is_game_paused = game_paused_modal.visible
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if is_level_finished:
		if event.is_action_pressed("ui_accept"):
			level_finished_modal.visible = false
			_next_level()
	else:
		if event.is_action_pressed("ui_pause"):
			game_paused_modal.visible = !is_game_paused
			_pause_game(!is_game_paused)
	
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


func _next_level():
	# TODO: load next level
	_start_game()


func _start_game():
	$World/Player.reset($World/Level/Start.position)
	$World/Camera2D.current = true
	Globals.reset()
	_switch_light()
	_pause_game(false)


func _pause_game(paused):
	is_paused = paused
	$World/Player.pause(paused)

