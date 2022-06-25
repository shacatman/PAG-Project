tool
extends Area2D

# Defines a speakingNPC that can initiate dialog conversations with the player

export var dialogID = "default"#conversation opener(can be updated)
export(String, "Speak", "Action") var type = "Speak"#character or object
export(String) var tag = "None"#to identify object from dialog
export(Texture) var sprite setget setSprite#to override default from editor

var player
var canSpeak = true
var icon

func _ready():
	match type:
		"Speak":
			icon = $SpeachIcon
		"Action":
			icon = $ActionIcon
	if sprite:
		$Sprite.texture = sprite
	if Dialog.is_inside_tree():#avoid errors in editor(tool script)
		Dialog.currentDialog.connect("removeObject", self, "remove")


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
func _on_SpeakingNPC_body_exited(_body):
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

func setSpeakingStatus(status = false):#used for disabling dialog
	canSpeak = status
	#enable/disable area detection
	if status:#enable-connect
		if !self.is_connected("body_entered", self, "_on_SpeakingNPC_body_entered"):
			self.connect("body_entered", self, "_on_SpeakingNPC_body_entered")
		if !self.is_connected("body_exited", self, "_on_SpeakingNPC_body_exited"):
			self.connect("body_exited", self, "_on_SpeakingNPC_body_exited")
	else:#disconnect
		if self.is_connected("body_entered", self, "_on_SpeakingNPC_body_entered"):
			self.disconnect("body_entered", self, "_on_SpeakingNPC_body_entered")
		if player and player.is_connected("speak", self, "talk"):#don't wait for player dialog initiation
			player.disconnect("speak", self, "talk")
		if self.is_connected("body_exited", self, "_on_SpeakingNPC_body_exited"):
			self.disconnect("body_exited", self, "_on_SpeakingNPC_body_exited")


func waitForSignal(wait):
	var notifier = Dialog.currentDialog
	if wait:#wait for possible signals
		if !notifier.is_connected("dialogCheckpoint", self, "updateID"):
			notifier.connect("dialogCheckpoint", self, "updateID")
		if !notifier.is_connected("stopDialog", self, "setSpeakingStatus"):
			notifier.connect("stopDialog", self, "setSpeakingStatus")
	else:#dialog ended,stop waiting for signals
		if notifier.is_connected("dialogCheckpoint", self, "updateID"):
			notifier.disconnect("dialogCheckpoint", self, "updateID")
		if notifier.is_connected("stopDialog", self, "setSpeakingStatus"):
			notifier.disconnect("stopDialog", self, "setSpeakingStatus")
		if Dialog.is_connected("dialogEnded", self, "waitForSignal"):
			Dialog.disconnect("dialogEnded", self, "waitForSignal")

func remove(object:String):
	if object == tag:#match tag of object to remove
		setSpeakingStatus(false)
		visible = false

#save the dialog progression
func getSaveData():
	return {"dialogID":dialogID, "canSpeak":canSpeak,"visible":visible}

#load the dialog progression
func loadData(data : Dictionary):
	dialogID = data["dialogID"]
	if !data["visible"]:#removed
		remove(tag)
	else:#dialog disabled
		setSpeakingStatus(data["canSpeak"])
