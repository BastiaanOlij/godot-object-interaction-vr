tool
extends StaticBody

export (Material) var material = null setget set_material, get_material

func set_material(new_mat):
	material = new_mat
	if $MeshInstance:
		$MeshInstance.material_override = material
	if $MeshInstance2:
		$MeshInstance2.material_override = material

func get_material():
	return material

func _ready():
	set_material(material)
