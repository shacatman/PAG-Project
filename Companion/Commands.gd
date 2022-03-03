extends Node2D

#Defines the Commands object which manages a popup menu interface(sends commands to companion)

signal newCommand(id,params)
var lastMousePos
onready var menu=$CanvasLayer/PopupMenu


# Called when the node enters the scene tree for the first time.
func _ready():
	#add the commands to the popup menu
	menu.add_item("Follow Me",0)
	menu.add_item("Stay",1)
	menu.add_item("Go Here",2)
	menu.connect("id_pressed", self,"onIdPressed")#connect signal from command events


func _input(event):
	#right click opens the popup menu
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == BUTTON_RIGHT:
		lastMousePos=get_global_mouse_position()
		menu.popup(Rect2(event.position.x,event.position.y,menu.rect_size.x,menu.rect_size.y))


func onIdPressed(id):
	#pass the relevant command(and info) through signal to the parent (companion)
	match id:
		0:#FOLLOW ME
			menu.set_item_disabled(menu.get_item_index(id),true)#avoid multiple clicks
			menu.set_item_disabled(menu.get_item_index(1),false)
			emit_signal("newCommand",0)
		1:#STAY
			menu.set_item_disabled(menu.get_item_index(id),true)
			menu.set_item_disabled(menu.get_item_index(0),false)
			emit_signal("newCommand",1)
		2:#GO HERE
			menu.set_item_disabled(menu.get_item_index(0),false)
			menu.set_item_disabled(menu.get_item_index(1),false)
			emit_signal("newCommand",2,lastMousePos)
