extends Node


onready var world_light = $World/Level/Phases/Light
onready var world_dark = $World/Level/Phases/Dark
onready var phases = $World/Level/Phases
onready var fx_light = $World/Light
onready var fx_dark = $World/Dark


var score_timer = 0
var is_paused = false


func _ready():
	_start_game()
	var _error = EventBus.connect("light_state_changed", self, "_on_EventBus_light_state_changed")
	_error = EventBus.connect("player_started", self, "_on_EventBus_player_started")
	_error = EventBus.connect("player_finished", self, "_on_EventBus_player_finished")


func _on_EventBus_light_state_changed():
	_switch_light()


func _on_EventBus_player_started():
	# TODO: update UI, start game (monsters, score, etc?)
	pass


func _on_EventBus_player_finished():
	# TODO: update UI, finish game
	print("Finished!")
	pass


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
	var is_game_start = $CanvasLayer/UI/GameStartModal.visible
	var is_game_over = $CanvasLayer/UI/GameOverModal.visible
	var is_game_pause = $CanvasLayer/UI/GamePauseModal.visible
	
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	
	if !is_game_start and !is_game_over and !is_game_pause and event.is_action_pressed("ui_cancel"):
		$CanvasLayer/UI/GamePauseModal.visible = true
		_pause_game(true)
		
	if event.is_action_pressed("ui_accept"):
		if is_game_start:
			$CanvasLayer/UI/GameStartModal.visible = false
			_pause_game(false)
			if !BGM.is_playing():
				BGM.play_title()
		elif is_game_over:
			$CanvasLayer/UI/GameOverModal.visible = false
			_start_game()
		elif is_game_pause:
			$CanvasLayer/UI/GamePauseModal.visible = false
			_pause_game(false)
	
	if event.is_action_released("ui_select"):
		var new_state = Globals.LightState.Light
		if Globals.get_light_state() == Globals.LightState.Light:
			new_state = Globals.LightState.Dark
		Globals.set_light_state(new_state)
		_switch_light()


func _process(delta):
	if is_paused:
		return
	
	score_timer += delta
	if score_timer > 1:
		Globals.increase_score()
		score_timer = 0
	
	$World/Camera2D.position = $World/Player.position


func _start_game():
#	$CanvasLayer/UI/GameStartModal.visible = true
	
	$World/Player.reset($World/Level/Start.position)
	Globals.reset()
	
	_pause_game(false)
	
	$World/Camera2D.current = true
	
	_switch_light()


func _game_over():
	$CanvasLayer/UI/GameOverModal.visible = true
	$CanvasLayer/UI/GameOverModal.set_score($CanvasLayer/UI/ScoreDisplay.get_score())
	_pause_game(true)
	SFX.play_game_over()


func _pause_game(paused):
	is_paused = paused
	$World/Player.pause(paused)

