extends CharacterBody3D

class_name Yorchik

@export var bark_range: float = 10.0
@onready var fox_detector: Area3D = $FoxDetector
var last_bark_position: Vector3 = Vector3.ZERO
@export var speed: float = 6.0  # Movement speed
var random_target_position: Vector3 = Vector3.ZERO
var target_reached: bool = true  # Flag to check if the target is reached

func _ready():
	# Set an initial random target position
	set_random_target_position()

func _physics_process(delta):
	# Check if there are any foxes in the fox_detector's range
	var foxes = get_foxes()

	if foxes.size() > 0:
		# If foxes are detected, bark and follow them
		for fox in foxes:
			bark(fox.global_position)
			# Move towards the fox
			var direction_to_fox = (fox.global_position - global_position).normalized()
			velocity = direction_to_fox * speed
			move_and_slide()
			break
	else:
		# If no foxes are detected, move randomly
		if target_reached:
			# Set a new random target position when the current one is reached
			set_random_target_position()

		var direction_to_target = (random_target_position - global_position).normalized()
		velocity = direction_to_target * speed
		move_and_slide()

		# Check if Yorchik has reached the random target
		if global_position.distance_to(random_target_position) < 0.5:  # Threshold to consider target reached
			target_reached = true
		else:
			target_reached = false

func set_random_target_position():
	# Generate a random target position within a certain range
	random_target_position = global_position + Vector3(randf_range(-10.0, 10.0), 0, randf_range(-10.0, 10.0))
	target_reached = false

func get_foxes():
	var foxes = []
	for body in fox_detector.get_overlapping_bodies():
		if body.is_in_group("fox"):
			foxes.append(body)
	
	return foxes

func bark(position: Vector3):
	last_bark_position = position
	print("Yorchik: Bark! Bark! Fox detected at ", position)
