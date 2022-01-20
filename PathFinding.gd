extends Node2D

#Defines pathfinding setup for navigation using the Astar algorithm

class Astar:#internal class that implements trivial cost computation for Astar algorithm
	extends AStar2D
	func _compute_cost(from_id:int, to_id:int) -> float:
		return 1.0

var astar : = Astar.new()
var tileMap : TileMap
var half_cell_size : Vector2
var usedRect : Rect2 #path area

func _physics_process(delta):
	updateNavigationMap()


func createNavigationMap(tileMap : TileMap):
	self.tileMap = tileMap
	half_cell_size = tileMap.cell_size / 2
	usedRect = tileMap.get_used_rect()#rectangle enclosing the used (non-empty) tiles of the map.
	var tiles : Array = tileMap.get_used_cells()
	addTraversableTiles(tiles)
	connectTraversableTiles(tiles)
	

func addTraversableTiles(tiles : Array):
	for tile in tiles:
		var id = getIdForPoint(tile)
		astar.add_point(id, tile)
	
	
func connectTraversableTiles(tiles : Array):
	for tile in tiles:
		var id = getIdForPoint(tile)
		
		for x in range(-1, 2):
			for y in range(-1, 2):
				var target = tile + Vector2(x, y)
				var targetId = getIdForPoint(target)
				
				if tile == target or not astar.has_point(targetId):
					continue
				astar.connect_points(id, targetId)


func updateNavigationMap():#option to use with signals later
	for point in astar.get_points():
		astar.set_point_disabled(point, false)
		astar.set_point_weight_scale(point, 1.0)
	var obstacles=get_tree().get_nodes_in_group("obstacles")
	for obstacle in obstacles:
		if obstacle is TileMap:
			var tiles = obstacle.get_used_cells()
			for tile in tiles:
				var id = getIdForPoint(tile)
				if astar.has_point(id):
					astar.set_point_disabled(id, true)
		if obstacle is KinematicBody2D:
			var tileCoord = tileMap.world_to_map(tileMap.to_local(obstacle.global_position))
			for x in range(-1, 2):
				for y in range(-1, 2):
					var tile = tileCoord + Vector2(x, y)
					var id = getIdForPoint(tile)
					if astar.has_point(id):#calculate distance between obstacle and tile
						var worldPoint = tileMap.map_to_world(tile) + half_cell_size
						#the closer the obstacle is to the tile-the larger the weight
						if worldPoint.distance_to(obstacle.global_position) <= sqrt(2)*half_cell_size.x:
							var weight = 2*sqrt(2)*half_cell_size.x/worldPoint.distance_to(obstacle.global_position)
							astar.set_point_weight_scale(id,weight)

func getIdForPoint(point : Vector2) -> int:#simple hash
	var x = point.x - usedRect.position.x
	var y = point.y - usedRect.position.y
	return x + y * usedRect.size.x
	
	
func getNewPath(start : Vector2, end : Vector2) -> Array:
	var startTile = tileMap.world_to_map(start)
	var endTile = tileMap.world_to_map(end)
	var startId = getIdForPoint(startTile)
	var endId = getIdForPoint(endTile)
	
	if not astar.has_point(startId) or not astar.has_point(endId):
		print("invalid points")#for debug!!!!!!
		return []#no path
	var tilePath = astar.get_point_path(startId, endId)
	if tilePath.size()<1:#for debug!!!!!!
		print("can't find path",startTile,"  ",endTile,"	",tilePath)
	var worldPath = []
	for point in tilePath:
		var worldPoint = tileMap.map_to_world(point) + half_cell_size
		worldPath.append(worldPoint)
	return worldPath
	
	
