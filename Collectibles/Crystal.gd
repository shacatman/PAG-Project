extends Area2D


#member variables
enum COLORS {RED,GREEN,BLUE}#make sure this is the same as in ColorEffect!
export(COLORS) var color = COLORS.RED#default value

signal newcolor(color)



func _on_Crystal_body_entered(body):
	if body.name == "Player":
		emit_signal("newcolor",color)
		queue_free()
