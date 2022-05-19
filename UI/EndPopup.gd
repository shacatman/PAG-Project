extends ConfirmationDialog

#Defines EndPopup which notifies of game ending and gives a quick option to quit

func _ready():
	connect("confirmed", LevelSwitcher, "titleScreen")#back to menu
	#'style' improvments
	get_child(1).align = Label.ALIGN_CENTER#center the popup text
	#remove default blue highlight around buttons
	get_cancel().focus_mode = Control.FOCUS_NONE
	get_ok().focus_mode = Control.FOCUS_NONE
	get_ok().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_ok().text = "Quit"
	get_cancel().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	get_cancel().text = "Stay"
	#'remove' closing button
	get_close_button().disabled = true
	get_close_button().hide()
	#wait until game finished
	yield(Dialog.currentDialog, "endGame")
	yield(Dialog,"dialogEnded")
	popup_centered()#show once
