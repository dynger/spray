extends Node

const MIN_INT = -2^63
const MAX_INT = 2^63 - 1

func rotate_to_normal(transform, front, normal):
	var axis = front.cross(normal)
	if axis == Vector3():
		return transform

	axis = axis.normalized()

	var cosa = front.dot(normal)
	var angle = acos(cosa)

	return transform.rotated(axis, angle)
