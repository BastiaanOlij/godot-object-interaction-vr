extends Area

export (bool) var press_to_hold = true
export var impulse_factor = 1.0
export var max_impulse = 1.0

# Who picked us up?
var picked_up_by = null
var pick_up_delta = Vector3()
var by_controller : ARVRController = null
var closest_count = 0

# have we been picked up?
func is_picked_up():
	if picked_up_by:
		return true
	
	return false
	
func _update_highlight():
	pass
	
func increase_is_closest():
	closest_count += 1
	_update_highlight()

func decrease_is_closest():
	closest_count -= 1
	_update_highlight()

# we are being picked up by...
func pick_up(by, with_controller):
	if picked_up_by == by:
		return
	
	if picked_up_by:
		let_go()
	
	# remember who picked us up
	picked_up_by = by
	by_controller = with_controller
	pick_up_delta = by.global_transform.origin - global_transform.origin
	
	set_process(true)

# we are being let go
func let_go(_starting_linear_velocity = Vector3(0.0, 0.0, 0.0)):
	if picked_up_by:
		# we are no longer picked up
		picked_up_by = null
		by_controller = null
		
		# have to change this and let the door swing
		
		set_process(false)

func _ready():
	set_process(false)

func _process(_delta):
	var parent = get_parent()
	if by_controller and parent is RigidBody:
		var impulse_position = by_controller.global_transform.origin - pick_up_delta
		var direction = impulse_position - global_transform.origin
		
		var strength = clamp(direction.length() * impulse_factor, 0.0, max_impulse)
		
		parent.apply_impulse(impulse_position, direction.normalized() * strength)
		
		

