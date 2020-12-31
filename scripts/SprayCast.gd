extends RayCast

onready var texture = load("res://textures/sprayblume.png")

func _physics_process(delta):
	if Input.is_action_pressed("mouse_left") and is_colliding():
		var collider = get_collider()
		print(collider.get_name())
		var global_position = get_collision_point()
		var normal = get_collision_normal()
		_on_sprayed(collider, global_position, normal)

func _on_sprayed(collision_object, collision_position, collider_normal):
	var tag = create_tag(collision_object)
	rotate_spray_to_collider_normal(tag, collider_normal)
	apply_spray_at_position(tag, collision_object, collision_position, collider_normal)
	

func create_tag(collision_object):
	var tag = Sprite3D.new()
	collision_object.add_child(tag)
	tag.texture = texture
	return tag

func rotate_spray_to_collider_normal(tag, collider_normal):
	var tag_front = Vector3(0,0,1)
	
	var axis = tag_front.cross(collider_normal)
	axis = axis.normalized()

	var cosa = tag_front.dot(collider_normal)
	var angle = acos(cosa)
	
	var rotated_global_transform = tag.transform.rotated(axis, angle)
	tag.set_global_transform(rotated_global_transform) 

func apply_spray_at_position(tag, collision_object, collision_position, collider_normal):
	var local_position = collision_object.to_local(collision_position)
	var normalized_normal = collider_normal.normalized()
	tag.transform.origin = local_position + (normalized_normal * 0.0001)

func luminescent_material():
	pass
	#var tag_material = SpatialMaterial.new()
#	tag_material.emission_enabled = true
#	tag_material.flags_transparent = true
	#tag_material.emission = Color(255,255,255,255)
	
	#tag_material.emission_texture = load("res://textures/sprayblume.png")
	#tag_material.albedo_color = Color(255,255,255,255)
	#tag_material.albedo_texture = load("res://textures/sprayblume.png")
	#tag.material_override = tag_material
