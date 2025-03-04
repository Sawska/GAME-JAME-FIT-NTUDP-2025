extends Node3D

const ENTITY : Resource = preload("res://scenes/entities/fox.tscn")

func _ready() -> void:
	#spawn(ENTITY)
	pass


#func _process(delta: float) -> void:
	#pass


func spawn(player_prel) -> void:
	var player_inst = player_prel.instantiate()
	player_inst.position.y += 2
	add_child(player_inst)
	print("success")
