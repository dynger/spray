class_name TextureMerge

var merge_limit = 2

# Pass an array of SprayStencil
# It is assumed that they all have the same parent and normal
# and lie on a common plane.
# Iow, they were all sprayed on the same face of a mesh.
func merge_stencils(stencils:Array):
	if stencils.size() < merge_limit:
		return # nothing to merge
	
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
	var combined_texture = ImageTexture.new()
	combined_texture.create_from_image(combined_image)
	var combined_stencil = SprayStencil.new()
	combined_stencil.set_texture(combined_texture)
	combined_stencil.translate(Vector3(0,0,5))
	original_parent.add_child(combined_stencil)
	delete_rotation_helper(rotation_helper)
#	delete_original_stencils(stencils)

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
		var image = stencil.texture.get_data()
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
	var original_parent = stencils[0].get_parent()
	for stencil in stencils:
		var copy = stencil.duplicate()
		original_parent.remove_child(copy)
		rotation_helper.add_child(copy)

func rotate_normal_to_global_x(rotation_helper):
	print("rotation_helper: basis=%s" % rotation_helper.transform.basis)
	rotation_helper.rotation = Vector3.ZERO
	var any_child = rotation_helper.get_child(0)
	var rotated_transform = MathUtils.rotate_to_normal(
		rotation_helper.transform, any_child.transform.basis.z, Vector3(0,0,1))
	rotation_helper.transform = rotated_transform
	print("after rotation: basis=%s" % rotation_helper.transform.basis)

func calculate_combined_size(rotation_helper):
	var min_x = MathUtils.MAX_INT
	var min_y = MathUtils.MAX_INT
	var max_x = MathUtils.MIN_INT
	var max_y = MathUtils.MIN_INT
	var pixel_size
	
	for stencil in rotation_helper.get_children():
		pixel_size = stencil.get_pixel_size()
		var used_rect = image_size_world(stencil)
		var horizontal = used_rect.size.x / 2
		var vertical = used_rect.size.y / 2
		var center = stencil.transform.origin
		print("image at position %s has world size %s" % [center, used_rect.size])

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
	var width_pixel = width_world / pixel_size
	var height_pixel = height_world / pixel_size
	print("combined image size in pixels (%s, %s) and size in world (%s, %s)"
	% [width_pixel, height_pixel, max_x - min_x, max_y - min_y])
	print("min_x: %s, min_y: %s, max_x: %s, max_y: %s" % [min_x, min_y, max_x, max_y])
	var combined_size_world = Rect2(min_x, min_y, width_world, height_world)
	print("rect: %s" % combined_size_world)
	
	var combined_image_spec = CombinedImageSpec.new(Vector2(width_pixel, height_pixel))
	
	for stencil in rotation_helper.get_children():
#		var origin_pixel = determine_origin_pixel(stencil, rect_world)
		var top_left_pixel = determine_top_left_pixel(stencil, combined_size_world)
		print("top left pixel %s" % [top_left_pixel])
		var image_part = PartImageSpec.new()
		image_part.left_top_pixel = top_left_pixel
		image_part.image = stencil.texture.get_data()
		combined_image_spec.add_part(image_part)
	
	return combined_image_spec

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
	print("image world origin %s to pixel origin %s" % [stencil.transform.origin, origin_pixel])
	var image = stencil.texture.get_data()
	var used_rect = image.get_used_rect()
	var half_size_pizel = used_rect.size / 2
	return origin_pixel - half_size_pizel
	
func determine_origin_pixel(stencil:SprayStencil, combined_size_world: Rect2):
	var origin_world = Vector2(stencil.transform.origin.x, stencil.transform.origin.y)
	var distance_world = origin_world - combined_size_world.position
	return distance_world / stencil.get_pixel_size()
	
#class ImageSpec:
#	func get_size_world(): pass
#	func get_size_pixel(): pass
#	func get_origin_world(): pass
#	func get_origin_pixel(): pass

class CombinedImageSpec:# extends ImageSpec:
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
			print("append image with width, height (%s, %s)" % [width, height])
			
#			var left = origin.x / pixel_size - (width/2)
#			var top = origin.y / pixel_size - (height/2)
#
#			print("top left of appended image (%s, %s)" % [top, left])
			
			for y in range(height):
				var y_combined = part.left_top_pixel.y + y
				for x in range(width):
					var x_combined = part.left_top_pixel.x + x
					var pixel = image.get_pixel(x, y)
					if pixel != Color.transparent:
	#				print("set pixel (%s, %s): %s" % [x, y, pixel])
						result.set_pixel(x_combined, y_combined, pixel)
			
			image.unlock()
		result.unlock()
		return result
		
class PartImageSpec:# extends ImageSpec:
	var image: Image
	var left_top_pixel: Vector2
	
#	func _init(image: Image, left_top_pixel: Vector2):
#		self.image = image
#		self.left_top_pixel = left_top_pixel

#func draw_image(combined_image_spec: CombinedImageSpec):
##	var pixel_size = rotation_helper.get_child(0).get_pixel_size()
#	var builder = ImageBuilder.new(combined_size.size, pixel_size)
#
#	for stencil in rotation_helper.get_children():
#		var image = stencil.texture.get_data()
#		var origin = stencil.transform.origin
#		var origin2d = Vector2(origin.x, origin.y)
#		builder.append(image, origin2d)
#
#	return builder.get_result()

func delete_rotation_helper(rotation_helper):
	for child in rotation_helper.get_children():
		child.queue_free()
	rotation_helper.queue_free()

func delete_original_stencils(stencils:Array):
	for stencil in stencils:
		stencil.queue_free()

#class ImageBuilder:
#	var result:Image
#	var combined_image_spec: CombinedImageSpec
#
#	func _init(combined_image_spec: CombinedImageSpec):
##		self.pixel_size = pixel_size
##		print("create image builder for combined size (%s, %s)" % [combined_size.x, combined_size.y])
#		result = Image.new()
#		result.create(combined_image_spec.size_pixel.x, combined_image_spec.size_pixel.y, false, Image.FORMAT_RGBA8)
#		result.fill(Color.transparent)
#
#	func append(image:Image, origin:Vector2):
#		image.decompress()
#		result.lock()
#		image.lock()
#
#		var height = image.get_height()
#		var width = image.get_width()
#		print("image at origin (%s), width, height (%s, %s)" % [origin, width, height])
#
#		var left = origin.x / pixel_size - (width/2)
#		var top = origin.y / pixel_size - (height/2)
#
#		print("top left of appended image (%s, %s)" % [top, left])
#
#		for y in range(height):
#			var y_combined = top + y
#			for x in range(width):
#				var pixel = image.get_pixel(x, y)
#				var x_combined = left + x
##				print("set pixel (%s, %s): %s" % [x, y, pixel])
#				result.set_pixel(x_combined, y_combined, pixel)
#
#		image.unlock()
#		result.unlock()
#
#	func get_result():
#		return result
