extends Position3D

export var time_scale = 1.0;

var move = 1

func _physics_process(delta):
	if move == 1:
		rotation_degrees.y += delta * time_scale
	
	if Input.is_action_just_pressed("RMB"):
		move *= -1
