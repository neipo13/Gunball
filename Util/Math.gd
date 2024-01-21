class_name  Math


static func approachVec2(start : Vector2, end : Vector2, shift : float) -> Vector2:
	start.x = approachf(start.x, end.x, shift)
	start.y = approachf(start.y, end.y, shift)
	return start
	
static func approachf(start: float, end:float, shift:float) -> float:
	if(start < end):
		return min(start+shift, end)
	return max(start - shift, end)
