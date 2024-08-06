extends Node2D


const MAX_CHANNELS = 128


var _available_pool = []
var _playing_pool = []
var _enabled = false


func enabled(enabled):
	_enabled = enabled


func play(path) -> void:
	if !_enabled:
		return
	
	if _available_pool.size() <= 0:
		if _playing_pool.size() >= MAX_CHANNELS:
			_reset_channel(_playing_pool[0])
		else:
			_add_channel()
	
	var index = _available_pool.size() - 1
	var channel = _available_pool[index]
	channel.stream = path
	channel.position = Vector2(512, 320)
	channel.play()
	_playing_pool.append(channel)
	_available_pool.remove(index)


func _add_channel() -> void:
	var channel: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	add_child(channel)
	channel.bus = "Sound"
	_available_pool.append(channel)
	var _error = channel.connect("finished", self, "_on_stream_finished", [channel])


func _reset_channel(channel: AudioStreamPlayer2D) -> void:
	if channel.playing:
		channel.stop()
	_available_pool.append(channel)
	var index = _playing_pool.find(channel)
	_playing_pool.remove(index)


func _on_stream_finished(channel) -> void:
	_reset_channel(channel)

