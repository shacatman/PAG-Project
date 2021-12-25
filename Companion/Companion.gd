extends KinematicBody2D

#Description_TODO
var velocity : = Vector2.ZERO
#var target = null
var pathFinding
var path : Array = []
onready var player : Player = $"../Player"#reference to player scene
onready var lineOfSight : RayCast2D = $LineOfSight
onready var collisionShape : CollisionShape2D = $CollisionShape2D

enum {#state machine
	IDLE,
	FOLLOW
}
var state=IDLE

## Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	match state:
		IDLE:
			velocity=Vector2.ZERO
		FOLLOW:
			followPlayer(delta)
			
	lineOfSight.look_at(player.global_position)
	if lineOfSight.get_collider() is Player:# and global_position.distance_to(player.global_position) > 30:
		state=FOLLOW
	else:#option to go to player's last known location
		state=IDLE

#	wander(unfinished-delayed for future update)
#		velocity=Vector2.ZERO
#		while target == null or global_position.distance_to(target) < 5:#find new target to wander to
#			var x : int = randi() % 80
#			var y : int = randi() % 80
##			target=Vector2(player.global_position.x+x-40,player.global_position.y+y-40)
#			target = Vector2(global_position.x + x - 40, global_position.y + y - 40)
#			var path : Array = pathFinding.getNewPath(global_position, target)
#			if path.size() > 1:
#				velocity = global_position.direction_to(path[1]) * 20 
#			else:
##				print("path not found(wander)")
#				target=null
#
#		move_and_slide(velocity)
#	pass

func followPlayer(delta)->void:
	var avoiding:bool=false
	path = pathFinding.getNewPath(global_position, player.global_position)
	if path.size() > 1:
		#path steering
		var desired_velocity : Vector2= global_position.direction_to(path[1]) * 40 
		if global_position.distance_to(player.global_position)<30:#40?
			#for now goes to idle state
#			desired_velocity*= global_position.distance_to(player.global_position)/80
			state=IDLE
			return
		elif path.size() > 2 and global_position.distance_to(path[1])<20:#skip close path points-smoother traversal
			desired_velocity = global_position.direction_to(path[2]) * 40
		var steering : Vector2 = desired_velocity - velocity
		steering=steering.clamped(15)#max steering force
		velocity = (velocity + steering).clamped(40)
		steering=Vector2.ZERO#reset steering
		#avoidance steering
		var space_state = get_world_2d().direct_space_state
		for i in range(-2,3):#steering rays at different angles
			var offset:Vector2=velocity.rotated(deg2rad(90)).normalized()
			var angleOffset:Vector2=velocity.rotated(deg2rad(30*i)).normalized()
			var result = space_state.intersect_ray(global_position, global_position+angleOffset*16, [self], collision_mask)
			if i !=0:#ignore axis parallel to velocity
				angleOffset= angleOffset.dot(offset)*offset
			if result:# and not result.collider is Player:
				avoiding=true
				steering-=angleOffset*20#*(1/(abs(i)+1)#proportion to distance from object???
				if i==0:
					var pushForce:Vector2 =(global_position -result.collider.global_position).normalized()
					pushForce= pushForce.dot(offset)*offset
					steering+= pushForce.normalized() *40#dont use normalized here?maybe doesnt matter?
			else:
				steering+=angleOffset*40#*(1/(abs(i)+1)

		if !avoiding:
			steering=Vector2.ZERO
		elif 1-abs(steering.normalized().dot(velocity.normalized()))<0.0001:#need to break symetry
			avoiding=false#reset boolean
			var positionOffset:Vector2=velocity.rotated(deg2rad(90)).normalized() * collisionShape.shape.radius
			for i in range(-1,2):
				var result = space_state.intersect_ray(global_position+i*positionOffset, global_position+i*positionOffset+velocity.normalized()*30, [self], collision_mask)#lineOfSight.cast_to.length()
				if result:
					avoiding=true
#					steering-= (i*positionOffset+velocity.normalized()*30).normalized()*250
					var pushForce:Vector2 =(global_position+i*positionOffset -result.collider.global_position).normalized()
					pushForce= pushForce.dot(positionOffset.normalized())*positionOffset.normalized()
					steering+= pushForce.normalized() *20#dont use normalized here?maybe doesnt matter?
				else:
					steering+= (i*positionOffset+velocity.normalized()*30).normalized()*40
			if !avoiding:
				steering=Vector2.ZERO
			elif 1-abs(steering.normalized().dot(velocity.normalized()))<0.0001:
				print("CHOSE RANDOM STEERING DIRECTION")#for debug
				#choose direction randomly
				if randi()%2==0:
					steering+=positionOffset.normalized()*40
				else:
					steering-=positionOffset.normalized()*40
				
		
		steering=steering.clamped(40)
		velocity = (velocity + steering).clamped(40)

		move_and_slide(velocity)

	else:#no path to the player is available
		state=IDLE
