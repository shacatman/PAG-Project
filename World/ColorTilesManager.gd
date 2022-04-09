extends Node2D

#Defines the ColorTilesManager which will have both the ColorPickerTile and ColoredTile objects as children nodes
#will recieve signals from them and manage their behavior

var colorables : Array = []
var correctColors : int = 0
onready var barrier = $Barrier

func _ready():#connect signals for all child nodes
	for child in get_children():
		if "ColorPickerTile" in child.name:
			child.connect("tile_color_update",self,"notifyColorChanged")
		elif "ColoredTile" in child.name:
			colorables.append(child)
			child.connect("correct_tile_color",self,"correctColor")
			child.connect("wrong_tile_color",self,"wrongColor")


func notifyColorChanged(color = null):#called by color pickers,notifies colored tiles
	for colorable in colorables:
		colorable.colorUpdated(color)


func correctColor():#called by colored tiles whenever they changed into their correct color
	correctColors += 1
	if correctColors == colorables.size() and barrier.active:#solved the puzzle-disable barrier
		barrier.disableBarrier()


func wrongColor():#called by colored tiles whenever they changed from their correct color to a wrong one
	correctColors -= 1
