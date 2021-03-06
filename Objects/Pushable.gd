class_name Pushable
extends KinematicBody2D

# Defines an object that can be pushed (by Player)

#member variables
var SPEED : = 50



func push(direction : Vector2) -> void:
	move_and_slide(direction.normalized() * SPEED)

func getSaveData():
	return {"posx":position.x, "posy":position.y}
	
func loadData(data : Dictionary):
	position.x = data["posx"]
	position.y = data["posy"]
