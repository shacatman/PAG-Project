extends KinematicBody2D

#Defines the Runner object: AI,State Machine and steering behavior

export (String, "None", "Red", "Green", "Blue", "Yellow") var type#match with NpcCatcher type
export(Color) var trailColor


var velocity : = Vector2.ZERO
var state = IDLE
var target = null
var stay : bool = false
var speed : = 60
var detectedArray : Array = []
var sleepPos = null
onready var player = preload("res://Player/Player.gd")#reference to player scene
onready var companion = preload("res://Companion/Companion.gd")#reference to companion scene
onready var lineOfSight : RayCast2D = $LineOfSight
onready var detectionArea : Area2D = $Area2D
onready var collisionShape : CollisionShape2D = $CollisionShape2D
onready var sprite : = $Sprite
onready var prevPos : Vector2 = global_position
onready var trail : Line2D = $Line2D
onready var wanderTimer : Timer = $WanderTimer

enum {#state machine
	IDLE,
	FLEE
	WANDER
}


## Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	trail.default_color = trailColor


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for body in detectedArray:#check potential threats
		if !stay and isInSight(body):#threat exists
			state = FLEE
			break#no need to look for more threats
		elif state == FLEE:#no threat anymore-calm down (unless another threat is found in next iterations)
			state=IDLE

	match state:
		IDLE:
			if stay and global_position.distance_to(sleepPos) > 5:#go to resting position
				followTarget(delta, sleepPos)
			else:#stay in place
				velocity = Vector2.ZERO
			if !stay and wanderTimer.is_stopped():#wander if possible
				wanderTimer.wait_time = int(rand_range(10, 15))
				wanderTimer.start()
				yield(wanderTimer,"timeout")#continue once timer finished
				if state == IDLE and !stay:#can still wander
					state = WANDER
					target = null#reset target
		WANDER:
			prevPos = global_position
			var space = get_world_2d().get_direct_space_state()
			while !target:#if no target pick random target nearby
				var x = rand_range(global_position.x - 30, global_position.x + 30)
				var y = rand_range(global_position.y - 30, global_position.y + 30)
				target = Vector2(x,y)
				if space.intersect_point(target, 1, [], collision_mask):#if target not in clear area(inside solid block),try again
					target = null
			followTarget(delta,target)
			if global_position.distance_to(prevPos) < 0.2:#didn't move much-stop trying
				velocity = Vector2.ZERO
				state = IDLE
		FLEE:
			if !stay:#not in sleeping position-need to escape
				flee(delta)
			else:#sleeping-not scared anymore
				state = IDLE

	#sprite frame:	
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
	#trail drawing(when moving)
	if state != IDLE or velocity != Vector2.ZERO:
		trail.drawline()



func followTarget(delta, target) -> void:
	var avoiding : bool = false
	var desired_velocity : Vector2 = global_position.direction_to(target) * speed 
	
	if  global_position.distance_to(target) < 30:#near target
		#slow near target:		
		desired_velocity *= (global_position.distance_to(target)/30) * 0.8 + 0.2
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
			steering -= angleOffset * 10
			if i == 0:
				var pushForce : Vector2 = (global_position - result.collider.global_position).normalized()
				pushForce = pushForce.dot(offset) * offset
				steering += pushForce.normalized() * 20
		else:
			steering += angleOffset * 20

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
				steering += pushForce.normalized() * 10
			else:
				steering += (i * positionOffset + velocity.normalized() * 30).normalized() * 20
		
		if !avoiding:
			steering = Vector2.ZERO
		elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:
#			print("CHOSE RANDOM STEERING DIRECTION!!!!!")#for debug
			#choose direction randomly
			if randi() % 2 == 0:
				steering += positionOffset.normalized() * 20
			else:
				steering -= positionOffset.normalized() * 20
			
	steering = steering.clamped(25)#max steering force
	if global_position.distance_to(target) > 16:#don't avoid collisions if target is nearby
		velocity = (velocity + steering).clamped(speed)
	move_and_slide(velocity)


func flee(delta) -> void:
	var avoiding : bool = false
	var desired_velocity : Vector2 = Vector2.ZERO
	if detectedArray.empty():#slow down after escaping
		desired_velocity = velocity * 0.8
		if velocity.length() < 1:
			state = IDLE
	else:#flee steering
		for body in detectedArray:
			if isInSight(body):
				desired_velocity += body.global_position.direction_to(global_position) * speed
	var steering : Vector2 = desired_velocity - velocity
	steering = steering.clamped(15)#max steering force
	velocity = (velocity + steering).clamped(speed)
	steering = Vector2.ZERO#reset steering
	
	#collision avoidance steering(similar to companion)
	var space_state = get_world_2d().direct_space_state
	for i in range(-2, 3):#steering rays at different angles
		var offset : Vector2 = velocity.rotated(deg2rad(90)).normalized()
		var angleOffset : Vector2 = velocity.rotated(deg2rad(30 * i)).normalized()
		var result = space_state.intersect_ray(global_position, global_position + angleOffset * 16, [self], collision_mask)
		if i != 0:#ignore axis parallel to velocity
			angleOffset = angleOffset.dot(offset) * offset
		if result:
			avoiding = true
			steering -= angleOffset * 40
			if i == 0:#reflect the steering vector from the collider surface
				var reflect : Vector2 = (result.collider.global_position - global_position).reflect(result.normal)
				
				steering += reflect.normalized() * 40
		else:
			steering += angleOffset * 80

	if !avoiding:
		steering = Vector2.ZERO
	elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:#need to break symetry
		avoiding = false#reset boolean
		var positionOffset : Vector2 = velocity.rotated(deg2rad(90)).normalized() * collisionShape.shape.radius
		for i in range(-1, 2):
			var result = space_state.intersect_ray(global_position + i * positionOffset, global_position + i * positionOffset + velocity.normalized() * 30, [self], collision_mask)
			if result:
				avoiding = true
				var pushForce : Vector2 = (global_position + i * positionOffset - result.collider.global_position).normalized()
				pushForce = pushForce.dot(positionOffset.normalized()) * positionOffset.normalized()
				steering += pushForce.normalized() * 40
			else:
				steering += (i * positionOffset + velocity.normalized() * 30).normalized() * 80
		if !avoiding:
			steering = Vector2.ZERO
		elif 1 - abs(steering.normalized().dot(velocity.normalized())) < 0.0001:
#			print("CHOSE RANDOM STEERING DIRECTION!!!!!")#for debug
			#choose direction randomly
			if randi() % 2 == 0:
				steering += positionOffset.normalized() * 80
			else:
				steering -= positionOffset.normalized() * 80
			
	steering = steering.clamped(55)
	velocity = (velocity + steering).clamped(speed)
	move_and_slide(velocity)


func isInSight(object) -> bool:
	var space = get_world_2d().direct_space_state
	var result = space.intersect_ray(global_position, object.global_position, [self], lineOfSight.collision_mask)
	if result:
		if result.collider.name == "Player" or result.collider.name == "Companion":
			return true
	return false


func _on_detectionArea_body_entered(body):#either player or companion within detection area
	detectedArray.append(body)


func _on_detectionArea_body_exited(body):#either player or companion left detection area
	detectedArray.erase(body)

func getSaveData():
	return {"posx" : position.x, "posy" : position.y}

func loadData(data : Dictionary):
	position.x = data["posx"]
	position.y = data["posy"]

