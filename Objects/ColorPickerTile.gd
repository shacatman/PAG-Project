tool
extends Area2D

#Defines the ColorPickerTile which is a 'brush' for the ColoredTile objects
# that is active only when the companion stands on it.

signal tile_color_update(color)
export (String, "None", "Red", "Green", "Blue", "Yellow") var colorType setget setColor
var colormap = {"Red":Color.red, "Green":Color.green, "Blue":Color.blue, "Yellow":Color.yellow}

onready var rect = $ColorRect

## Called when the node enters the scene tree for the first time.
func _ready():
	rect.color = colormap[colorType]
	collision_mask=4#companion collisions only

func setColor(newColor):#set the tile color(in editor/ready function)
	colorType = newColor
	if !is_inside_tree():#avoid crashes
		return
	$ColorRect.color = colormap[newColor]


func _on_ColorPickerTile_body_entered(body):#companion on picker tile
	emit_signal("tile_color_update",colorType)


func _on_ColorPickerTile_body_exited(body):#companion left
	emit_signal("tile_color_update")

