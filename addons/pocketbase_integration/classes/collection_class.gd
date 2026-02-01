class_name Collection
extends Node

var model: String

signal list_received(success, data)
signal create_completed(success, data)
signal update_completed(success, data)

func _init(model_name: String) -> void:
	model = model_name

func getList() -> Array:
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model + "/records"
	var headers = ["Content-type: application/json", "Accept: application/json"]
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_get_list_completed)
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Collection.getList: Error al solicitar lista: " + str(err))
		emit_signal("list_received", false, "Error al solicitar lista: " + str(err))
		return await self.list_received
	return await self.list_received


func _on_get_list_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	if response_code == 200:
		var data_json = JSON.parse_string(response_text)
		if typeof(data_json) == TYPE_DICTIONARY and data_json.has("items"):
			emit_signal("list_received", true, data_json.items)
			return
	emit_signal("list_received", false, response_text)

func create(data) -> Dictionary:
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model + "/records"
	var headers = ["Content-type: application/json", "Accept: application/json"]
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_create_completed)
	var err = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if err != OK:
		push_error("Collection.create: Error al crear registro: " + str(err))
		emit_signal("create_completed", false, "Error al crear registro: " + str(err))
		return await self.create_completed
	return await self.create_completed


func _on_create_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	if response_code == 200 or response_code == 201:
		var data_json = JSON.parse_string(response_text)
		emit_signal("create_completed", true, data_json)
		return
	emit_signal("create_completed", false, response_text)

func update(id, data) -> Dictionary:
	if id == "":
		push_error("Collection.update: Se requiere id para actualizar.")
		emit_signal("update_completed", false, "Se requiere id para actualizar.")
		return await self.update_completed
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model + "/records/" + id
	var headers = ["Content-type: application/json", "Accept: application/json"]
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_update_completed)
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	if err != OK:
		push_error("Collection.update: Error al actualizar registro: " + str(err))
		emit_signal("update_completed", false, "Error al actualizar registro: " + str(err))
		return await self.update_completed
	return await self.update_completed


func _on_update_completed(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	if response_code == 200:
		var data_json = JSON.parse_string(response_text)
		emit_signal("update_completed", true, data_json)
		return
	emit_signal("update_completed", false, response_text)
