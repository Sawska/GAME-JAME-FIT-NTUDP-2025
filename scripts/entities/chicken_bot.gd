extends CharacterBody3D

class_name ChickenBot

@export var speed: float = 6.0
@export var target_reached: bool = true
@export var Life_time: float = 60
var random_target_position: Vector3 = Vector3.ZERO
@onready var fox_detector: Area3D = $FoxDetector
var fox_time: float = 0.0


func _ready():
	# Add ChickenBot to the 'chicken_bot' group
	add_to_group("chicken_bot")
	set_random_target_position()
	
	if not fox_detector:
		print("Fox detector node not found!")
		return

func _physics_process(delta):
	if not fox_detector:
		return
	if fox_time > Life_time:
		queue_free()
	else:
		fox_time += delta 
	# Check if there are any foxes in the fox_detector's range
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
		# If no foxes are detected, move towards a random target
		if target_reached:
			# Set a new random target position when the current one is reached
			set_random_target_position()

		var direction_to_target = (random_target_position - global_position).normalized()
		velocity = direction_to_target * speed

		# Check if ChickenBot has reached the random target
		if global_position.distance_to(random_target_position) < 0.5:  # Threshold to consider target reached
			target_reached = true
		else:
			target_reached = false

	move_and_slide()

func set_random_target_position():
	random_target_position = global_position + Vector3(randf_range(-10.0, 10.0), 0, randf_range(-10.0, 10.0))
	target_reached = false

func get_foxes():
	var foxes = []
	for body in fox_detector.get_overlapping_bodies():
		if body.is_in_group("fox"):
			foxes.append(body)
	
	return foxes
