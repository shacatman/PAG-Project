extends Node

#Defines the LevelSwitcher which adds and removes levels from the scene tree
onready var currentLevel = $DemoLevel #default level


# Called when the node enters the scene tree for the first time.
func _ready():
	currentLevel.setup()#setup the default level
	currentLevel.connect("levelchanged", self, "switchLevel")

# Load new level, remove current level.
func switchLevel(nextLevelIndex:int, comingFrom:String) -> void:
	var nextLevel = load("res://Levels/Level" + str(nextLevelIndex) + ".tscn").instance()
	add_child(nextLevel)
	nextLevel.setup(comingFrom)
	nextLevel.connect("levelchanged", self, "switchLevel")
	currentLevel.queue_free()
	currentLevel = nextLevel
