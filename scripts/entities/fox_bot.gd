extends CharacterBody3D

class_name FoxBot

@export var speed: float = 8.0
@onready var chicken_detector: Area3D = $ChickenDetector
@export var random_speed: float = 4.0  # Speed when moving randomly

func _ready():
	# Add this FoxBot to the 'fox' group
	add_to_group("fox")

func _physics_process(delta):
	var target = get_target()
	if target:
		# If a chicken is detected, chase it
		var chase_direction = (target.global_position - global_position).normalized()
		velocity = chase_direction * speed
	else:
		# If no chickens are detected, move randomly
		var random_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		velocity = random_direction * random_speed
	
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
	
	# Return null if no chicken is detected
	return null
