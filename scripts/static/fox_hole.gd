extends Node3D

const ENTITY : Resource = preload("res://scenes/entities/fox.tscn")
const MAP: Resource = preload("res://scenes/static/map.tscn")

func _ready() -> void:
	spawn(ENTITY)
	var fox = get_tree().get_first_node_in_group("fox")
	await fox.show_some_temp_text("Ви - Маленька лисичка \n Знайдіть вихід з печери")
	


#func _process(delta: float) -> void:
	#pass


func spawn(player_prel) -> void:
	var player_inst = load("res://scenes/entities/fox.tscn").instantiate()
	player_inst.position.y += 2
	add_child(player_inst)
	print("success")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("fox"):
		var fox = body.get_tree().get_first_node_in_group("fox")
		fox.CANCONTROL = false
		fox.velocity = Vector3(0,0,0)
		fox.KeyboardInput = Vector2(0,0)
		fox.velocity = Vector3(0,0,0)
		await fox.show_black_screen()
	get_tree().change_scene_to_packed(MAP)
