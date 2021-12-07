extends Area2D


#member variables
enum COLORS {RED,GREEN,BLUE}#make sure this is the same as in ColorEffect!
export(COLORS) var color = COLORS.RED#default value to be changed through editor or inheritance

signal newcolor(color)


#Player picks up the crystal-notify player and crystal effect nodes
func _on_Crystal_body_entered(body):
	emit_signal("newcolor",color)
	queue_free()
