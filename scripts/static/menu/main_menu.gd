extends Control
#TODO 
const TEMP_SCENE_FOR_TESTING: Resource = preload("res://scenes/static/temp_scene_for_testing.tscn")
const NIGHTMAP: Resource = preload("res://scenes/static/nightmap.tscn")
const FOX_HOLE: Resource = preload("res://scenes/static/fox_hole.tscn")

func _ready() -> void:
	#DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	
func _on_btn_new_game_pressed() -> void:
	get_tree().change_scene_to_packed(TEMP_SCENE_FOR_TESTING)


func _on_btn_about_authors_pressed() -> void:
	pass #TODO create authors page dedicated only for us


func _on_btn_quit_pressed() -> void:
	get_tree().quit()


func _on_btn_danyasmap_pressed() -> void:
	get_tree().change_scene_to_packed(NIGHTMAP)


func _on_btn_cavemap_pressed() -> void:
	get_tree().change_scene_to_packed(FOX_HOLE)
