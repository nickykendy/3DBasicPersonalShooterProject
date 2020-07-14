extends KinematicBody

export (Vector3) var Destination = Vector3(48, 10, 5)
export (float) var Speed = 15

var direction : Vector3

func _process(delta):
	direction = Vector3()
	if Destination.distance_to(transform.origin) > 0.1:
		direction = Destination - transform.origin
		direction = direction.normalized() * Speed
	else:
		direction = Destination - transform.origin
	move_and_slide(direction)
