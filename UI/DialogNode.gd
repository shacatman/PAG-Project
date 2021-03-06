extends Node

#Defines a DialogNode corresponding to an entry in the dialog json file
#Holds info of currentID,speaker(name),text(array),choices,action,nextID

signal dialogCheckpoint(newID)#signal to notify npc what to say next time
signal removeObject(index)#to remove barriers through dialog
signal stopDialog#disables dialog for a npc
signal endGame#notifies of game completion

var currentID
var speaker setget ,getName
var text
var textMarker#keeps track of text progression
var choices
var action
var nextID setget ,getNextID
#dialog variables(for conditions)
var stats = {}

func setDefault() -> void:#default setup(resets node)
	currentID = ""
	speaker = ""
	text = []
	textMarker = 0
	choices = []
	action = []
	nextID = "end"
	
func setID(id:String):
	setDefault()#reset to default values
	if id in GameData.dialog:#legal dialog id
		currentID = id
		var dialogNode = GameData.dialog[id]
		if "name" in dialogNode:
			speaker = dialogNode.name
		if "text" in dialogNode:
			text = dialogNode.text
		if "action" in dialogNode:
			action = dialogNode.action
		if "choices" in dialogNode:
			choices = dialogNode.choices
		if "next" in dialogNode:
			nextID = dialogNode.next


func getNextText():#returns the next text string to display
	if textMarker < text.size():#more text to show
		var textSection = text[textMarker]
		textMarker += 1
		return textSection
	else:#finished text
		return ""
		
func getTextSectionsLeft():#how many left to display
	return text.size() - textMarker

#getter functions
func getName():
	return speaker
	
func getNextID():
	return nextID
	
func getChoices():
	var choiceArray = []
	for choice in choices:
		if !"show_if" in choice or testCondition(choice.show_if):#test condition first(if any)
			choiceArray.append([choice.text, choice.next])
	return choiceArray
	
func hasChoices() -> bool:#count only showable choices
	for choice in choices:
		if !"show_if" in choice or testCondition(choice.show_if):
			return true
	return false

func testCondition(condition:String) -> bool:
	var args = condition.split(" ")
	if args.size() != 3:
		print("Condition cannot be tested!")
		return false
	var v = args[0]
	var operator = args[1]
	var val = args[2]
	match operator:
		"==":#string comparison
			return v in stats and stats[v] == val
	return false#unexpected operator
		

func executeAction() -> void:
	for act in action:
		var args = act.split(" ")
		match args[0]:
			"emit_signal":
				match args.size():
					2:
						emit_signal(args[1])#signal with no parameters
					3:
						emit_signal(args[1], args[2])#(signal,param)
			"set":#add/update variable
				#set var value
				var v = args[1]
				var val= args[2]
				match val:
					"+":
						if v in stats:#update
							stats[v] = str(int(stats[v]) + 1)
						else:#assumes starting from 0, increment by 1
							stats[v]="1"
					"true","false":
						stats[v] = val


func getSaveData():#Persistent_Static
	return {"DialogData":stats}

func loadData(data:Dictionary):#Persistent_Static
	stats = data["DialogData"]

