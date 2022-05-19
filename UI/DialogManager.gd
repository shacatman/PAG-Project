extends CanvasLayer

#Defines the Dialog UI management singleton
signal dialogStarted
signal dialogEnded

var talking = false#interact with dialog only when UI is open
onready var dialogUI = $DialogUI
onready var currentDialog = $DialogNode#stores relevant data per dialog node(from json file)
onready var nameBox = $DialogUI/VBoxContainer/NameBox
onready var textBox = $DialogUI/VBoxContainer/TextBox
onready var choices = $DialogUI/VBoxContainer/Choices


# Called when the node enters the scene tree for the first time.
func _ready():
	currentDialog.setDefault()
	#hide the UI until required
	dialogUI.hide()

func setDialogUI(id):#match the UI with dialog node data(with new id)
	if id == "end":#finished dialog for now
		endDialog()
	else:#some dialog block to show
		currentDialog.setID(id)#set data to correct id
		nameBox.text = currentDialog.speaker
		textBox.text = currentDialog.getNextText()
		#we want to show choices only on the last text element of the block
		if currentDialog.hasChoices() and currentDialog.getTextSectionsLeft() < 1:#that was all text
			createChoices()
		currentDialog.executeAction()#execute action of the current dialog node(if any)


#shows the UI when new dialog starts
func startDialog(id):
	setDialogUI(id)#initializes dialog node
	dialogUI.show()
	talking = true#enables interation within dialog
	emit_signal("dialogStarted")


func endDialog(): #hides UI again
	dialogUI.hide()
	talking = false
	emit_signal("dialogEnded")


func _input(event):
	if talking and event.is_action_pressed("ui_accept"):#input to progress dialog
		continueDialog()


func continueDialog():
	if currentDialog.getTextSectionsLeft() > 1:#got more text to show after
		textBox.text = currentDialog.getNextText()#set text in UI
	elif currentDialog.getTextSectionsLeft() == 1:#show choices with final text(if any)
		textBox.text = currentDialog.getNextText()#last text to show
		if currentDialog.hasChoices():
			#setup choices ui
			createChoices()
	else:#shown all text
		if not currentDialog.hasChoices():#not waiting for choice selection
			setDialogUI(currentDialog.nextID)#progress to next text 'block'


func createChoices():#set the UI buttons for choices
	#for every choice we need the text and nextID
	var choiceArray = currentDialog.getChoices()
	for choice in choiceArray:#choice is array of text,next
		var button = Button.new()
		button.text = choice[0]
		button.connect("pressed", self, "choiceSelected", [choice[1]])#pass the next id when pressed
		choices.add_child(button)
	choices.show()

#clear choices when one is selected
func choiceSelected(nextID):
	choices.hide()
	for button in choices.get_children():#delete the choices
		button.queue_free()
	setDialogUI(nextID)

