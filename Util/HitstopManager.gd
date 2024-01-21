extends Node

var stopped : bool = false

func hit_stop_tiny() -> void:
	hit_stop(0.10)
	
func hit_stop_short() -> void:
	hit_stop(0.15)
	
func hit_stop_mid() -> void:
	hit_stop(0.25)

func hit_stop_long() -> void:
	hit_stop(0.4)

func hit_stop(timeout:float) -> void:
	if stopped: return
	get_tree().paused = true
	stopped = true
	await get_tree().create_timer(timeout,true,false,true).timeout
	get_tree().paused = false
	stopped = false
