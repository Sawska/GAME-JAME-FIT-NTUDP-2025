extends CharacterBody3D


class_name ChickenBot

@export var speed: float = 6.0
@onready var fox_detector: Area3D = $FoxDetector

func _physics_process(delta):
	var foxes = get_foxes()
	if foxes.size() > 0:
		var flee_direction = Vector3.ZERO
		for fox in foxes:
			flee_direction += (global_position - fox.global_position).normalized()
		flee_direction /= foxes.size()
		velocity = flee_direction * speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

func get_foxes():
	var foxes = []
	for body in fox_detector.get_overlapping_bodies():
		if body.is_in_group("fox"):
			foxes.append(body)
	return foxes
