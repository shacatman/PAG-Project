extends StaticBody2D

#Defines the Barrier object: disables once puzzles are completed
export(String) var id = "None"#optional(used through dialog)

var active = true
onready var collision = $CollisionShape2D

func _ready():
	#optional method of removing a barrier
	var notifier = Dialog.currentDialog
	notifier.connect("removeObject", self, "disableBarrier")

func disableBarrier(id = null):#called once puzzles are solved,optional id to differentiate between multiple barriers
	if !id or id == self.id:
		if active:
			collision.set_deferred("disabled", true)
			visible = false
			active = false


func getSaveData():
	return {"active": active}
	
func loadData(data:Dictionary):
	if data["active"] == false:
		disableBarrier()
