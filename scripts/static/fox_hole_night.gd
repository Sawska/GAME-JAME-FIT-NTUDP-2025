extends StaticBody3D

func _ready() -> void:
	await get_tree().create_timer(5).timeout
	var fox = get_tree().get_first_node_in_group("fox")
	await fox.show_some_temp_text("Ви врятували багато курочок\nвід злого фермера!\nЧас відпочити", 5)
	await fox.show_black_screen()
	await get_tree().create_timer(3).timeout
	

func _process(delta: float) -> void:
	pass
