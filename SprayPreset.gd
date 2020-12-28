extends Node

const ray_length = 20
var material : SpatialMaterial
#var destination = Vector3()

func get_cursor_position():
	var mouse_position = get_viewport().get_mouse_position()
	var from = $Camera.project_ray_origin(mouse_position)
	var to = from + $Camera.project_ray_normal(mouse_position) * ray_length
	return Vector3(to.x, to.y, -1)

func spray():
#	var tag = load("res://scenes/Tag.tscn").instance()
#	$MeshInstance.visible = true
#	$MeshInstance.transform.origin = (get_cursor_position())
	var tag = Sprite3D.new()
	tag.transform.origin = get_cursor_position()
#	tag.rotation.z = -90
#	print(tag.transform.origin)
	tag.texture = load("res://textures/sprayblume.png")
	
	get_parent().add_child(tag)
#	var tree = get_tree()
#	var root = tree.get_root()
#	debug_tree(root)
	
#	tag.set_mesh(PlaneMesh.new())
#	tag.set_material_override(SpatialMaterial.new())
#	var texture = tag.get_material_override().albedo.texture
#	texture.load("res://textures/sprayblume.png")

func _process(delta):
	if(Input.is_action_just_pressed("mouse_left")):
		spray()

func debug_tree(node):
	if(node != null):
		print(node.name)
		for child in node.get_children():
			debug_tree(child)

