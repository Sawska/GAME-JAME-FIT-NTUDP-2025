extends CharacterBody3D

const MAIN_MENU = preload("res://scenes/static/menu/main_menu.tscn")

@export_group("Camera settings")
@export var MOUSE_SENS: float = 0.25
@export var CAMERA_DISTANCE: float = 8.0
@export_group("Movement settings")
@export var SPEED: float = 8.0
@export var ACCELERATION: float = 20.0
@export var ROTATION: float = 12.0
@export var JUMP_STRENGTH: float = 5.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var fox_timer: Timer = $FoxTimer  # Reference to the Timer node
@onready var fox_timer_label: Label = $CanvasLayer/FoxTimerLabel  # Reference to the Label node in CanvasLayer
@onready var chickens_label: Label = $CanvasLayer/ChickensCaughtLabel  # Label to show chickens caught
@onready var score_label: Label = $CanvasLayer/ScoreLabel  # Label to show score

var CameraInpDir: Vector2 = Vector2.ZERO
var LastDir: Vector3 = Vector3.BACK
var Gravity : int = ProjectSettings.get_setting("physics/3d/default_gravity")
var fox_time: float = 0.0  # Timer to track the fox's time
var chickens_caught: int = 0  # Counter for chickens caught
var survival_score: int = 0
var chicken_score: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$head/SpringArm3D.spring_length = CAMERA_DISTANCE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	add_to_group("fox")
	
	# Check if fox_timer and fox_timer_label exist
	if fox_timer:
		fox_timer.start()  # Start the timer as soon as the fox enters the scene
		
	# Check if chickens_label and score_label exist
	if chickens_label:
		update_chickens_label()  # Update the chicken count label initially
	if score_label:
		update_score_label(0)  # Initialize score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update the timer and label text if fox_timer and fox_timer_label exist
	if fox_timer and fox_timer.time_left > 0:
		fox_time += delta  # Increment the time based on the frame's delta
		if fox_timer_label:
			fox_timer_label.text = "Time: " + str(int(fox_time)) + " sec"  # Update the label with the time

	# Calculate the score
	calculate_score()

	# Camera and movement logic
	$head.rotation.x += CameraInpDir.y * delta
	$head.rotation.x = clamp($head.rotation.x, -PI / 2.0, PI / 2.0)
	$head.rotation.y -= CameraInpDir.x * delta
	CameraInpDir = Vector2.ZERO
	
	var KeyboardInput: Vector2 = Input.get_vector("ui_a", "ui_d", "ui_w", "ui_s")
	var forward: Vector3 = $head/SpringArm3D/Camera3D.global_basis.z
	var right: Vector3 = $head/SpringArm3D/Camera3D.global_basis.x
	var MoveDir: Vector3 = forward * KeyboardInput.y + right * KeyboardInput.x
	MoveDir.y = 0.0
	MoveDir = MoveDir.normalized()
	
	var y_velocity: float = velocity.y
	velocity.y = 0
	velocity = velocity.move_toward(MoveDir * SPEED, ACCELERATION * delta)
	velocity.y = y_velocity - Gravity * delta
	move_and_slide()
	
	if MoveDir.length() > 0.2:
		LastDir =  MoveDir
	var TargetAngle: float = Vector3.BACK.signed_angle_to(LastDir, Vector3.UP)
	collision_shape_3d.rotation.y = lerp_angle(collision_shape_3d.rotation.y, TargetAngle, ROTATION * delta)
	$FoxModel.rotation.y = collision_shape_3d.rotation.y
	
# Handle user inputs, mouse, and movement controls
func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		CameraInpDir = event.relative * MOUSE_SENS
	if (event is InputEventKey and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		if (Input.is_action_just_pressed("ui_esc")):
			get_tree().change_scene_to_file("res://scenes/static/menu/main_menu.tscn")
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y += JUMP_STRENGTH
	if (event is InputEventMouseButton):
		if (Input.is_action_just_pressed("ui_scrlup")):
			$head/SpringArm3D.spring_length = clamp($head/SpringArm3D.spring_length - 0.5, 0.0, 10.0)
		if (Input.is_action_just_pressed("ui_scrldown")):
			$head/SpringArm3D.spring_length = clamp($head/SpringArm3D.spring_length + 0.5, 0.0, 10.0)

# Function to catch a chicken
func catch_chicken():
	chickens_caught += 1
	update_chickens_label()

# Update the chickens caught label in the UI, if it exists
func update_chickens_label():
	if chickens_label:
		chickens_label.text = "Chickens caught: " + str(chickens_caught)

# Function to calculate the score based on chickens caught and time survived
func calculate_score():
	chicken_score = chickens_caught * 10  # Score based on chickens caught
	survival_score = int(fox_time) * 5  # Score based on time survived
	
	var total_score = chicken_score + survival_score
	update_score_label(total_score)

# Update the score label in the UI, if it exists
func update_score_label(total_score: int):
	if score_label:
		score_label.text = "Score: " + str(total_score)

# When entering a den, update the chicken count label
func on_enter_den():
	update_chickens_label()  # Update chickens caught label when entering the den
	# You can add additional logic here to display chickens in the den or other actions
