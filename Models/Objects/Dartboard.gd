extends Area

var scores = [ 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5, 20 ]
var total = 0 

func _get_slice_score(point2d):
	var one3d = $One.transform.origin
	var one2d = Vector2(one3d.x, one3d.y)
	
	var angle = point2d.angle_to(one2d)
	var slice = floor(20.0 * angle / (2.0 * PI))
	if slice < 0:
		slice += 20;
	
	return scores[slice]

func _on_Dartboard_body_entered(body):
	# we always know that our body is a dart
	
	# we are going to check the angle between our dart and the dartboard
	var dartboard_normal = global_transform.basis.z
	var dart_direction = body.global_transform.basis.z
	
	# dot product of two unit vectors gives us the cosine of the angle between the two vectors
	var dot = dartboard_normal.dot(dart_direction)
	
	# just to make it easier to read
	var angle = rad2deg(acos(dot))
	if angle < 45:
		# Change the rigid body mode 
		body.mode = RigidBody.MODE_STATIC
		
		# we cheat because we know this is our dart
		var point = body.get_node('Point').global_transform.origin
		point = global_transform.xform_inv(point)
		
		# we simply adjust our darts position based on its local depth
		body.global_transform.origin += -point.z * dartboard_normal
		
		# figure out where we hit our dartboard
		var point2d = Vector2(point.x, point.y)
		var dist_from_center = point2d.length()
		var score = 0
		
		if dist_from_center < 0.01:
			# red bullseye
			score = 50
		elif dist_from_center < 0.021:
			# green bullseye
			score = 25
		elif dist_from_center < 0.115:
			# normal
			score = _get_slice_score(point2d)
		elif dist_from_center < 0.128:
			# first small ring
			score = 3 * _get_slice_score(point2d)
		elif dist_from_center < 0.191:
			# normal
			score = _get_slice_score(point2d)
		elif dist_from_center < 0.204:
			# second small ring
			score = 2 * _get_slice_score(point2d)
		else:
			# no score
			score = 0
		
		total += score
		
		var info = "Score: " + str(score) + "\n"
		info += "Total: " + str(total)
		
		$Scoreboard.get_scene_instance().get_node('Score').text = info

