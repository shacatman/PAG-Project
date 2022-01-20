extends Node2D

#Defines the main color effect behavior: updating the visible colors
#member variables
onready var colorRect : ColorRect = $ColorRect
enum{RED, GREEN, BLUE}#must be the same as in the Crystal COLORS



func _on_Crystal_newcolor(color : int) -> void:#connected through new_color signal
	match color:#make the new color visible(inside the effect area)
		RED:
			colorRect.material.set_shader_param("show_red", true)
		GREEN:
			colorRect.material.set_shader_param("show_green", true)
		BLUE:
			colorRect.material.set_shader_param("show_blue", true)
