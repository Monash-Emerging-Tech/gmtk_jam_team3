extends Line2D

@export var snake_length : int = 5

func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	%head.move_and_collide(get_global_mouse_position() - %head.global_position)
