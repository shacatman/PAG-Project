extends Node2D

#Defines Level setup
signal levelchanged(nextLevelIndex, comingFrom)


func setup(comingFrom = null) -> void:#called whenever a (new) level enters the scene tree
	var ground : TileMap = $GrassTile
	var pathFinding : Node2D = $PathFinding
	var companion = $YSort/Companion
	var companionSprite = $YSort/Companion/Sprite
	var player = $YSort/Player
	var playerSprite = $YSort/Player/Sprite
	pathFinding.createNavigationMap(ground)
	companion.pathFinding = pathFinding
	if comingFrom:#has specific spawn location
		var spawnpos = find_node(comingFrom)#the spwan position in the new level
		player.position = spawnpos.position
		companion.position = spawnpos.position
		match comingFrom:#fix sprite orientation when entering new level
			"North": 
				playerSprite.set_frame(0)
				companionSprite.set_frame(0)
			"South": 
				playerSprite.set_frame(2)
				companionSprite.set_frame(2)
			"East": 
				playerSprite.set_frame(3)
				companionSprite.set_frame(3)
			"West": 
				playerSprite.set_frame(1)
				companionSprite.set_frame(1)
	for levelchanger in get_tree().get_nodes_in_group("LevelChangers"):#connect signals for new level
		levelchanger.connect("body_entered", self, "_on_LevelChangeTile_body_entered", [levelchanger.nextLevelIndex, levelchanger.comingFrom])


func _on_LevelChangeTile_body_entered(body,nextLevel,comingFrom:String) -> void:
	emit_signal("levelchanged", nextLevel, comingFrom)#pass the next level info to the level switcher

