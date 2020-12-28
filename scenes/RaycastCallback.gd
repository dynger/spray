extends StaticBody


func _input_event (camera, event, click_position, click_normal, shape_idx):
	if(event is InputEventMouseButton and event.pressed):
		print("normal: %s" % click_normal)
		print("world position: %s" % click_position)
		
		var tag = Sprite3D.new()
		tag.transform.origin = click_position
	#	tag.rotation.z = -90
	#	print(tag.transform.origin)
		tag.texture = load("res://textures/sprayblume.png")
		
		get_parent().add_child(tag)
