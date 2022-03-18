extends Line2D

#Defines the Trail object which is drawn behind the Runner object 

export(int) var length = 50#trail line length
var point

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_toplevel(true)#makes trail independent of the parent position(fixes weird offset)


func drawline():#called by the parent
	global_position = Vector2.ZERO
	global_rotation = 0
	point = get_parent().global_position
	add_point(point)
	while get_point_count() > length:#remove old points to keep same length
		remove_point(0)
