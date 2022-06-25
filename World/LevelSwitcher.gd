extends Node

#Defines the LevelSwitcher (Singleton) which adds and removes levels from the scene tree
var currentLevel = null
onready var root = get_tree().get_root()

# Called when the node enters the scene tree for the first time.
func _ready():
	currentLevel = root.get_child(root.get_child_count() - 1)#the starting scene
	if currentLevel.has_method("setup"):#actual levels
		currentLevel.setup()#setup the level
		currentLevel.connect("levelchanged", self, "switchLevel")
	GameData.currentLevel = currentLevel


# Load new level, remove current level.
func switchLevel(nextLevelIndex:int, comingFrom = null, saveState = true) -> void:

	if saveState:
		currentLevel.call_deferred("saveLevelData")
		yield(currentLevel,"dataSaved")#don't load next level until data is saved from current level
	var nextLevel = load("res://Levels/Level" + str(nextLevelIndex) + ".tscn").instance()
	root.add_child(nextLevel)
	nextLevel.setup(comingFrom)
	currentLevel.queue_free()
	yield(currentLevel,"tree_exited")#wait until previous level is freed from memory before loading the level for current data 
	nextLevel.loadLevelData(nextLevelIndex)
	nextLevel.connect("levelchanged", self, "switchLevel")
	currentLevel = nextLevel
	GameData.currentLevel = currentLevel
	
	
func titleScreen() -> void:#goes to title screen, does not save
	var title = load("res://UI/TitleScreen.tscn").instance()
	root.add_child(title)
	BackgroundMusic.stopMusic()
	currentLevel.queue_free()
	yield(currentLevel,"tree_exited")
	currentLevel = title
