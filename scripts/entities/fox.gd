extends CharacterBody3D

class_name Fox_milita

const MAIN_MENU = preload("res://scenes/static/menu/main_menu.tscn")
const ACTUAL_NET = preload("res://scenes/entities/actual_net.tscn")
const FOX_HOLE: Resource = preload("res://scenes/static/fox_hole.tscn")
const FOX_HOLE_NIGHT = preload("res://scenes/static/fox_hole_night.tscn")

@export var EndedGame: bool = false
@export var COUNTER: bool = false
@export var CANCONTROL: bool = false
@export var Life_time: float = 60
@export_group("Camera settings")
@export var MOUSE_SENS: float = 0.25
@export var CAMERA_DISTANCE: float = 0
@export_group("Movement settings")
@export var SPEED: float = 40.0
@export var ACCELERATION: float = 20.0
@export var ROTATION: float = 12.0
@export var JUMP_STRENGTH: float = 7.0

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var fox_timer: Timer = $FoxTimer  # Reference to the Timer node
@onready var fox_timer_label: Label = $CanvasLayer/VBoxContainer/FoxTimerLabel  # Reference to the Label node in CanvasLayer
@onready var chickens_label: Label = $CanvasLayer/VBoxContainer/ChickensCaughtLabel  # Label to show chickens caught
@onready var score_label: Label = $CanvasLayer/VBoxContainer/ScoreLabel  # Label to show score

var CameraInpDir: Vector2 = Vector2.ZERO
var LastDir: Vector3 = Vector3.BACK
var TargetAngle: float
var Gravity : int = ProjectSettings.get_setting("physics/3d/default_gravity")
var KeyboardInput: Vector2 = Vector2(0,0)
var fox_time: float = 0.0  # Timer to track the fox's time
var chickens_caught: int = 0  # Counter for chickens caught
var survival_score: int = 0
var chicken_score: int = 0
var chickens_in_den: int = 0  # Counter for chickens in the den

# Called when the node enters the scene tree for the first time.
func _ready():
	$head/SpringArm3D.spring_length = CAMERA_DISTANCE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	check_for_counter()
	
	add_to_group("fox")
	
	await hide_black_screen()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Update the timer and label text if fox_timer and fox_timer_label exist
	if fox_timer and fox_timer.time_left > 0:
		fox_time += delta  # Increment the time based on the frame's delta
		if fox_timer_label:
			fox_timer_label.text = "Time: " + str(int(fox_time)) + " sec"  # Update the label with the time
	
	if fox_time > Life_time and !EndedGame:
		EndedGame = true
		CANCONTROL = false
		velocity = Vector3(0,0,0)
		KeyboardInput = Vector2(0,0)
		await show_some_temp_text("Час закінчився\nВіднесіть " + str(chickens_caught) + " курочок собі у нору")
		CANCONTROL = true
	
	# Calculate the score
	calculate_score()

	# Camera and movement logic
	$head.rotation.x += CameraInpDir.y * delta
	$head.rotation.x = clamp($head.rotation.x, -PI / 2.0, PI / 2.0)
	$head.rotation.y -= CameraInpDir.x * delta
	CameraInpDir = Vector2.ZERO
	
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
		##СЮДА ДОБАВИТЬ БЕГ
	else:
		##СЮДА ДОБАВИТЬ СТОЯНИЕ И ПАСС ЗАКОМЕНТИТЬ
		pass
	TargetAngle = Vector3.BACK.signed_angle_to(LastDir, Vector3.UP)
	collision_shape_3d.rotation.y = lerp_angle(collision_shape_3d.rotation.y, TargetAngle, ROTATION * delta)
	$FoxModel.rotation.y = collision_shape_3d.rotation.y
	
