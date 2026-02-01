@tool
extends EditorPlugin


const userAuth = "UserAuth"
const globalStore = "GlobalStore"
const pb = "PB"

func _enable_plugin() -> void:
	# Add autoloads here.
	add_autoload_singleton(userAuth, "res://addons/pocketbase_integration/services/user_auth.gd")
	add_autoload_singleton(pb, "res://addons/pocketbase_integration/services/pb.gd")

func _disable_plugin() -> void:
	# Remove autoloads here.
	remove_autoload_singleton(userAuth)
	remove_autoload_singleton(globalStore)


func _enter_tree() -> void:
	# -------------------------------
	# ProjectSettings defaults
	# -------------------------------

	# Base Connection URL
	var base_url_key := "pocketbase/base_url"
	if not ProjectSettings.has_setting(base_url_key):
		ProjectSettings.set_setting(base_url_key, "https://127.0.0.1:8090")
		ProjectSettings.set_initial_value(base_url_key, "https://127.0.0.1:8090")

	# Google Auth Polling URL
	var google_auth_url_key := "pocketbase/google_auth_url"
	if not ProjectSettings.has_setting(google_auth_url_key):
		ProjectSettings.set_setting(google_auth_url_key, "https://localhost:5173/godot/")
		ProjectSettings.set_initial_value(google_auth_url_key, "https://localhost:5173/godot/")

	# Google Auth Polling URL
	var google_auth_polling_token_url_key := "pocketbase/google_auth_polling_token_url"
	if not ProjectSettings.has_setting(google_auth_polling_token_url_key):
		ProjectSettings.set_setting(google_auth_polling_token_url_key, "https://127.0.0.1:8090/api/google-polling-token-url")
		ProjectSettings.set_initial_value(google_auth_polling_token_url_key, "https://127.0.0.1:8090/api/google-polling-token-url")

	# Debug API requests/responses
	var debug_api_key := "pocketbase/debug_api_requests"
	if not ProjectSettings.has_setting(debug_api_key):
		ProjectSettings.set_setting(debug_api_key, false)
		ProjectSettings.set_initial_value(debug_api_key, false)

	# Base URL Setting
	ProjectSettings.add_property_info({
		"name": base_url_key,
		"type": TYPE_STRING,
	})

	# Google Auth Polling URL
	ProjectSettings.add_property_info({
		"name": google_auth_url_key,
		"type": TYPE_STRING,
	})

	# Google Auth Polling URL
	ProjectSettings.add_property_info({
		"name": google_auth_polling_token_url_key,
		"type": TYPE_STRING,
	})

	# Debug API requests/responses
	ProjectSettings.add_property_info({
		"name": debug_api_key,
		"type": TYPE_BOOL,
	})


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
