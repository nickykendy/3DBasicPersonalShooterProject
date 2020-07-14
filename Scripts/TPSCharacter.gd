extends KinematicBody

export (float) var DefaultMoveSpd = 10
export (float) var SprintMoveSpd = 18
export (float) var CrouchMoveSpd = 5
export (float) var CrouchSpd = 20
export (float) var Acceleration = 5
export (float) var MouseSensitivity = 0.1
export (float) var Gravity = 9.8
export (float) var Jump = 3

var speed : float
var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var fall : Vector3 = Vector3()
var jumpNum : int = 0

onready var pivot = $Pivot
onready var gunPivot = $GunPivot

signal show_speed

func _ready():
	# hide the mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	# quit the game
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit(-1)
	# check mouse movement
	if event is InputEventMouseMotion:
		# horizontal rotate the character
		rotate_y(deg2rad(-event.relative.x * MouseSensitivity))
		# vertical rotate the character
		pivot.rotate_x(deg2rad(-event.relative.y * MouseSensitivity))
		pivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-60), deg2rad(60))
		# vertical rotate the gun
		gunPivot.rotate_x(deg2rad(-event.relative.y * MouseSensitivity))
		gunPivot.rotation.x = clamp(pivot.rotation.x, deg2rad(-60), deg2rad(60))
	
func _physics_process(delta):
	# reset speed
	speed = DefaultMoveSpd
	# reset direction
	direction = Vector3()
	# get input
	var _forward = Input.is_action_pressed("move_forward")
	var _backward = Input.is_action_pressed("move_backward")
	var _left = Input.is_action_pressed("move_left")
	var _right = Input.is_action_pressed("move_right")
	var _jump = Input.is_action_just_pressed("jump")
	# move forward and backward
	if _forward:
		direction -= transform.basis.z
	elif _backward:
		direction += transform.basis.z
	# move left and right
	if _left:
		direction -= transform.basis.x
	elif _right:
		direction += transform.basis.x
	# check if character is on the floor
	if not is_on_floor():
		fall.y -= Gravity * delta
	# reset jum num
	if is_on_floor():
		jumpNum = 0
	# jump once
	if _jump and is_on_floor() and jumpNum == 0:
		fall.y = Jump
		jumpNum = 1
	# jump twice
	if _jump and not is_on_floor() and jumpNum == 1:
		fall.y = Jump
		jumpNum = 2
	# move the character
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, Acceleration * delta)
	velocity = move_and_slide(velocity + fall, Vector3.UP, true, 4, 0.9, false)
	# emit
	emit_signal("show_speed", speed)
	
