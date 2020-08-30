extends Area

export (NodePath) var pivot = null setget set_pivot
var pivot_node = null
var pivot_transform = Transform()

enum ROTATE_TYPE { ROTATE_X, ROTATE_Y, ROTATE_Z }
export (ROTATE_TYPE) var rotate_type = ROTATE_TYPE.ROTATE_Y
export var min_rotation = 0
export var max_rotation = 120

export (bool) var press_to_hold = true

onready var min_rotrad = deg2rad(min_rotation)
onready var max_rotrad = deg2rad(max_rotation)

# Who picked us up?
var picked_up_by = null
var pick_up_delta = Vector3()
var by_controller : ARVRController = null
var closest_count = 0

var start_position

func set_pivot(new_pivot):
	pivot = new_pivot
	if pivot:
		pivot_node = get_node(pivot)
		if pivot_node:
			pivot_transform = pivot_node.global_transform
			start_position = pivot_transform.xform_inv(global_transform.origin)
	else:
		pivot_node = null

# have we been picked up?
func is_picked_up():
	if picked_up_by:
		return true
	
	return false

func _update_highlight():
	$highlighted.visible = closest_count > 0 

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
	
	# reset this now that we're ready
	set_pivot(pivot)

func _process(_delta):
	if pivot_node:
		var v1 : Vector3 = start_position
		var v2 : Vector3 = pivot_transform.xform_inv(picked_up_by.global_transform.origin - pick_up_delta)
		var rot : Basis = Basis()
		
		if rotate_type == ROTATE_TYPE.ROTATE_X:
			v1.x = 0.0
			v2.x = 0.0
		elif rotate_type == ROTATE_TYPE.ROTATE_Y:
			v1.y = 0.0
			v2.y = 0.0
		elif rotate_type == ROTATE_TYPE.ROTATE_Z:
			v1.z = 0.0
			v2.z = 0.0
		
		v1 = v1.normalized()
		v2 = v2.normalized()
		
		var angle = acos(v1.dot(v2))
		var adj_angle = angle
		var cross = v1.cross(v2).normalized()
		if cross.y >= 0.0:
			adj_angle = 2 * PI - angle
			
		print("Angle : " + str(rad2deg(adj_angle)))
		
		if adj_angle >= min_rotrad and adj_angle <= max_rotrad:
			pivot_node.transform.basis = rot.rotated(cross, angle)

