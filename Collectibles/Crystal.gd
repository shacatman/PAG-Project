extends Area2D

#Defines the crystal object which emits a signal once picked up (by the Player) 
signal newcolor(color)
#member variables
enum COLORS {RED, GREEN, BLUE}#make sure this is the same as in ColorEffect!
export(COLORS) var color = COLORS.RED#default value to be changed through editor
var disabled = false


#Player picks up the crystal-notify both effect nodes
func _on_Crystal_body_entered(_body : Player) -> void:
	emit_signal("newcolor", color)
	disableCrystal()


func disableCrystal() -> void:#make crystal invisible and non-interactable
	$AudioStreamPlayer.play()#pickup sound
	$CollisionShape2D.set_deferred("disabled", true)
	visible = false
	disabled = true
	
func getSaveData():
	return {"disabled": disabled}

	
func loadData(data:Dictionary):
	if data["disabled"] == true:
		$AudioStreamPlayer.stream = null#do not play pickup sound again
		disableCrystal()
