extends CharacterBody3D

@export_group("Camera settings")
@export var MOUSE_SENS: float = 0.25
@export var CAMERA_DISTANCE: float = 8
@export_group("Movement settings")
@export var SPEED: float = 8.0
@export var ACCELERATION: float = 20.0
@export var ROTATION: float = 12.0
@export var JUMP_STRENGTH: float = 5.0

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var CameraInpDir: Vector2 = Vector2.ZERO
var LastDir: Vector3 = Vector3.BACK
var Gravity : int = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	$head/SpringArm3D.spring_length = CAMERA_DISTANCE
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	$head.rotation.x += CameraInpDir.y * delta
	$head.rotation.x = clamp($head.rotation.x, -PI / 2.0, PI / 2.0)
	$head.rotation.y -= CameraInpDir.x * delta
	CameraInpDir = Vector2.ZERO
	
	var KeyboardInput: Vector2 = Input.get_vector("ui_a","ui_d","ui_w","ui_s")
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
	$MeshInstance3D.rotation.y = collision_shape_3d.rotation.y
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y += JUMP_STRENGTH


func _unhandled_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and								#waiting for mouse event inside window
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED):
		CameraInpDir = event.relative * MOUSE_SENS 						#screen_relative
