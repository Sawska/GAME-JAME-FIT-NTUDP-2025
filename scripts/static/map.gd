extends Node3D

const CHICKEN_BOT = preload("res://scenes/entities/chicken_bot.tscn")
const DOG_BOT = preload("res://scenes/entities/dog_bot.tscn")
const FOX_HOLE: Resource = preload("res://scenes/static/fox_hole.tscn")
const FOX_HOLE_NIGHT: Resource = preload("res://scenes/static/fox_hole_night.tscn")

var MainLife = 5
var HaveAlreadySeen: bool = false
var HaveAlreadyFound: bool = false
var GameStarted: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn()
	var fox = get_tree().get_first_node_in_group("fox")
	fox.show_some_temp_text("Знайдіть паркан")
	add_to_group("main_map")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func spawn() -> void:
	var player_inst = load("res://scenes/entities/fox.tscn").instantiate()
	player_inst.position += Vector3(-20, 3, -63)
	player_inst.Life_time = MainLife
	player_inst.OnTheMap = true
	add_child(player_inst)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox") and !HaveAlreadySeen:
		body.get_tree().get_first_node_in_group("fox").show_some_temp_text("Знайдіть отвір у паркані", 3)
		HaveAlreadySeen = true


func _on_area_near_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox") and !HaveAlreadyFound:
		body.get_tree().get_first_node_in_group("fox").show_some_temp_text("Зайдіть усередину загону", 3)
		HaveAlreadyFound = true

func _on_area_inside_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox") and !GameStarted:
		var fox = body.get_tree().get_first_node_in_group("fox")
		fox.CANCONTROL = false
		fox.velocity = Vector3(0,0,0)
		fox.KeyboardInput = Vector2(0,0)
		await fox.show_some_temp_text("Вам дуже потрібні курочки \n Спіймайте якомога більше та \n остерігайтесь собак", 5)
		fox.COUNTER = true
		fox.check_for_counter()
		fox.CANCONTROL = true
		spawn_animals_day(50,1, MainLife)
		GameStarted = true

func spawn_inside_fence(bot: PackedScene, Life_time: float) -> void:
	var bot_instance = bot.instantiate()
	bot_instance.Life_time = Life_time
	bot_instance.position = Vector3(randf_range(100, 30), 0.0, randf_range(-76, -8))
	add_child(bot_instance)

func spawn_animals_day(Chickens: int, Dogs: int, Life_time: float = 60) -> void:
	for i in Chickens:
		spawn_inside_fence(CHICKEN_BOT, Life_time)
	for i in Dogs:
		spawn_inside_fence(DOG_BOT, Life_time)


func _on_area_door_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox"):
		var fox = body.get_tree().get_first_node_in_group("fox")
		if fox.EndedGame == true:
			fox.CANCONTROL = false
			fox.velocity = Vector3(0,0,0)
			fox.KeyboardInput = Vector2(0,0)
			await fox.show_black_screen()
			await get_tree().change_scene_to_packed(FOX_HOLE_NIGHT)
