extends Node2D


#onready var colorRect=$ColorRect


#crystal collected-remove the crystal effect
func _on_Crystal_newcolor(color):
#	print("removing effect")
#	colorRect.material.set_shader_param("active",false)
	queue_free()
