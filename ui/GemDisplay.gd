extends Control


const GEM_TEXTURE = preload("res://assets/gem.png")
const EMPTY_TEXTURE = preload("res://assets/gem_empty.png")


func _ready():
	_update_gems()
	var _error = EventBus.connect("gems_changed", self, "_on_EventBus_gems_changed")


func _update_gems():
	var gems_in_level = Globals.get_gems_in_level()
	var gems_collected = Globals.get_gems()
	
	for child in $HBoxContainer.get_children():
		child.queue_free()
	
	for i in gems_in_level:
		var texture_rect = TextureRect.new()
		if gems_collected > 0:
			texture_rect.texture = GEM_TEXTURE
			gems_collected -= 1
		else:
			texture_rect.texture = EMPTY_TEXTURE
		$HBoxContainer.add_child(texture_rect)


func _on_EventBus_gems_changed():
	_update_gems()

