extends Area2D

#Defines the flower object which can be picked up by the Player after companion digs nearby 
#displays in order according to index, matching with dialog data(checked at ready func)


export(int) var order = -1#to be compared in ready to determine activity
var disabled = true
var pickable = false#updated through dig


func _ready():
	if Dialog.currentDialog.testCondition("flowerIndex == " + str(order)):#match index
		setFlowerActive(true)
	else:
		setFlowerActive(false)


func _on_Flower_body_entered(body) -> void:
	if disabled:#no interaction allowed
		return
	match body.collision_layer:#layer value of the body entering
		1:#player
			#pick flower if possible-disables it+notify dialog
			if pickable:
				setFlowerActive(false)
				Dialog.startDialog("flower_collected")
		4:#companion
			#connect to function changing flower state(allows comapnion to dig)
			var commands = body.get_node("Commands")
			commands.unlock("Dig", 3)
			if !commands.is_connected("newCommand", self, "dig"):
				commands.connect("newCommand", self, "dig")


func _on_Flower_body_exited(body):#stop companion from digging
	if body.collision_layer == 4:#only for companion
		var commands = body.get_node("Commands")
		commands.lock("Dig", 3)
		if commands.is_connected("newCommand", self, "dig"):
			commands.disconnect("newCommand", self, "dig")


func setFlowerActive(isActive:bool) -> void:#toggle flower activity
	$CollisionShape2D.set_deferred("disabled", !isActive)#toggle collisions
	visible = isActive
	disabled = !isActive

func dig(digKey, _params = null):#extra params are ignored
	if digKey == 3:#validate command as Dig command
		#digging changes the state of the flower so it can be picked up by the player now
		pickable = true#if player in area make them pick it up...
		for body in get_overlapping_bodies():#in case player is already inside area
			if body.collision_layer == 1:
				setFlowerActive(false)
				Dialog.startDialog("flower_collected")#inform player of progress


func getSaveData():
	return {"pickable":pickable}#save last state of the flower

func loadData(data:Dictionary):
	#disabled var is corrected on ready function
	pickable = data["pickable"]
	#if picked up already will not appear again after save(beacause flowerIndex is +1)
