extends Node2D


export (int) var gems_in_level = 0


func _ready():
	Globals.set_gems_in_level(gems_in_level)

