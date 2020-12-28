extends RayCast

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
	tag.texture = load("res://textures/sprayblume.png")
	tag.transform.origin = position
	var normal_correct_rotation = Vector3(normal.y, normal.x, normal.z)
	tag.transform.basis = transform.basis.rotated(normal_correct_rotation, PI/2)
	collider.add_child(tag)
