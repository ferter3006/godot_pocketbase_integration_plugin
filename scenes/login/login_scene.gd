extends Node2D

var userpass : PackedScene = preload("res://scenes/dashboard/user_pass_form.tscn")

func _on_user_pass_log_in_pressed() -> void:
	var form = userpass.instantiate()
	get_tree().root.add_child(form)

func _on_google_log_in_pressed() -> void:
	UserAuth.AuthWithGoogle()

func _on_token_set():
	get_tree().change_scene_to_file("res://scenes/dashboard/dashboard.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit(0)

func _on_sign_up_pressed() -> void:
	var form = userpass.instantiate()
	form.isCreatingAcc = true
	get_tree().root.add_child(form)
