extends RayCast

class_name MergingSprayCast

var texture_merge = TextureMerge.new()

func _physics_process(delta):
	if Input.is_action_just_pressed("spray_stencil") and is_colliding():
		var collider = get_collider()
		var global_position = get_collision_point()
		var normal = get_collision_normal()
		_on_sprayed(collider, global_position, normal)

func _on_sprayed(collision_object, collision_position, collider_normal):
	var tag = create_tag(collision_object, collider_normal)
	rotate_spray_to_collider_normal(tag, collider_normal)
	apply_spray_at_position(tag, collision_object, collision_position, collider_normal)
	apply_spray_texture(tag)
	print("drew stencil")
	var stencils = collect_existing_sprays_on_same_surface(collision_object, collision_position, collider_normal)
	print("collected %s stencils on same object" % stencils.size())
	texture_merge.merge_stencils(stencils)
	
func create_tag(collision_object, collider_normal):
	var tag = SprayStencil.new()
	tag.collider_normal = collider_normal
	collision_object.add_child(tag)
	return tag

func rotate_spray_to_collider_normal(tag, collider_normal):
	var front = tag.transform.basis.z
	var rotated_global_transform = MathUtils.rotate_to_normal(tag.transform, front, collider_normal)
	tag.set_global_transform(rotated_global_transform)

func apply_spray_at_position(tag, collision_object, collision_position, collider_normal):
	var local_position = collision_object.to_local(collision_position)
	var normalized_normal = collider_normal.normalized()
	tag.transform.origin = local_position + (normalized_normal * 0.001)

func apply_spray_texture(tag):
	tag.texture = get_selected_spray()

func get_selected_spray():
	return load("res://textures/sprayblume.png")

func collect_existing_sprays_on_same_surface(collision_object, collision_position, collider_normal):
	var result = []
	for existing_spray in collision_object.get_children():
		# TODO: collect only those which lie on the same face!
		if existing_spray is SprayStencil and existing_spray.collider_normal == collider_normal:
			result.append(existing_spray)
	
	return result
