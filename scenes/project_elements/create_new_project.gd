class_name CreateNewProjectCard
extends Node2D

signal newProjectCreated
@onready var Title = $Node2D/title
@onready var Desc = $Node2D/description

func _on_create_btn_pressed() -> void:
	
	if Title.text.length() < 5 || Desc.text.length() < 3:
		return
		
	var body = {
		"title": Title.text,
		"description": Desc.text,
		"owner_id": UserAuth.currentUser.id
	}
	PB.create("projects", body, _on_create_response)

func _on_cancel_btn_pressed() -> void:
	self.queue_free()

func _on_create_response(_error, _data):
	newProjectCreated.emit()
	self.queue_free()
