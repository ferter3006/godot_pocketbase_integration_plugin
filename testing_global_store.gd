extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalStore.get_model("puntuaciones", mifunction)

func mifunction(result, x):
	if result == GlobalStore.Result.OK:
		print("es ok, ", result)
	print("este", x[0].points)
