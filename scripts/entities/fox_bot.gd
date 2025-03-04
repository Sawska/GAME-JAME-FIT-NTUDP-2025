extends CharacterBody3D

class_name FoxBot

@export var speed: float = 8.0
@export var run_away_speed: float = 16.0  # Speed when running away from a dog (double speed)
@onready var chicken_detector: Area3D = $ChickenDetector
@onready var dog_detector: Area3D = $DogDetector  # Dog detector to detect nearby dogs
@export var random_speed: float = 4.0  # Speed when moving randomly
var random_target_position: Vector3 = Vector3.ZERO
var target_reached: bool = true  # Flag to check if the target is reached

func _ready():
	# Add this FoxBot to the 'fox' group
	add_to_group("fox")

	# Set an initial random target position for movement
	set_random_target_position()

func _physics_process(delta):
	# Check if there are any dogs in the dog_detector's range
	var dogs = get_dogs()
	if dogs.size() > 0:
		# If dogs are detected, run away from them at double speed
		var run_direction = Vector3.ZERO
		for dog in dogs:
			# Calculate the run-away direction (move away from dog)
			run_direction += (global_position - dog.global_position).normalized()
		run_direction /= dogs.size()
		
		# Set y component to 0 to prevent upward or downward movement
		run_direction.y = 0
		velocity = run_direction * run_away_speed
		move_and_slide()
		return

	# Check if there are any chickens in the chicken_detector's range
	var chickens = get_chickens()

	if chickens.size() > 0:
		# If chickens are detected, chase the first one
		var target = chickens[0]
		var chase_direction = (target.global_position - global_position).normalized()
		velocity = chase_direction * speed
		move_and_slide()
	else:
		# If no chickens are detected, move randomly
		if target_reached:
			# Set a new random target position when the current one is reached
			set_random_target_position()

		var direction_to_target = (random_target_position - global_position).normalized()
		velocity = direction_to_target * random_speed
		move_and_slide()

		# Check if the FoxBot has reached the random target
		if global_position.distance_to(random_target_position) < 0.5:  # Threshold to consider target reached
			target_reached = true
		else:
			target_reached = false

func set_random_target_position():
	random_target_position = global_position + Vector3(randf_range(-10.0, 10.0), 0, randf_range(-10.0, 10.0))
	target_reached = false

func get_chickens():
	var chickens = []
	for body in chicken_detector.get_overlapping_bodies():
		if body.is_in_group("chicken_player") or body.is_in_group("chicken"):
			chickens.append(body)
	
	return chickens

func get_dogs():
	var dogs = []
	for body in dog_detector.get_overlapping_bodies():
		if body.is_in_group("dog"):
			dogs.append(body)
	
	return dogs
