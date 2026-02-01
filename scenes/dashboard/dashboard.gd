extends Node2D

const projectCardScene : PackedScene = preload("res://scenes/project_elements/project_card.tscn")
const createNewProject : PackedScene = preload("res://scenes/project_elements/create_new_project.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fetchProjects()

func _on_projects_response(error, response):
	if error == FAILED:
		return

	for child in $ScrollContainer/GridContainer.get_children():
		child.queue_free()
		
	for project in response:
		var newProjectCard = projectCardScene.instantiate()
		newProjectCard.project = project
		newProjectCard.delete_action.connect(fetchProjects)
		$ScrollContainer/GridContainer.add_child(newProjectCard)

func _on_new_project_pressed() -> void:
	var newP : CreateNewProjectCard = createNewProject.instantiate()
	newP.newProjectCreated.connect(fetchProjects)
	self.add_child(newP)

func fetchProjects():
	PB.getList("projects", {}, _on_projects_response)

func _on_logout_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/login/login_scene.tscn")
