extends StaticBody2D


@export var tileColor : Color
@export var backgroundColor : Color



func _ready() -> void:
	#get all the child collision shapes
	var children : Array[Node] = get_children()
	for item in children:
		if item is CollisionShape2D:
			#draw the actual polys2D & set colors
			item.set_color(tileColor)
		elif item is ColorRect:
			#set the background color as well
			item.modulate = backgroundColor
