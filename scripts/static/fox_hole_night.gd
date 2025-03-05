extends StaticBody3D

const MAP_NIGHT = preload("res://scenes/static/map_night.tscn")

func _ready() -> void:
	spawn()
	var fox = get_tree().get_first_node_in_group("fox")
	await fox.show_some_temp_text("Ви врятували багато курочок\nвід злого фермера!\nЧас відпочити", 5)
	await get_tree().create_timer(6).timeout
	await fox.show_black_screen()
	await get_tree().create_timer(3).timeout
	get_tree().change_scene_to_packed(MAP_NIGHT)

func _process(delta: float) -> void:
	pass

func spawn() -> void:
	var player_inst = load("res://scenes/entities/fox.tscn").instantiate()
	player_inst.position.y += 2
	add_child(player_inst)
	print("success")
