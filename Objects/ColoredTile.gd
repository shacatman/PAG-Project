extends Area2D

#Defines the ColoredTile which can change its color (to activeColor) when the player stands on it
#and send signals about its color's correctness

signal correct_tile_color
signal wrong_tile_color

export (String, "None", "Red", "Green", "Blue", "Yellow") var correctColor
var colormap = {"Red":Color.red, "Green":Color.green, "Blue":Color.blue, "Yellow":Color.yellow}
var tileActive = false
var activeColor = null
onready var rect = $ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_mask = 1#player collisions only


func _on_ColorTile_body_entered(body):#player on tile-may change its color
	tileActive = true
	if activeColor:
		changeTileColor()


func _on_ColorTile_body_exited(body):#player left tile-cannot change color
	tileActive = false


func colorUpdated(color = null):#called by manager whenever there is active color change
	activeColor = color
	if color and tileActive:
		changeTileColor()


func changeTileColor():#change tile color to active color
	if rect.color != colormap[activeColor]:#color is new
		if activeColor == correctColor:#new tile color is correct
			emit_signal("correct_tile_color")
		elif rect.color == colormap[correctColor]:#tile color was correct before change
			emit_signal("wrong_tile_color")
		rect.color = colormap[activeColor]
