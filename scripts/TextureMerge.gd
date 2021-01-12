class_name TextureMerge

var merge_limit = 2

# Pass an array of SprayStencil
# They must all have the same parent and normal
# and lie on a common plane.
# Iow, they were all sprayed on the same face of a mesh.
func merge_stencils(stencils:Array):
	if stencils.size() < merge_limit:
		return

	if not have_same_parent(stencils):
		push_error("All stencils must have the same parent!")

	if not have_same_pixel_size(stencils):
		push_error("All stencils must have the same pixel size!")

	print("merging %s stencils on same object" % stencils.size())

	var original_parent = stencils[0].get_parent()
	var rotation_helper = create_rotation_helper(original_parent)
	duplicate_stencils(stencils, rotation_helper)
	rotate_normal_to_global_x(rotation_helper)
	var combined_image_spec = calculate_combined_size(rotation_helper)
	var combined_image = combined_image_spec.create_combined_image()
	var combined_stencil = create_combined_stencil(combined_image, original_parent)
	move_combined_stencil(stencils, combined_stencil)
	delete_rotation_helper(rotation_helper)
	delete_original_stencils(stencils)

func create_combined_stencil(combined_image: Image, original_parent):
	var combined_texture = ImageTexture.new()
	combined_texture.create_from_image(combined_image)
	var combined_stencil = SprayStencil.new()
	combined_stencil.set_texture(combined_texture)
	original_parent.add_child(combined_stencil)
	return combined_stencil

func have_same_parent(stencils:Array):
	var parent_check = null
	for stencil in stencils:
		var parent = stencil.get_parent()
		if parent_check == null:
			parent_check = parent
		elif parent != parent_check:
			return false
	return true

func have_same_pixel_size(stencils:Array):
	var pixel_size_check = null
	for stencil in stencils:
		var pixel_size = stencil.get_pixel_size()
		if pixel_size_check == null:
			pixel_size_check = pixel_size
		elif pixel_size != pixel_size_check:
			return false
	return true

func create_rotation_helper(original_parent):
	var rotation_helper = Spatial.new()
	var root = original_parent.get_parent()
	root.add_child(rotation_helper)
	rotation_helper.transform = original_parent.transform
	return rotation_helper

func duplicate_stencils(stencils:Array, rotation_helper):
	for stencil in stencils:
		var copy = stencil.duplicate()
		rotation_helper.add_child(copy)

func move_combined_stencil(stencils:Array, combined_stencil: SprayStencil):
	var new_origin_local = calculate_new_origin(stencils, combined_stencil)
	combined_stencil.transform.origin = new_origin_local

func calculate_new_origin(stencils:Array, combined_stencil: SprayStencil):
	var axis
	for stencil in stencils:
		var origin = stencil.transform.origin
		if axis == null:
			axis = origin
		else:
			axis = origin - axis
	var new_origin = axis / 2
#	return stencils[0].get_parent().to_local(new_origin)
	return new_origin

func rotate_normal_to_global_x(rotation_helper):
	print("rotation_helper: basis=%s" % rotation_helper.transform.basis)
	rotation_helper.rotation = Vector3.ZERO
	var any_child = rotation_helper.get_child(0)
	var rotated_transform = MathUtils.rotate_to_normal(
		rotation_helper.transform, any_child.transform.basis.z, Vector3(0,0,1))
	rotation_helper.transform = rotated_transform
	print("after rotation: basis=%s" % rotation_helper.transform.basis)

func calculate_combined_size(rotation_helper):
	var combined_size_world = calculate_combined_size_world(rotation_helper)
	return create_combined_image_spec(rotation_helper, combined_size_world)

