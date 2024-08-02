extends Control


func set_text():
	var time = Globals.get_time()
	var gems = Globals.get_gems()
	$VBoxContainer/Label2.text = "Your time was: " + str(time) + "\nYou collected " + str(gems) + " gems"

