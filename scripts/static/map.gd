extends Node3D

const FOX = preload("res://scenes/entities/fox.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn(FOX)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func spawn(player_prel) -> void:
	var player_inst = player_prel.instantiate()
	player_inst.position += Vector3(-32, 3, -76)
	player_inst.SOMETEXT = "Знайдіть паркан"
	add_child(player_inst)
