extends CharacterBody3D

class_name Yorchik

@export var bark_range: float = 10.0
@onready var fox_detector: Area3D = $FoxDetector
var last_bark_position: Vector3 = Vector3.ZERO

func _physics_process(delta):
	for body in fox_detector.get_overlapping_bodies():
		if body.is_in_group("fox_player"):
			bark(body.global_position)
			break

func bark(position: Vector3):
	last_bark_position = position
	print("Yorchik: Bark! Bark! Fox detected at ", position)
