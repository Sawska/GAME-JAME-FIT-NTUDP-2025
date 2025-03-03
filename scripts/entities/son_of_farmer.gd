extends CharacterBody3D  # Используем CharacterBody3D вместо Node3D

class_name SonOfFarmer

@export var speed: float = 7.0
@export var chase_range: float = 12.0
@export var yorchik_instance: Node3D
@onready var player_detector: Area3D = $PlayerDetector
@onready var scream_image: TextureRect = $ScreamImage  # Ссылка на картинку скримера (сделаем её прозрачной по умолчанию)
@onready var scream_sound: AudioStreamPlayer3D = $ScreamSound  # Звуковой эффект скримера
@export var scream_duration: float = 3.0  # Время показа изображения (в секундах)
var target_position: Vector3 = Vector3.ZERO
var scream_threshold: float = 5.0  # Расстояние, при котором активируется скример

func _ready():
	# Убедимся, что картинка и звук скрыты и не активированы по умолчанию
	if scream_image:
		scream_image.visible = false
	else:
		print("Warning: ScreamImage not found!")

	if scream_sound:
		scream_sound.stop()
	else:
		print("Warning: ScreamSound not found!")

func _physics_process(delta):
	var player = get_nearby_player()
	if player:
		target_position = player.global_position
	elif yorchik_instance and yorchik_instance.last_bark_position != Vector3.ZERO:
		target_position = yorchik_instance.last_bark_position
	
	if target_position != Vector3.ZERO:
		var move_direction = (target_position - global_position).normalized()
		velocity = move_direction * speed  # velocity теперь будет работать, так как это CharacterBody3D
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()  # В Godot 4.3 move_and_slide() больше не требует аргументов, он использует свойство velocity по умолчанию
	
	# Проверка на приближение к лисе
	check_for_fox_scream()

func get_nearby_player():
	for body in player_detector.get_overlapping_bodies():
		if body.is_in_group("fox"):
			return body
	return null

# Функция для проверки расстояния и активации скримера
func check_for_fox_scream():
	var player = get_nearby_player()
	if player:
		var distance_to_fox = global_position.distance_to(player.global_position)
		
		# Если фермер слишком близко к лисе, активируем скример
		if distance_to_fox < scream_threshold:
			if scream_sound and not scream_sound.playing:  # Проверяем, что scream_sound существует и не играет
				activate_scream()

# Функция активации скримера
func activate_scream():
	# Включаем картинку и звук, только если они существуют
	if scream_image:
		scream_image.visible = true
	else:
		print("Warning: ScreamImage is not available for activation!")

	if scream_sound:
		scream_sound.play()
	else:
		print("Warning: ScreamSound is not available for activation!")

	# Ждем определенное время, а потом скрываем картинку и останавливаем звук
	await get_tree().create_timer(scream_duration).timeout
	if scream_image:
		scream_image.visible = false
	if scream_sound:
		scream_sound.stop()
