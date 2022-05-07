tool
extends Area2D

# Defines a speakingNPC that can initiate dialog conversations with the player

export var dialogID = "default"#conversation opener(can be updated)
export(Texture) var sprite setget setSprite#to override default from editor

var player
onready var icon = $BubbleIcon

func _ready():
	if sprite:
		$Sprite.texture=sprite

func setSprite(newSprite):
	sprite = newSprite
	if !is_inside_tree():#avoid crash
		return
	$Sprite.texture = newSprite

#player nearby
func _on_SpeakingNPC_body_entered(body):
	player = body
	icon.show()
	if !player.is_connected("speak", self, "talk"):
		player.connect("speak", self, "talk")

#player is gone
func _on_SpeakingNPC_body_exited(body):
	if player.is_connected("speak", self, "talk"):
		player.disconnect("speak", self, "talk")
	icon.hide()

func talk():#initiate dialog with player
	#wait for signals until dialog ends
	Dialog.connect("dialogEnded", self, "waitForSignal", [false])
	waitForSignal(true)
	Dialog.startDialog(dialogID)

func updateID(newID):
	dialogID = newID
	
func waitForSignal(wait):
	var notifier = Dialog.currentDialog
	if wait:
		if !notifier.is_connected("dialogCheckpoint", self, "updateID"):
			notifier.connect("dialogCheckpoint", self, "updateID")
	else:
		if notifier.is_connected("dialogCheckpoint", self, "updateID"):
			notifier.disconnect("dialogCheckpoint", self, "updateID")

#save the dialog progression
func getSaveData():
	return {"dialogID":dialogID}

#load the dialog progression
func loadData(data : Dictionary):
	dialogID = data["dialogID"]
