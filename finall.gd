extends Control

func hide_black_screen() -> void:
	for i in 101:
		await get_tree().create_timer(0.01).timeout
		$ColorRect.color = Color(0,0,0,(i-100.0)/-100.0)
	$ColorRect.visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
