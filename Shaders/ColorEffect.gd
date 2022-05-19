extends Node2D

#Defines the main color effect behavior: updating the visible colors
#member variables
onready var colorRect : ColorRect = $ColorRect
enum{RED, GREEN, BLUE}#must be the same as in the Crystal COLORS
var colorMap:Dictionary = {RED:"red", GREEN:"green", BLUE:"blue"}
var colorKeys:Array = []

func _ready():
	Dialog.currentDialog.connect("endGame",self,"disableEffect")


func disableEffect():
	colorRect.material.set_shader_param("active", false)


func _on_Crystal_newcolor(color : int) -> void:#connected through new_color signal(emitted by crystal)
	colorRect.material.set_shader_param("show_" + colorMap[color], true)


func getSaveData():#Persistent_Static
	for colorKey in colorMap:#save shader parameters
		if colorRect.material.get_shader_param("show_" + colorMap[colorKey]):
			colorKeys.append(colorKey)
	var active = colorRect.material.get_shader_param("active")
	return {"colorKeys": colorKeys, "active" : active}
	
func loadData(data:Dictionary):#Persistent_Static
	for color in data["colorKeys"]:#load shader parameters
		colorRect.material.set_shader_param("show_" + colorMap[int(color)], true)
	if !data["active"]:
		disableEffect()
