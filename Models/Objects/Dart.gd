extends "res://addons/godot-xr-tools/objects/Object_pickable.gd"

onready var last_position = global_transform.origin
var impulse_factor = 5.0

func _physics_process(delta):
	var new_position = global_transform.origin
	var movement = new_position - last_position
	last_position = new_position
	
	if !is_picked_up() and movement.length() > 0.001:
		var forward = global_transform.basis.z
		# dot product is 0.0 if perpendicular and 1.0 or -1.0 if parallel
		var dot_inv = 1.0 - abs(forward.dot(movement.normalized()))
		
		var impulse = -movement * dot_inv * impulse_factor
		
		apply_impulse($Fins.global_transform.origin - new_position, impulse)
