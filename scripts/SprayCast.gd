extends RayCast

var ray_length = 20

#signal sprayed(position, normal)

func _physics_process(delta):
	if Input.is_action_just_pressed("mouse_left") and is_colliding():
		var obj = get_collider()
		print(obj.get_name())
		var location = get_collision_point()
		var normal = get_collision_normal()
		print(location)
		print(normal)
#		emit_signal("sprayed", location, normal)
		_on_sprayed(obj, location, normal)

func _on_sprayed(collider, position, normal):
	var tag = Sprite3D.new()
	tag.transform.origin = position
#	tag.rotation.z = -90
#	print(tag.transform.origin)
	tag.texture = load("res://textures/sprayblume.png")
#	tag.global_transform.basis.z = normal
#	tag.transform.basis.rotate_x(normal.x * PI/2)
#	tag.transform.basis.rotate_y(normal.y * PI/2)
#	tag.transform.basis.rotate_z(normal.z * PI/2)
	tag.transform.basis = Basis(-normal, PI) * tag.transform.basis
#	tag.set_rotation(normal)
	collider.add_child(tag)
