extends Area2D

#Defines the NpcCatcher which is a target area for an npc(Runner object) of matching type(color)

export(int) var npcGoal = 0
export (String, "None", "Red", "Green", "Blue", "Yellow") var type#match with runner's types
onready var barrier = $Barrier
onready var size = $CollisionShape2D.shape.extents

func _on_NpcCatcher_body_entered(body):
	if type == 'None' or body.type == 'None' or type == body.type:#types either match or are irrelevant
		#make the runner stop at random position inside the catcher area(will stop moving afterwards)
		body.stay = true
		var posx = global_position.x + rand_range(-size.x/2, size.x/2) * scale.x
		var posy = global_position.y + rand_range(-size.y/2, size.y/2) * scale.y
		body.sleepPos = Vector2(posx, posy)
		npcGoal -= 1
		if npcGoal == 0:#full capacity
			barrier.queue_free()
			barrier = null
