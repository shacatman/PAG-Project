extends Node

#Defines the GameData singelton which stores all important game data during runtime in dictionary form

var info = {}
var currentLevel = null#updated by the LevelSwitcher singleton


func saveGame():#save the info to a file
	currentLevel.saveLevelData()#update the progress in the current level
	info["level"] = currentLevel.name.replace("Level", "")#the index of current level
	
	var persistentNodes = get_tree().get_nodes_in_group("Persistent_Static")
	for node in persistentNodes:#info that should be saved only once(not per level)
		var nodeData:Dictionary = node.getSaveData()
		info[node.name] = nodeData
	
	var file = File.new()
	var error = file.open_encrypted_with_pass("user://savegame.json", File.WRITE, "PAGpag953%+q")
	if error == OK:
		var json = to_json(info)
		file.store_line(json)
	else:
		print("Error opening file!")
	file.close()
	
	
func loadGame():#load the game from the file
	var file = File.new()
	if file.file_exists("user://savegame.json"):
		var error = file.open_encrypted_with_pass("user://savegame.json", File.READ, "PAGpag953%+q")
		if error == OK:
			info = parse_json(file.get_as_text())
			LevelSwitcher.switchLevel(int(info["level"]), null,  false)#don't save current state
			var persistentNodes = get_tree().get_nodes_in_group("Persistent_Static")
			for node in persistentNodes:
				node.loadData(info[node.name])#all needed data from every persistent node
		else:
			print("Error opening the file")
		file.close()
	else:
		print("File doesn't exists")
