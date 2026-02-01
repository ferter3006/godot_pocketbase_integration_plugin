extends Node2D

signal confirm_action

var project = "This action is gona delete project permanently"
var task = "This action is gona delete task permanently"

var descrp = ""

func _ready() -> void:
	$Node2D/Label.text = "Are you sure?"
	$Node2D/Label2.text = descrp

func _on_cancelar_pressed() -> void:
	self.queue_free()

func _on_aceptar_pressed() -> void:
	confirm_action.emit()
	self.queue_free()
