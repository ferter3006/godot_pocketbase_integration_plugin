extends Node2D

@onready var email = $Node2D/email
@onready var password = $Node2D/passw

var isCreatingAcc = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !isCreatingAcc:
		$Node2D/Label4.text = "SING IN"
	else:
		$Node2D/Label4.text = "SING UP"

	$Node2D/email.grab_focus()

func _on_create_btn_pressed() -> void:
	if !isCreatingAcc:
		UserAuth.AuthWithPassword(email.text, password.text, _on_auth_callback)
	else:
		UserAuth.AuthRegister(email.text, email.text, password.text, password.text, _on_register_callback)

func _on_auth_callback(error, data):
	if error == OK:
		get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")

func _on_cancel_btn_pressed() -> void:
	self.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tab"):
		$Node2D/passw.grab_focus()

func _on_register_callback(error, _data):
	var alert = AcceptDialog.new()
	if error == OK:
		alert.dialog_text = "Perfect! now sign in"
	else:
		alert.dialog_text = "Fail! for some reason!"
	get_tree().root.add_child(alert)
	alert.popup_centered()
	self.queue_free()
