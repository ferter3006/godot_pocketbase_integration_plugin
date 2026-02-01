extends Node

# Global store para acceder a cualquier modelo de PocketBase

# Enum para resultados de callback
enum Result { OK, FAIL }

# Realiza un GET a /api/collections/{model_name}/records
# callback: función opcional a llamar con los datos recibidos
func getList(model_name: String, filters: Dictionary = {}, callback: Callable = Callable()):
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model_name + "/records"
	# Construir parámetros de filtro, soportando 'filter' como cadena especial
	if filters.size() > 0:
		var params = []
		for k in filters.keys():
			var v = filters[k]
			params.append(str(k) + '="' + str(v) + '"')
		
		var filter_string = '(' + ' && '.join(params) + ')'
		var encoded_filter = filter_string.uri_encode()
		url += '?filter=' + encoded_filter
		
	var headers = ["Content-type: application/json", "Accept: application/json"]
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST] GET ", url)
		print("[PocketBase][REQUEST] Headers: ", headers)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed.bind(http))
	var err = http.request(url, headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Error al solicitar modelo '" + model_name + "': " + str(err))
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al solicitar modelo '" + model_name + "': " + str(err))
	http.set_meta("callback", callback)
	http.set_meta("model_name", model_name)

func _on_request_completed(result, response_code, headers, body, http):
	var model_name = http.get_meta("model_name", "")
	var callback = http.get_meta("callback", Callable())
	var response_text = body.get_string_from_utf8()
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][RESPONSE] ", model_name, " code:", response_code)
		print("[PocketBase][RESPONSE] Body: ", response_text)
	var records = []
	if response_code == 200:
		var data_json = JSON.parse_string(response_text)
		if typeof(data_json) == TYPE_DICTIONARY and data_json.has("items"):
			records = data_json.items
			if callback.is_valid():
				callback.call(Result.OK, records)
			return
		else:
			push_error("Respuesta JSON inesperada para '" + model_name + "': " + response_text)
			if callback.is_valid():
				callback.call(Result.FAIL, "Respuesta JSON inesperada para '" + model_name + "': " + response_text)
	else:
		push_error("Error al recibir datos de '" + model_name + "': " + response_text)
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al recibir datos de '" + model_name + "': " + response_text)
	http.queue_free()

func create(model_name: String, data: Dictionary, callback: Callable = Callable()):
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model_name + "/records"
	var headers = ["Content-type: application/json", "Accept: application/json"]
	# Añadir token de usuario si está disponible en UserAuth.currentUser.token
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST] POST ", url)
		print("[PocketBase][REQUEST] Headers: ", headers)
		print("[PocketBase][REQUEST] Body: ", JSON.stringify(data))
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_create_completed.bind(http))
	var err = http.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if err != OK:
		push_error("Error al crear modelo '" + model_name + "': " + str(err))
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al crear modelo '" + model_name + "': " + str(err))
	http.set_meta("callback", callback)
	http.set_meta("model_name", model_name)
	http.set_meta("data", data)

func _on_create_completed(result, response_code, headers, body, http):
	var model_name = http.get_meta("model_name", "")
	var callback = http.get_meta("callback", Callable())
	var response_text = body.get_string_from_utf8()
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][RESPONSE] ", model_name, " code:", response_code)
		print("[PocketBase][RESPONSE] Body: ", response_text)
	if response_code == 200 or response_code == 201:
		var data_json = JSON.parse_string(response_text)
		if callback.is_valid():
			callback.call(Result.OK, data_json)
		return
	else:
		push_error("Error al crear modelo '" + model_name + "': " + response_text)
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al crear modelo '" + model_name + "': " + response_text)
	http.queue_free()

func delete(model_name: String, record_id: String, callback: Callable = Callable()):
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model_name + "/records/" + record_id
	var headers = ["Content-type: application/json", "Accept: application/json"]
	# Añadir token de usuario si está disponible en UserAuth.currentUser.token
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST] DELETE ", url)
		print("[PocketBase][REQUEST] Headers: ", headers)
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_delete_completed.bind(http))
	var err = http.request(url, headers, HTTPClient.METHOD_DELETE)
	if err != OK:
		push_error("Error al eliminar registro '" + record_id + "' de modelo '" + model_name + "': " + str(err))
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al eliminar registro '" + record_id + "' de modelo '" + model_name + "': " + str(err))
	http.set_meta("callback", callback)
	http.set_meta("model_name", model_name)
	http.set_meta("record_id", record_id)

func _on_delete_completed(result, response_code, headers, body, http):
	var model_name = http.get_meta("model_name", "")
	var record_id = http.get_meta("record_id", "")		
	var callback = http.get_meta("callback", Callable())
	var response_text = body.get_string_from_utf8()
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][RESPONSE] ", model_name, " DELETE code:", response_code)
		print("[PocketBase][RESPONSE] Body: ", response_text)
	if response_code == 200 or response_code == 204:
		if callback.is_valid():
			callback.call(Result.OK, "Registro '" + record_id + "' eliminado correctamente de modelo '" + model_name + "'.")
		return
	else:
		push_error("Error al eliminar registro '" + record_id + "' de modelo '" + model_name + "': " + response_text)
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al eliminar registro '" + record_id + "' de modelo '" + model_name + "': " + response_text)
	http.queue_free()

func update(model_name: String, record_id: String, data: Dictionary, callback: Callable = Callable()):
	var url = ProjectSettings.get_setting("pocketbase/base_url") + "/api/collections/" + model_name + "/records/" + record_id
	var headers = ["Content-type: application/json", "Accept: application/json"]
	# Añadir token de usuario si está disponible en UserAuth.currentUser.token
	headers.append("Authorization: Bearer " + UserAuth.currentUser.token)
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST] PATCH ", url)
		print("[PocketBase][REQUEST] Headers: ", headers)
		print("[PocketBase][REQUEST] Body: ", JSON.stringify(data))
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_update_completed.bind(http))
	var err = http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	if err != OK:
		push_error("Error al actualizar modelo '" + model_name + "': " + str(err))
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al actualizar modelo '" + model_name + "': " + str(err))
	http.set_meta("callback", callback)
	http.set_meta("model_name", model_name)
	http.set_meta("record_id", record_id)
	http.set_meta("data", data)

func _on_update_completed(result, response_code, headers, body, http):
	var model_name = http.get_meta("model_name", "")
	var callback = http.get_meta("callback", Callable())
	var response_text = body.get_string_from_utf8()
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][RESPONSE] ", model_name, " code:", response_code)
		print("[PocketBase][RESPONSE] Body: ", response_text)
	if response_code == 200:
		var data_json = JSON.parse_string(response_text)
		if callback.is_valid():
			callback.call(Result.OK, data_json)
		return
	else:
		push_error("Error al actualizar modelo '" + model_name + "': " + response_text)
		if callback.is_valid():
			callback.call(Result.FAIL, "Error al actualizar modelo '" + model_name + "': " + response_text)
	http.queue_free()	
