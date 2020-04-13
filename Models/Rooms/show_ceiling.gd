extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	# we're hiding the ceiling to make it easier to edit the rooms
	$Ceiling.visible = true
