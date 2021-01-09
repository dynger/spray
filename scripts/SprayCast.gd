extends RayCast

class_name SprayCast

func _physics_process(delta):
	if Input.is_action_just_pressed("spray_stencil") and is_colliding():
		_on_sprayed()

func _on_sprayed():
	draw_stencil()

func draw_stencil():
	var tag = create_tag()
	rotate_spray_to_collider_normal(tag)
	apply_spray_at_position(tag)
	apply_spray_texture(tag)
	print("drew stencil")

func create_tag():
	var tag = SprayStencil.new()
	tag.collider_normal = get_collision_normal()
	var collision_object = get_collider()
	collision_object.add_child(tag)
	return tag

func rotate_spray_to_collider_normal(tag):
	var front = tag.transform.basis.z
	var collider_normal = get_collision_normal()
	var rotated_global_transform = MathUtils.rotate_to_normal(
		tag.transform, front, collider_normal)
	tag.set_global_transform(rotated_global_transform)

func apply_spray_at_position(tag):
	var collision_object = get_collider()
	var collision_position = get_collision_point()
	var collider_normal = get_collision_normal()
	var local_position = collision_object.to_local(collision_position)
	var normalized_normal = collider_normal.normalized()
	tag.transform.origin = local_position + (normalized_normal * 0.001)

func apply_spray_texture(tag):
	tag.texture = get_selected_spray()

func get_selected_spray():
	return load("res://textures/sprayblume.png")
