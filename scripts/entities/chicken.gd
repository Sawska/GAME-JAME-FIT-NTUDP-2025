extends CharacterBody3D

class_name Chicken_milita

const MAIN_MENU = preload("res://scenes/static/menu/main_menu.tscn")
const ACTUAL_NET = preload("res://scenes/entities/actual_net.tscn")
const FOX_HOLE_NIGHT = preload("res://scenes/static/fox_hole_night.tscn")
const bababoi = preload("res://FINALL.tscn")

@export_group("Camera settings")
@export var MOUSE_SENS: float = 0.25
@export var CAMERA_DISTANCE: float = 8.0
@export_group("Movement settings")
@export var SPEED: float = 8.0
@export var ACCELERATION: float = 20.0
@export var ROTATION: float = 12.0
@export var JUMP_STRENGTH: float = 5.0

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var chicken_timer: Timer = $CanvasLayer/ChickenTimer  # Таймер для курочки
@onready var chicken_timer_label: Label = $CanvasLayer/ChickenTimerLabel  # Метка таймера
@onready var score_label: Label = $CanvasLayer/ScoreLabel  # Метка для счёта

var CANCONTROL: bool = true
var KeyboardInput: Vector2 
var CameraInpDir: Vector2 = Vector2.ZERO
var LastDir: Vector3 = Vector3.BACK
var TargetAngle: float
var Gravity : int = ProjectSettings.get_setting("physics/3d/default_gravity")
var chicken_time: float = 0.0  # Таймер для курочки
var survival_score: int = 0  # Счёт за выживание
var chicken_score: int = 0  # Счёт за курочек

# Called when the node enters the scene tree for the first time.
func _ready():
	$head/SpringArm3D.spring_length = CAMERA_DISTANCE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	add_to_group("chicken_player")
	
	# Start the chicken timer
	if chicken_timer:
		chicken_timer.start()  # Начинаем отсчёт таймера

	# Check if score_label exists
	if score_label:
		update_score_label(0)  # Инициализация счёта

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if chicken_time > 60:
		get_tree().change_scene_to_packed(bababoi)
	
	# Update the chicken timer
	if chicken_timer and chicken_timer.time_left > 0:
		chicken_time += delta  # Увеличиваем время курочки
		if chicken_timer_label:
			chicken_timer_label.text = "Time: " + str(int(chicken_time)) + " sec"  # Обновляем таймер на экране

	# Calculate the score for the chicken based on time survived
	calculate_score()

	# Camera and movement logic
	$head.rotation.x += CameraInpDir.y * delta
	$head.rotation.x = clamp($head.rotation.x, -PI / 2.0, PI / 2.0)
	$head.rotation.y -= CameraInpDir.x * delta
	CameraInpDir = Vector2.ZERO
	if CANCONTROL:
		KeyboardInput = Input.get_vector("ui_a", "ui_d", "ui_w", "ui_s")
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
	TargetAngle = Vector3.BACK.signed_angle_to(LastDir, Vector3.UP)
	collision_shape_3d.rotation.y = lerp_angle(collision_shape_3d.rotation.y, TargetAngle, ROTATION * delta)
	$FoxModel.rotation.y = collision_shape_3d.rotation.y

# Update the score label
func update_score_label(total_score: int):
	if score_label:
		score_label.text = "Score: " + str(total_score)

# Calculate the score based on time survived
func calculate_score():
	chicken_score = int(chicken_time) * 5  # Счёт зависит от времени выживания
	update_score_label(chicken_score)

# When entering the den, update the score and the chicken count label
func on_enter_den():
	# Add logic to update the number of chickens or other actions when entering the den
	print("Chicken entered the den!")

func show_black_screen() -> void:
	CANCONTROL = false
	$CanvasLayer/ColorRect.visible = true
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/ColorRect.color = Color(0,0,0,(i/100.0))

func hide_some_text() -> void:
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/Label.set("theme_override_colors/font_color",(Color(1.0,0.27,0.21,(i-100.0)/-100.0)))

func show_some_text(some_text: String, duration: int) -> void:
	$CanvasLayer/Label.text = some_text
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$CanvasLayer/Label.set("theme_override_colors/font_color",(Color(1.0,0.27,0.21,i/100.0)))
	await get_tree().create_timer(duration).timeout

func show_some_temp_text(some_text: String = "Change this text", duration: int = 3) -> void:
	CANCONTROL = false
	velocity = Vector3(0,0,0)
	KeyboardInput = Vector2(0,0)
	await show_some_text(some_text,3)
	await hide_some_text()
	CANCONTROL = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox"):
		await show_some_temp_text("Вас спіймали, спробуйте ще раз", 5)
		show_black_screen()
		get_tree().change_scene_to_packed(FOX_HOLE_NIGHT)
