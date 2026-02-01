extends Control

signal delete_action

var confirmActionScene : PackedScene = preload("res://scenes/project_elements/confirmacion_borrar.tscn")
var projectDashboardScene : PackedScene = preload("res://scenes/project_dashboard/project_dashboard.tscn")

var project : Dictionary = {
	"id": "",
	"title": "",
	"description": "",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$title.text = project.title
	$desc.text = project.description

func _on_entrar_pressed() -> void:
	Global.project = project
	get_tree().change_scene_to_packed(projectDashboardScene)

func _on_borrar_pressed() -> void:
	var conf = confirmActionScene.instantiate()
	conf.descrp = conf.project
	conf.confirm_action.connect(_on_confirm_action)
	get_tree().root.add_child(conf)

func _on_confirm_action():
	PB.delete("projects", project.id, _on_delete_response)

func _on_delete_response(result, _message):
	if result == OK:
		delete_action.emit()
