extends MenuButton

#Defines the Menu button that opens a popup menu with options(i.e. saving)

var popup = get_popup()
var paused = false

# Called when the node enters the scene tree for the first time.
func _ready():
	popup.popup_exclusive = true#don't close the popup from inputs outside the button
	popup.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	popup.add_item("Save",0)
	popup.add_item("Main",1)
	popup.connect("id_pressed", self,"onIdPressed")


func onIdPressed(id):
	match id:
		0:#SAVE
			GameData.saveGame()

		1:#back to main screen(does not save game)
			LevelSwitcher.titleScreen()


func togglePause() -> void:
	if !paused:#pause the game
		get_tree().paused = true
		paused = true
	else:#resume
		get_tree().paused = false
		paused = false


func _on_Menu_toggled(button_pressed):
	togglePause()
