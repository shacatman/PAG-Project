extends KinematicBody2D

#Defines the Companion object: AI,State Machine and steering behavior

var velocity : = Vector2.ZERO
var state = IDLE
var target = null
var pathFinding
var path : Array = []
var stay : bool = false
var speed : = 40
onready var wanderTimer : Timer = $WanderTimer
onready var cooldownTimer : Timer = $CoolDown#cooldown to avoid wandering after commands
onready var player : Player = $"../Player"#reference to player scene
onready var lineOfSight : RayCast2D = $LineOfSight
onready var collisionShape : CollisionShape2D = $CollisionShape2D
onready var sprite : = $Sprite
onready var prevPos : Vector2 = global_position

enum {#state machine
	IDLE,
	FOLLOWPLAYER
	FOLLOWTARGET
	WANDER
}


## Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	state = FOLLOWPLAYER#default state
	$ConfirmSound.stream = null
	$Commands.onIdPressed(0)#disable follow command initially
	$ConfirmSound.stream = preload("res://Audio/Recording.wav")

# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	prevPos = global_position#keep track of current position

	match state:
		IDLE:
			velocity = Vector2.ZERO
			#option to change to wander state:
			if !stay and wanderTimer.is_stopped() and cooldownTimer.is_stopped():#can move and not waiting to move
				wanderTimer.wait_time = int(rand_range(4, 10))#wait until movement(random time duration)
				wanderTimer.start()
				yield(wanderTimer, "timeout")#continue once timer finished
				if state == IDLE and !stay and cooldownTimer.is_stopped():#now is time to move(and still can)
					state = WANDER
					target = null#new target will be picked in wander state
		
		WANDER:	
			var space = get_world_2d().get_direct_space_state()
			while !target:#pick random point nearby
				var x = rand_range(global_position.x - 40, global_position.x + 40)
				var y = rand_range(global_position.y - 40, global_position.y + 40)
				target = Vector2(x, y)
				#if no clear (and visible) path try again with another point
				if space.intersect_point(target, 1, [], collision_mask) or pathFinding.getNewPath(global_position, target).size()<1:
					target = null
			#once picked target-move towards it
			followTarget(delta, target)
			if global_position.distance_to(prevPos) < 0.2:#didn't move much-stop trying
				state = IDLE
		
		FOLLOWPLAYER, FOLLOWTARGET:
			if state == FOLLOWPLAYER and isPlayerInSight():#set relevant target if following player
				if not target and not $ConfirmSound.playing and global_position.distance_to(player.global_position) > 30:#sees player after losing line of sight
					$ConfirmSound.play()
				target = player.global_position
			
			#do not follow targets if within close proximity
			if target and global_position.distance_to(target) > 23 and state == FOLLOWPLAYER:
				followTarget(delta, target)
			elif target and global_position.distance_to(target) > 10 and state == FOLLOWTARGET:
				followTarget(delta, target)
			else:
				target = null
				
			if state == FOLLOWTARGET and global_position.distance_to(prevPos) < 0.1:#didn't move much-stop trying (probably partially blocked path)
				state = IDLE
				
	#drawing sprite frame:	
	if abs(velocity.y) > abs(velocity.x):
		if velocity.y > 0:#going down
			sprite.set_frame(0)
		elif velocity.y < 0:
			sprite.set_frame(2)
	else:
		if velocity.x > 0:#going right
			sprite.set_frame(1)
		elif velocity.x < 0:
			sprite.set_frame(3)



func _on_Commands_newCommand(id, params = null):#recieved new command via signal
	match id:
		0:#FOLLOWPLAYER toggle
			if state != FOLLOWPLAYER:
				state = FOLLOWPLAYER
			stay = false
			target = null#no target initially(reset target)
			
		1:#STAY
			state = IDLE
			stay = true
			
		2:#Go To
			cooldownTimer.start()#start/restart cooldown until companion can start wandering again
			state = FOLLOWTARGET
			#params is the target position
			target = params
			stay = false
			if not $ConfirmSound.playing and pathFinding.getNewPath(global_position, target).size()>0:
				$ConfirmSound.play()#command received indication
			
		3:#DIG
			cooldownTimer.start()#do not wander while digging


func followTarget(_delta, target) -> void:
	var avoiding : bool = false
	path = pathFinding.getNewPath(global_position, target)
	if path.size() >= 1:
		#path steering
		var desired_velocity : Vector2
		if path.size() != 1:
			desired_velocity = global_position.direction_to(path[1]) * speed 
		else:#target is on the same tile-aim for exact target
			desired_velocity = global_position.direction_to(target) * speed 
			
		if path.size() <= 2:#slow near target(2 tile distance at most)		
			desired_velocity *= (global_position.distance_to(target) / 60) * 0.9 + 0.2
		elif path.size() > 2 and global_position.distance_to(path[1]) < 20:#skip close path points-for smoother traversal
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
				angleOffset = angleOffset.dot(offset) * offset
			if result:
				avoiding = true
				steering -= angleOffset * 5
				if i == 0:
					var pushForce : Vector2 = (global_position - result.collider.global_position).normalized()
					pushForce = pushForce.dot(offset) * offset
					steering += pushForce.normalized() * 10
			else:
				steering += angleOffset * 10

		if !avoiding:#no collisions detected
			steering = Vector2.ZERO
		elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:#need to break symetry if steering is parallel- try with parallel rays from edges
			avoiding = false#reset boolean
			var positionOffset : Vector2 = velocity.rotated(deg2rad(90)).normalized() * collisionShape.shape.radius
			for i in range(-1, 2):
				var result = space_state.intersect_ray(global_position + i * positionOffset, global_position + i * positionOffset + velocity.normalized() * 30, [self], collision_mask)
				if result:
					avoiding = true
					var pushForce : Vector2 = (global_position + i * positionOffset - result.collider.global_position).normalized()
					pushForce = pushForce.dot(positionOffset.normalized()) * positionOffset.normalized()
					steering += pushForce.normalized() * 5
				else:
					steering += (i * positionOffset + velocity.normalized() * 30).normalized() * 10
			
			if !avoiding:#no collisions detected
				steering = Vector2.ZERO
			elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:#steering stil parallel to velocity- just pick random direction
#				print("CHOSE RANDOM STEERING DIRECTION!!!!!")#for debug
				#choose direction randomly
				if randi() % 2 == 0:
					steering += positionOffset.normalized() * 10
				else:
					steering -= positionOffset.normalized() * 10
				
		steering = steering.clamped(25)#max steering force
		if global_position.distance_to(target) > 16:#don't avoid collisions if target is nearby
			velocity = (velocity + steering).clamped(speed)
		move_and_slide(velocity)
		
	else:#no path to the target is available
		if state != WANDER:
			if not $ConfusedSound.playing:
				$ConfusedSound.play()
		state = IDLE


func isPlayerInSight() -> bool:#check that there is a direct line of sight to the player
	lineOfSight.look_at(player.global_position)
	return lineOfSight.get_collider() is Player

func getSaveData():#Persistent_Static
	return {"CompanionPos": [global_position.x, global_position.y], "CompanionFrame" : sprite.frame}
	
func loadData(data : Dictionary):#Persistent_Static
	global_position.x = float(data["CompanionPos"][0])
	global_position.y = float(data["CompanionPos"][1])
	sprite.set_frame(int(data["CompanionFrame"]))

