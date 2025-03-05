extends ColorRect



func to_black():
	get_tree().get_first_node_in_group("menu").visibitity = true
	for i: int in 100:
		await get_tree().create_timer(0.01).timeout
		$".".color = Color(0,0,0,i/100.0)


func _ready() -> void:
	add_to_group("black_screen")
#
#func _process(delta: float) -> void:
	#pass
