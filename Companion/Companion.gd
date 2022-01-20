extends KinematicBody2D

#Defines the Companion object: AI,State Machine and steering behavior
var velocity : = Vector2.ZERO
var state = IDLE
var target = null
var pathFinding
var path : Array = []
var stay : bool = false
var speed : = 40
onready var player : Player = $"../Player"#reference to player scene
onready var lineOfSight : RayCast2D = $LineOfSight
onready var collisionShape : CollisionShape2D = $CollisionShape2D
onready var sprite : = $Sprite

enum {#state machine
	IDLE,
	FOLLOW
}


## Called when the node enters the scene tree for the first time.
func _ready():
	randomize()


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_select"):#temporary solution? use F key for 'Freeze'?
		stay = !stay
		
	if !stay:#allowed to move
		state = FOLLOW
	else:
		state = IDLE
		
	match state:
		IDLE:
			velocity = Vector2.ZERO
		FOLLOW:
			if isPlayerInSight():
				target = player.global_position
				
			if target and global_position.distance_to(target) > 16:
				followTarget(delta, target)
			#sprite frame:	
			if abs(velocity.y) >abs(velocity.x):
				if velocity.y > 0:#going down
					sprite.set_frame(0)
				elif velocity.y < 0:
					sprite.set_frame(2)
			else:
				if velocity.x > 0:#going right
					sprite.set_frame(1)
				elif velocity.x < 0:
					sprite.set_frame(3)



func followTarget(delta, target) -> void:
	var avoiding : bool = false
	path = pathFinding.getNewPath(global_position, target)
	if path.size() >= 1:
		#path steering
		var desired_velocity : Vector2
		if path.size()!=1:
			desired_velocity = global_position.direction_to(path[1]) * speed 
		else:#target is on the same tile
			desired_velocity = global_position.direction_to(path[0]) * speed 
			
		if path.size()==1 or global_position.distance_to(target) < 30:#near target
			#slow near target:		
			desired_velocity*= global_position.distance_to(player.global_position)/40
			if velocity.x*desired_velocity.x<0 or velocity.y*desired_velocity.y<0:#don't switch directions,just stop
				state = IDLE
				return
		elif path.size() > 2 and global_position.distance_to(path[1]) < 20:#skip close path points-smoother traversal
			desired_velocity = global_position.direction_to(path[2]) * speed
		var steering : Vector2 = desired_velocity - velocity
		steering = steering.clamped(15)#max steering force
		velocity = (velocity + steering).clamped(speed)
		steering = Vector2.ZERO#reset steering
		
		#avoidance steering
		var space_state = get_world_2d().direct_space_state
		for i in range(-2, 3):#steering rays at different angles
			var offset : Vector2 = velocity.rotated(deg2rad(90)).normalized()
			var angleOffset : Vector2 = velocity.rotated(deg2rad(30 * i)).normalized()
			var result = space_state.intersect_ray(global_position, global_position + angleOffset * 16, [self], collision_mask)
			if i != 0:#ignore axis parallel to velocity
				angleOffset= angleOffset.dot(offset) * offset
			if result:
				avoiding = true
				steering -= angleOffset * 20#*(1/(abs(i)+1)#proportion to distance from object?
				if i == 0:
					var pushForce : Vector2 = (global_position - result.collider.global_position).normalized()
					pushForce = pushForce.dot(offset) * offset
					steering += pushForce.normalized() * 40#dont use normalized here?maybe doesnt matter?
			else:
				steering += angleOffset * 40#*(1/(abs(i)+1)

		if !avoiding:
			steering = Vector2.ZERO
		elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:#need to break symetry
			avoiding = false#reset boolean
			var positionOffset : Vector2 = velocity.rotated(deg2rad(90)).normalized() * collisionShape.shape.radius
			for i in range(-1, 2):
				var result = space_state.intersect_ray(global_position+i*positionOffset, global_position+i*positionOffset+velocity.normalized()*30, [self], collision_mask)
				if result:
					avoiding = true
#					steering-= (i*positionOffset+velocity.normalized()*30).normalized()*250
					var pushForce : Vector2 = (global_position+i*positionOffset -result.collider.global_position).normalized()
					pushForce = pushForce.dot(positionOffset.normalized())*positionOffset.normalized()
					steering += pushForce.normalized() * 20#dont use normalized here?maybe doesnt matter?
				else:
					steering += (i * positionOffset + velocity.normalized() * 30).normalized() * 40
			if !avoiding:
				steering = Vector2.ZERO
			elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:
				print("CHOSE RANDOM STEERING DIRECTION!!!!!")#for debug,possible not needed
				#choose direction randomly
				if randi() % 2 == 0:
					steering += positionOffset.normalized() * 40
				else:
					steering -= positionOffset.normalized() * 40
				
		steering = steering.clamped(40)
		velocity = (velocity + steering).clamped(speed)
		move_and_slide(velocity)
	else:#no path to the player is available
		print("CAN'T FIND PATH TO PLAYER")#for debug
		state = IDLE
#		stay=true

func isPlayerInSight() -> bool:
	lineOfSight.look_at(player.global_position)
	return lineOfSight.get_collider() is Player

