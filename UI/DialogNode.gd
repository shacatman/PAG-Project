extends Node

#Defines a DialogNode corresponding to an entry in the dialog json file
#Holds info of currentID,speaker(name),text(array),choices,action,nextID

signal dialogCheckpoint(newID)#signal to notify npc what to say next time

var currentID
var speaker setget ,getName
var text
var textMarker#keeps track of text progression
var choices
var action
var nextID setget ,getNextID


func setDefault() -> void:#default setup(resets node)
	currentID = ""
	speaker = ""
	text = []
	textMarker = 0
	choices = []
	action = null
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
		elif "next" in dialogNode:
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
		choiceArray.append([choice.text, choice.next])
	return choiceArray
	
func hasChoices() -> bool:
	return not choices.empty()
	
func executeAction() -> void:
	if action:#action string
		var args = action.split(" ")
		match args[0]:
			"emit_signal":
				emit_signal(args[1], args[2])

