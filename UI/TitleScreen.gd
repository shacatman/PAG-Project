extends Control

#Defines the TitleScreen which is the first scene to be loaded in the game


# Called when the node enters the scene tree for the first time.
func _ready():
	if !File.new().file_exists("user://savegame.json"): #disable continue button if no save available
		$VBoxContainer/Continue.disabled = true
		$VBoxContainer/Continue.set_default_cursor_shape(0) 



func _on_NewGame_pressed():
	LevelSwitcher.switchLevel(1, null, false)#no data to save on title screen


func _on_Continue_pressed():
	GameData.loadGame()


func _on_Quit_pressed():
	get_tree().quit()

