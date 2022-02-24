extends Area2D

#Defines the LevelChangeTile information used for changing levels
export (String, "None", "North", "East", "South", "West") var comingFrom
export (int) var nextLevelIndex = -1

