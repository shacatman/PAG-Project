tool
extends Node2D

#Defines the sign object coloring(in editor and ready function)

export(Color) var color = Color.gray setget setColor

onready var colorRect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	colorRect.color = color

func setColor(newColor):
	color = newColor
	if !is_inside_tree():#avoid crash
		return
	$ColorRect.color = newColor
