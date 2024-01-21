extends Node2D

func _ready() -> void:
	var children : Array[Node] = get_children()
	var maxLifetime : float = 0
	for i : Node in children:
		var particles : GPUParticles2D = i as GPUParticles2D
		particles.emitting = true
		if(particles.lifetime > maxLifetime): maxLifetime = particles.lifetime
	await get_tree().create_timer(maxLifetime + 1.0).timeout
	queue_free()


func _on_tree_entered()->void:
	var children : Array[Node] = get_children()
	for i : Node in children:
		var particles : GPUParticles2D = i as GPUParticles2D
		particles.modulate = modulate
