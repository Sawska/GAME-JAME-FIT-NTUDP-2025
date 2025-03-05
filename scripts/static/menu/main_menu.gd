extends Control
#TODO 
const TEMP_SCENE_FOR_TESTING: Resource = preload("res://scenes/static/temp_scene_for_testing.tscn")
const MAP: Resource = preload("res://scenes/static/map.tscn")
const FOX_HOLE: Resource = preload("res://scenes/static/fox_hole.tscn")
const FOX_HOLE_NIGHT = preload("res://scenes/static/temp_scene_for_testing.tscn")

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_esc"):
		get_tree().quit()

func _on_btn_new_game_pressed() -> void:
	$ColorRect.visible = true
	for i: int in 101:
		await get_tree().create_timer(0.01).timeout
		$ColorRect.color = Color(0,0,0,i/100.0)
	get_tree().change_scene_to_packed(FOX_HOLE)


func _on_btn_about_authors_pressed() -> void:
	pass #TODO create authors page dedicated only for us


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_btn_danyasmap_pressed() -> void:
	get_tree().change_scene_to_packed(MAP)


func _on_btn_cavemap_pressed() -> void:
	get_tree().change_scene_to_packed(FOX_HOLE)


func _on_btn_testmap_pressed() -> void:
	get_tree().change_scene_to_packed(TEMP_SCENE_FOR_TESTING)


func _on_asf_pressed() -> void:
	get_tree().change_scene_to_packed(FOX_HOLE_NIGHT)
