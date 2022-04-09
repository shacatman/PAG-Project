extends StaticBody2D

#Defines the Barrier object: disables once puzzles are completed

var active = true
onready var collision = $CollisionShape2D


func disableBarrier():#called once puzzles are solved
	if active:
		collision.set_deferred("disabled", true)
		visible = false
		active = false


func getSaveData():
	return {"active": active}
	
func loadData(data:Dictionary):
	if data["active"] == false:
		disableBarrier()
