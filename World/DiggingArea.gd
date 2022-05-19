extends Area2D


## Defines a DiggingArea that can detect companion and enable/disable digging command

export(float,0,1) var truffleProbability = 0.5
export(int) var capacity = 1

var digger#companion


#save the dialog progression
func getSaveData():
	return {"capacity":capacity}


#load the dialog progression
func loadData(data : Dictionary):
	capacity = data["capacity"]


func _on_DiggingArea_body_entered(body):#allow companion to dig
	digger = body
	var commands = digger.get_node("Commands")
	commands.unlock("Dig", 3)
	if !commands.is_connected("newCommand", self, "dig"):
		commands.connect("newCommand", self, "dig")


func _on_DiggingArea_body_exited(body):#stop companion from digging
	var commands = digger.get_node("Commands")
	commands.lock("Dig", 3)
	if commands.is_connected("newCommand", self, "dig"):
		commands.disconnect("newCommand", self, "dig")


func dig(digKey, _params = null):#extra params will be ignored
	if digKey == 3:#validate command is Dig command
		var isTruffle = capacity > 0 and truffleProbability > randf()
		if capacity <= 0:
			Dialog.startDialog("dig_finished")
		elif isTruffle:
			Dialog.startDialog("dig_success")
			capacity -= 1
		else:#pick random fail(2 options)
			Dialog.startDialog("dig_fail" + str(randi() % 2 + 1))

