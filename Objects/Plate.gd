extends Area2D

# Defines the Plate object that can be pressed by Player,Companion or Pushables.

signal pressed
signal unpressed
var bodyCount : int = 0

func _ready():
	#connect signals to PlatesTracker
	connect("pressed",get_parent(),"platePressed")
	connect("unpressed",get_parent(),"plateUnPressed")


func _on_Plate_body_entered(_body):
	bodyCount+=1
	if bodyCount == 1:#first time being pressed
		#change to pressed sprite?(later)
		emit_signal("pressed")


func _on_Plate_body_exited(_body):
	bodyCount-=1
	if bodyCount == 0:#not pressed anymore
		#change to default sprite?(later)
		emit_signal("unpressed")
