extends AcceptDialog

#Defines Controls description popup that can be opened on main menu

func _ready():
	#remove default blue highlight around buttons
	get_ok().focus_mode = Control.FOCUS_NONE
	get_ok().mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	#'remove' close button
	get_close_button().disabled = true
	get_close_button().hide()


#Description:
#1. Move the player using the arrow keys.
#2. Right-click to open Commands interface.
#3. Dialog interactions are triggered by the 'E' key. (available when a bubble icon appears)
#4. Use space bar to continue dialog. (unless a choice is required,then press a button)
