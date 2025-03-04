extends CharacterBody3D

class_name ChickenBot

@export var speed: float = 6.0
@onready var fox_detector: Area3D = $FoxDetector

func _ready():
	# Add ChickenBot to the 'chicken_bot' group
	add_to_group("chicken_bot")
	
	if not fox_detector:
		print("Fox detector node not found!")
		return

func _physics_process(delta):
	if not fox_detector:
		return

	var foxes = get_foxes()
	if foxes.size() > 0:
		# If foxes are detected, run away from them
		var flee_direction = Vector3.ZERO
		for fox in foxes:
			# Calculate the flee direction (move away from fox)
			flee_direction += (global_position - fox.global_position).normalized()
		flee_direction /= foxes.size()
		
		# Set y component to 0 to prevent upward or downward movement
		flee_direction.y = 0
		velocity = flee_direction * speed
	else:
		# If no foxes are detected, move in a random direction
		var random_direction = Vector3(randf_range(-1.0, 1.0), 0, randf_range(-1.0, 1.0)).normalized()
		velocity = random_direction * speed

	move_and_slide()

func get_foxes():
	var foxes = []
	for body in fox_detector.get_overlapping_bodies():
		print(body.get_groups())
		if body.is_in_group("fox"):
			foxes.append(body)
	
	return foxes