# Handle user inputs, mouse, and movement controls
func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		CameraInpDir = event.relative * MOUSE_SENS
	if (event is InputEventKey and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		if CANCONTROL:
			KeyboardInput = Input.get_vector("ui_a", "ui_d", "ui_w", "ui_s")
		if (Input.is_action_just_pressed("ui_esc")):
			get_tree().change_scene_to_file("res://scenes/static/menu/main_menu.tscn")
		if Input.is_action_pressed("ui_accept") and is_on_floor():
			velocity.y += JUMP_STRENGTH
	if (event is InputEventMouseButton):
		if (Input.is_action_just_pressed("ui_scrlup")):
			$head/SpringArm3D.spring_length = clamp($head/SpringArm3D.spring_length - 0.5, 0.0, 10.0)
		if (Input.is_action_just_pressed("ui_scrldown")):
			$head/SpringArm3D.spring_length = clamp($head/SpringArm3D.spring_length + 0.5, 0.0, 10.0)
		if (Input.is_action_just_pressed("ui_lmb")):
			LastDir = $head.basis*Vector3(0,0,1)
			shoot()

func show_some_text(some_text: String, duration: int) -> void:
	$CanvasLayer/Label.text = some_text
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/Label.set("theme_override_colors/font_color",(Color(1.0,0.27,0.21,i/100.0)))
	await get_tree().create_timer(duration).timeout

func hide_some_text() -> void:
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/Label.set("theme_override_colors/font_color",(Color(1.0,0.27,0.21,(i-100.0)/-100.0)))

func hide_black_screen() -> void:
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/ColorRect.color = Color(0,0,0,(i-100.0)/-100.0)
	$CanvasLayer/ColorRect.visible = false
	CANCONTROL = true

func show_black_screen() -> void:
	CANCONTROL = false
	$CanvasLayer/ColorRect.visible = true
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/ColorRect.color = Color(0,0,0,(i/100.0))

func show_some_temp_text(some_text: String = "Change this text", duration: int = 3) -> void:
	CANCONTROL = false
	velocity = Vector3(0,0,0)
	KeyboardInput = Vector2(0,0)
	await show_some_text(some_text,3)
	await hide_some_text()
	CANCONTROL = true

func check_for_counter() ->void:
	if !COUNTER:
		$CanvasLayer/VBoxContainer.visible = COUNTER
	else:
		$CanvasLayer/VBoxContainer.visible = COUNTER
		if fox_timer:
			fox_timer.start()  # Start the timer as soon as the fox enters the scene
		if chickens_label:
			update_chickens_label()  # Update the chicken count label initially
		if score_label:
			update_score_label(0)  # Initialize score

func shoot() -> void:
	var net_scale: int = 5
	var net: Node = ACTUAL_NET.instantiate()
	net.position = get_global_position()
	net.rotation = $head.rotation
	net.scale = Vector3(net_scale,net_scale,net_scale)
	net.apply_impulse($head.basis * Vector3(0, 0, 80))
	add_sibling(net)

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

## СУКИ КОГДА ДОБАВИТЕ МОДЕЛЬКУ КУРИЦ 
## НИКОГДАИДИНАХУЙ <3
## When entering a den, update the chicken count label and spawn chickens in the den
#func on_enter_den():
	#chickens_in_den = chickens_caught  # Set the number of chickens in the den to the number caught
	#update_chickens_label()  # Update the chicken count label when entering the den
	## Add chickens to the den (spawn them or activate them in the scene)
	## For example, you could instantiate chickens based on `chickens_in_den`
	#for i in range(chickens_in_den):
		#var chicken = preload("res://scenes/entities/chicken.tscn").instantiate()
		#chicken.position = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))  # Random spawn positions in the den
		#add_child(chicken)


func _on_sobakadetector_body_entered(body: Node3D) -> void:
	if body.is_in_group("dog_bot"):
		await show_some_temp_text("Вас спіймали, спробуйте ще раз", 5)
		show_black_screen()
		get_tree().change_scene_to_packed(FOX_HOLE_NIGHT)
