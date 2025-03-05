extends Control

func hide_black_screen() -> void:
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$ColorRect.color = Color(0,0,0,(i-100.0)/-100.0)
	$ColorRect.visible = false

func _ready() -> void:
	hide_black_screen()
	
func _process(delta: float) -> void:
	pass
