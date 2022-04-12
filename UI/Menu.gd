extends MenuButton

#Defines the Menu button that opens a popup menu with options(i.e. saving)

var popup = get_popup()
var paused = false
onready var quitConfirm = $ConfirmationDialog
onready var saveMessage = $"../Label"
# Called when the node enters the scene tree for the first time.
func _ready():
	popup.popup_exclusive = true#don't close the popup from inputs outside the button
	popup.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	popup.add_item("Save",0)
	popup.add_item("Main",1)
	popup.connect("id_pressed", self,"onIdPressed")
	quitConfirm.connect("confirmed", LevelSwitcher, "titleScreen")
	#'style' improvments
	quitConfirm.get_child(1).align = Label.ALIGN_CENTER#center the popup text
	#remove default blue highlight around buttons
	quitConfirm.get_cancel().focus_mode = Control.FOCUS_NONE
	quitConfirm.get_ok().focus_mode = Control.FOCUS_NONE
	quitConfirm.get_ok().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quitConfirm.get_cancel().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	quitConfirm.get_close_button().queue_free()
	saveMessage.hide()


func onIdPressed(id):
	match id:
		0:#SAVE
			GameData.saveGame()
			saveMessage.show()
			var timer = saveMessage.get_node("Timer")#get_tree().create_timer(1)
			timer.start()
			yield(timer,"timeout")
			saveMessage.hide()

		1:#back to main screen(does not save game)
			#confirmation dialog
			togglePause()
			quitConfirm.popup_centered()
			yield(quitConfirm,"popup_hide")
			togglePause()


func togglePause() -> void:
	if !paused:#pause the game
		get_tree().paused = true
		paused = true
	else:#resume
		get_tree().paused = false
		paused = false


func _on_Menu_toggled(button_pressed):
	togglePause()
