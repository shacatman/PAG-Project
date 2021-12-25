extends Node2D

#Could be deleted in the future



#crystal collected-remove the crystal effect
func _on_Crystal_newcolor(color : int) -> void:

	queue_free()
