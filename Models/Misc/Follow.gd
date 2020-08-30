extends Spatial

export var enabled = true
export var max_distance = 0.5
export var impulse_factor = 5.0
export var max_impulse = 1.0

var move_step = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Position our kinematic body where our spatial node currently is
	$Float/FollowBody.global_transform = global_transform
	
	move_step = $Float/FollowBody/CollisionShape.shape.radius * 2.0

func _physics_process(_delta):
	if !enabled:
		return
	
	# this is how far we need to move to get this into position
	var move : Vector3 = global_transform.origin - $Float/FollowBody.global_transform.origin
	var move_len : float = move.length()
	
	if move_len > max_distance:
		# if we're this far away we'll just snap back into position
		$Float/FollowBody.global_transform = global_transform
	elif move_len > 0.0:
		# we always copy our basis
		$Float/FollowBody.global_transform.basis = global_transform.basis
		
		move = move.normalized()
		while move_len > 0.0:
			var move_part : Vector3 = move * (move_step if move_step < move_len else move_len)
			move_len = (move_len - move_step) if move_step < move_len else 0.0
			
			# but now try and move to this position
			var collider : KinematicCollision = $Float/FollowBody.move_and_collide(move_part, false)
			if collider and collider.collider is RigidBody:
				# We have potentially moved some distance, see how much movement is remaining
				move = global_transform.origin - $Float/FollowBody.global_transform.origin
				move_len = move.length()
				
				# we collided, apply a small force to that object
				var collided_with : RigidBody = collider.collider
				
				var strength = clamp(move_len * impulse_factor, 0.0, max_impulse)
				collided_with.apply_impulse(collider.position - collided_with.global_transform.origin, move.normalized() * strength)
				
				return
