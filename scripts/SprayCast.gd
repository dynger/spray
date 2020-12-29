extends RayCast

#signal sprayed(position, normal)

func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_left") and is_colliding():
		var collider = get_collider()
		print(collider.get_name())
		var global_position = get_collision_point()
#		var local_position = global_position - collider.transform.origin
#		print(collider.transform.basis.get_rotation_quat())
		var normal = get_collision_normal()
		#print(location)
		#print(normal)
#		emit_signal("sprayed", location, normal)
		_on_sprayed(collider, global_position, normal)

func _on_sprayed(object, collision_position, collider_normal):
	var tag = Sprite3D.new()
	object.add_child(tag)
	rotate_spray_to_collider_normal(tag, collider_normal)
	tag.texture = load("res://textures/sprayblume.png")
	var local_position = object.to_local(collision_position)
	tag.transform.origin = local_position# * collider_normal.normalized() * 1.01
	

func rotate_spray_to_collider_normal(tag, collider_normal):
	print(collider_normal)
	var tag_front = Vector3(0,0,1)
	
	var axis = tag_front.cross(collider_normal)
	axis = axis.normalized()

	var cosa = tag_front.dot(collider_normal)
	var angle = acos(cosa)
	
	var rotated_global_transform = tag.transform.rotated(axis, angle)
	
	tag.set_global_transform(rotated_global_transform) 

func luminescent_material():
	#var tag_material = SpatialMaterial.new()
#	tag_material.emission_enabled = true
#	tag_material.flags_transparent = true
	#tag_material.emission = Color(255,255,255,255)
	
	#tag_material.emission_texture = load("res://textures/sprayblume.png")
	#tag_material.albedo_color = Color(255,255,255,255)
	#tag_material.albedo_texture = load("res://textures/sprayblume.png")
	#tag.material_override = tag_material
	pass
