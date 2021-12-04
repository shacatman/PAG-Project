extends Area2D


#member variables
onready var colorRect=$ColorRect
enum{RED,GREEN,BLUE}#must be the same as in the Crystal COLORS



func _on_Crystal_newcolor(color):#connected through new_color signal
	match color:
		RED:
			colorRect.material.set_shader_param("show_red",true)
		GREEN:
			colorRect.material.set_shader_param("show_green",true)
		BLUE:
			colorRect.material.set_shader_param("show_blue",true)
	pass
