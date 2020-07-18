extends RigidBody

export var damage : float = 50
export var speed : float = 10

var bShoot = false

func _ready():
	set_as_toplevel(true)

func _physics_process(delta):
	if bShoot:
		apply_impulse(transform.basis.z, -transform.basis.z * speed)

func shoot():
	bShoot = true
	
func _on_Area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		queue_free()
	else:
		queue_free()

func _on_Timer_timeout():
	queue_free()