func calculate_combined_size_world(rotation_helper):
	var min_x = MathUtils.MAX_INT
	var min_y = MathUtils.MAX_INT
	var max_x = MathUtils.MIN_INT
	var max_y = MathUtils.MIN_INT

	for stencil in rotation_helper.get_children():
		var used_rect = image_size_world(stencil)
		var horizontal = used_rect.size.x / 2
		var vertical = used_rect.size.y / 2
		var center = stencil.transform.origin

		var top = center.y - vertical
		var bottom = center.y + vertical
		var left = center.x - horizontal
		var right = center.x + horizontal

		if top < min_y:
			min_y = top
		if bottom > max_y:
			max_y = bottom
		if left < min_x:
			min_x = left
		if right > max_x:
			max_x = right

	var width_world = (max_x - min_x)
	var height_world = (max_y - min_y)
	return Rect2(min_x, min_y, width_world, height_world)

func create_combined_image_spec(rotation_helper, combined_size_world):
	var pixel_size = rotation_helper.get_children()[0].get_pixel_size()
	var combined_size_pixels = calculate_combined_size_pixels(combined_size_world, pixel_size)
	var combined_image_spec = CombinedImageSpec.new(combined_size_pixels)
	for stencil in rotation_helper.get_children():
		add_image_part(stencil, combined_size_world, combined_image_spec)
	return combined_image_spec

func calculate_combined_size_pixels(combined_size_world: Rect2, pixel_size: float):
	var width_world = combined_size_world.size.x
	var height_world = combined_size_world.size.y
	var width_pixel = width_world / pixel_size
	var height_pixel = height_world / pixel_size
	return Vector2(width_pixel, height_pixel)

func add_image_part(stencil: SprayStencil, combined_size_world, combined_image_spec):
	var left_top_pixel = determine_top_left_pixel(stencil, combined_size_world)
	var image_part = PartImageSpec.new()
	image_part.left_top_pixel = left_top_pixel
	image_part.image = stencil.texture.get_data()
	combined_image_spec.add_part(image_part)

func image_size_world(sprite):
	var image = sprite.texture.get_data()
	var used_rect = image.get_used_rect()
	var pixel_size = sprite.get_pixel_size()
	var world_x = used_rect.size.x * pixel_size
	var world_y = used_rect.size.y * pixel_size
	return Rect2(used_rect.position, Vector2(world_x, world_y))

func determine_top_left_pixel(stencil:SprayStencil, combined_size_world: Rect2):
	var origin_world = Vector2(stencil.transform.origin.x, stencil.transform.origin.y)
	var distance_world = origin_world - combined_size_world.position
	var origin_pixel = distance_world / stencil.get_pixel_size()
	var image = stencil.texture.get_data()
	var used_rect = image.get_used_rect()
	var half_size_pizel = used_rect.size / 2
	return origin_pixel - half_size_pizel

func determine_origin_pixel(stencil:SprayStencil, combined_size_world: Rect2):
	var origin_world = Vector2(stencil.transform.origin.x, stencil.transform.origin.y)
	var distance_world = origin_world - combined_size_world.position
	return distance_world / stencil.get_pixel_size()

class CombinedImageSpec:
	var image_parts = []
	var size_pixel: Vector2

	func _init(size_pixel:Vector2):
		self.size_pixel = size_pixel

	func add_part(part: PartImageSpec):
		image_parts.append(part)

	func create_combined_image():
		var result = Image.new()
		result.create(size_pixel.x, size_pixel.y, false, Image.FORMAT_RGBA8)
		result.fill(Color.transparent)
		result.lock()

		for part in image_parts:
			var image = part.image
			image.decompress()
			image.lock()

			var height = image.get_height()
			var width = image.get_width()

			for y in range(height):
				var y_combined = part.left_top_pixel.y + y
				for x in range(width):
					var x_combined = part.left_top_pixel.x + x
					var pixel = image.get_pixel(x, y)
					if pixel != Color.transparent:
						result.set_pixel(x_combined, y_combined, pixel)

			image.unlock()
		result.unlock()
		return result

class PartImageSpec:
	var image: Image
	var left_top_pixel: Vector2

func delete_rotation_helper(rotation_helper):
	for child in rotation_helper.get_children():
		child.queue_free()
	rotation_helper.queue_free()

func delete_original_stencils(stencils:Array):
	for stencil in stencils:
		stencil.queue_free()
