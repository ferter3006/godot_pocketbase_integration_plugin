extends Node

signal todoUpdated

const confirmAction : PackedScene = preload("res://scenes/project_elements/confirmacion_borrar.tscn")

var todo : Dictionary = {
	"id": "",
	"title": "",
	"description": "",
	"state" : ""
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$title.text = todo["title"]
	$desc.text = todo["description"]
	$state.text = todo["state"]
	$state.uppercase = true
	
	var sb = $state.get_theme_stylebox("normal")
	if sb is StyleBoxFlat:
		# Duplicar para que sea único
		sb = sb.duplicate() as StyleBoxFlat

		# Asignar color según estado
		match todo["state"]:
			"pending":
				sb.bg_color = Colors.todo_pending
			"inProgress":
				sb.bg_color = Colors.todo_inProgress
			"completed":
				sb.bg_color = Colors.todo_completed

	# Aplicar override solo a este nodo
	$state.add_theme_stylebox_override("normal", sb)

func _on_borrar_pressed() -> void:
	var confirm = confirmAction.instantiate()
	confirm.confirm_action.connect(_on_confirm_delete)
	get_tree().root.add_child(confirm)

func _on_confirm_delete():
	PB.delete("todos", todo["id"], _on_delete_response)

func _on_delete_response(result, _data):
	if result == OK:
		todoUpdated.emit()

func _on_todo_updated(result, _data):
	if result == OK:
		todoUpdated.emit()

func _on_restore_task_pressed() -> void:
	PB.update("todos", todo.id, {"state" : "pending"}, _on_todo_updated)
	
