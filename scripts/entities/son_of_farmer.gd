extends CharacterBody3D

class_name SonOfFarmer

@export var speed: float = 7.0
@export var chase_range: float = 12.0
@export var yorchik_instance: Node3D 
@onready var player_detector: Area3D = $PlayerDetector
var target_position: Vector3 = Vector3.ZERO

func _physics_process(delta):
	var player = get_nearby_player()
	if player:
		target_position = player.global_position
	elif yorchik_instance and yorchik_instance.last_bark_position != Vector3.ZERO:
		target_position = yorchik_instance.last_bark_position
	
	if target_position != Vector3.ZERO:
		var move_direction = (target_position - global_position).normalized()
		velocity = move_direction * speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()

func get_nearby_player():
	for body in player_detector.get_overlapping_bodies():
		if body.is_in_group("fox_player"):
			return body
	return null
