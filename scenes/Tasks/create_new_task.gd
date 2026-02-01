extends Node2D

signal taskCreated

func _on_create_btn_pressed() -> void:
	if $Node2D/title.text.length() < 3:
		return
	
	PB.create("todos", 
	{"title": $Node2D/title.text,
	"description": $Node2D/description.text,
	"state": "pending",
	"project_id": Global.project["id"]
	}, _on_task_created)

func _on_task_created(result, _data):
	if result == OK:
		taskCreated.emit()
	
	self.queue_free()

func _on_cancel_btn_pressed() -> void:
	self.queue_free()
