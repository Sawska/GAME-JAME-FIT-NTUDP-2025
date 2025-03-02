extends CharacterBody3D


class_name FoxBot

@export var speed: float = 8.0
@onready var chicken_detector: Area3D = $ChickenDetector

func _physics_process(delta):
	var target = get_target()
	if target:
		var chase_direction = (target.global_position - global_position).normalized()
		velocity = chase_direction * speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

func get_target():
	var chickens = []
	for body in chicken_detector.get_overlapping_bodies():
		if body.is_in_group("chicken_player"):
			return body
		elif body.is_in_group("chicken"):
			chickens.append(body)
	if chickens.size() > 0:
		return chickens[0]
	return null
