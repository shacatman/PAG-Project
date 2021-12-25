extends Area2D

#Defines the crystal object which emits a signal once picked up (by the Player) 
signal newcolor(color)
#member variables
enum COLORS {RED, GREEN, BLUE}#make sure this is the same as in ColorEffect!
export(COLORS) var color = COLORS.RED#default value to be changed through editor or inheritance



#Player picks up the crystal-notify both effect nodes
func _on_Crystal_body_entered(body : Player) -> void:
	emit_signal("newcolor", color)
	queue_free()
