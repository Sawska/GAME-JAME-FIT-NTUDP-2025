extends RigidBody3D

@onready var area_3d: Area3D = $Area3D

var already_exist: int = 0
var life: int = 60

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	already_exist += 1
	if already_exist > life:
		queue_free()
	for body in area_3d.get_overlapping_bodies():
		if body.is_in_group("chicken_bot"):
			body.queue_free()
			var fox = get_tree().get_first_node_in_group("fox")
			if fox:
				fox.catch_chicken()
			queue_free()
