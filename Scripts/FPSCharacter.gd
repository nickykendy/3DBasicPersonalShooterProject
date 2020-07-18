extends KinematicBody

export (float) var DefaultMoveSpd = 7
export (float) var SprintMoveSpd = 14
export (float) var CrouchMoveSpd = 3
export (float) var CrouchSpd = 20
export (float) var Gravity = 9.8
export (float) var Acceleration = 20.0
export (float) var Jump = 5
export (float) var MouseSensitivity = 0.05
export (float) var BlinkDistance = 10

var speed : float
var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var fall : Vector3 = Vector3()
var jumpNum : int = 0
var defaultHeight : float = 1.5
var crouchHeight : float = 0.5
var bHeadBonked : bool  = false
var bSprinting : bool = false
var bCrouching : bool = false
var bWallRunnable : bool = false
var wallNormal : Object

onready var head = $Head
onready var charCap = $CollisionShape
onready var bonker = $HeadBonker
onready var sprintTimer = $SprintTimer
onready var wallRunTimer = $WallRunTimer
onready var aimCast = $Head/Camera/AimCast
onready var muzzle = $Head/Gun/Muzzle
onready var virtualPoint = $Head/VirtualPoint
onready var bullet = preload("res://Scenes/Bullet.tscn")

func _ready():
	pass
	
func _input(event):
	# hide mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# quit the game
	if Input.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# get mouse motion and rotate
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * MouseSensitivity))
		head.rotate_x(deg2rad(-event.relative.y * MouseSensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-60), deg2rad(60))

func _physics_process(delta):
	# reset speed
	speed = DefaultMoveSpd
	# reset direction
	direction = Vector3()
	# get input
	var _forward = Input.is_action_pressed("move_forward")
	var _back = Input.is_action_pressed("move_backward")
	var _right = Input.is_action_pressed("move_right")
	var _left = Input.is_action_pressed("move_left")
	var _jump = Input.is_action_just_pressed("jump")
	var _blink = Input.is_action_just_pressed("blink")
	var _crouch = Input.is_action_just_pressed("crouch")
	var _sprint = Input.is_action_just_pressed("sprint")
	var _fire = Input.is_action_just_pressed("fire")
	# wall running
	if bWallRunnable and _jump and _forward and is_on_wall():
		wallNormal = get_slide_collision(0)
		yield(get_tree().create_timer(0.2), "timeout")
		fall.y = 0
		direction = -wallNormal.normal * speed
	# apply gravity
	move_and_slide(direction + fall, Vector3.UP)
	# press fire to shoot
	if _fire:
		var targetPos = Vector3()
		if aimCast.is_colliding():
			targetPos = aimCast.get_collision_point()
		else:
			targetPos = virtualPoint.global_transform.origin
		var b = bullet.instance()
		muzzle.add_child(b)
		b.look_at(targetPos, Vector3.UP)
		b.shoot()
	# check bonked
	if bonker.is_colliding():
		bHeadBonked = true
	else:
		bHeadBonked = false
	# toggle crouch
	if _crouch and not bCrouching:
		bCrouching = true
		if bSprinting:
			bSprinting = false
	elif _crouch and bCrouching:
		bCrouching = false
	# crouch
	if bCrouching:
		charCap.shape.height -= CrouchSpd * delta
		speed = CrouchMoveSpd
	elif not bHeadBonked and not bCrouching:
		charCap.shape.height += CrouchSpd * delta
	charCap.shape.height = clamp(charCap.shape.height, crouchHeight, defaultHeight)
	# toggle sprint
	if _sprint and not bSprinting and not bCrouching:
		bSprinting = true
		sprintTimer.start()
	elif _sprint and bSprinting:
		bSprinting = false
	# set sprint speed
	if bSprinting:
		speed = SprintMoveSpd
	# move forward and back
	if _forward:
		direction -= transform.basis.z
		# blink forward
		if _blink:
			translate(Vector3(0, 0, -BlinkDistance))
	elif _back:
		direction += transform.basis.z
		# blink backword
		if _blink:
			translate(Vector3(0, 0, BlinkDistance))
	# move right and left
	if _left:
		direction -= transform.basis.x
		# blink left
		if _blink:
			translate(Vector3(-BlinkDistance, 0, 0))
	elif _right:
		direction += transform.basis.x
		# blink right
		if _blink:
			translate(Vector3(BlinkDistance, 0, 0))
	# reset jump num
	if is_on_floor():
		jumpNum = 0
	# falling
	if not is_on_floor():
		fall.y -= Gravity * delta
	else:
		bWallRunnable = false
	# jump once
	if _jump and is_on_floor() and jumpNum == 0:
		fall.y = Jump
		jumpNum = 1
		bWallRunnable = true
		wallRunTimer.start()
	# jump twice
	if _jump and not is_on_floor() and jumpNum == 1:
		fall.y = Jump
		jumpNum = 2
	# fix when head bonked
	if bHeadBonked:
		fall.y = -2
	# move the character
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, Acceleration * delta)
	velocity = move_and_slide(velocity + fall, Vector3.UP, true)

func _on_SprintTimer_timeout():
	bSprinting = false

func _on_WallRunTimer_timeout():
	bWallRunnable = false
