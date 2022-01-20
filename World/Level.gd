extends Node2D

#Defines Level setup
onready var ground : TileMap = $GrassTile
onready var pathFinding : Node2D = $PathFinding
onready var companion = $YSort/Companion

# Called when the node enters the scene tree for the first time.
func _ready():
	pathFinding.createNavigationMap(ground)
	companion.pathFinding = pathFinding

