extends Node2D

var todoCard : PackedScene = preload("res://scenes/Tasks/task_card.tscn")
var todoCardCompleted : PackedScene = preload("res://scenes/Tasks/task_small_card.tscn")
var todoCreate : PackedScene = preload("res://scenes/Tasks/create_new_task.tscn")

func _ready() -> void:
	fetchTodos()

func _on_get_todos_response(result, data):
	if result != OK:
		return
	
	for child in $ScrollContainer/GridContainer.get_children():
		child.queue_free()
	
	for child in $ScrollContainer2/GridContainerCompleted.get_children():
		child.queue_free()
	
	for todo in data:
		
		if todo.state != "completed":
			var newT = todoCard.instantiate()
			newT.todo = todo
			newT.todoUpdated.connect(fetchTodos)
			$ScrollContainer/GridContainer.add_child(newT)
		
		else:
			var newT = todoCardCompleted.instantiate()
			newT.get_child(0).todo = todo
			newT.get_child(0).todoUpdated.connect(fetchTodos)
			$ScrollContainer2/GridContainerCompleted.add_child(newT)

func fetchTodos():
	PB.getList("todos", {"project_id" : Global.project["id"]}, _on_get_todos_response)

func _on_new_task_pressed() -> void:
	var newT = todoCreate.instantiate()
	newT.taskCreated.connect(fetchTodos)
	self.add_child(newT)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")
