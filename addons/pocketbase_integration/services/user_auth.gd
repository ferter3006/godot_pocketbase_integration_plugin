extends Node

var http: HTTPRequest
var timerPolling : Timer
var uuid : String # Used for google auth polling token in case of follow my tutorial how-to

# Diccionario con la información completa del usuario autenticado
var currentUser : Dictionary = {}

const URL_register = "/api/collections/users/records" # endpoint para crear usuario en PocketBase
const URL_authWithPassword = "/api/collections/users/auth-with-password" # default in pocketbase

var headers := [
		"Content-type: application/json",
		"Accept: application/json"
	];

func AuthRegister(username: String, email: String, password: String, passwordConfirm: String, callback: Callable = Callable()):
	var body = JSON.stringify({
		'username': username,
		'email': email,
		'password': password,
		'passwordConfirm': passwordConfirm
	})
	var url = ProjectSettings.get_setting("pocketbase/base_url") + URL_register
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST][UserAuth] POST ", url)
		print("[PocketBase][REQUEST][UserAuth] Headers: ", headers)
		print("[PocketBase][REQUEST][UserAuth] Body: ", body)
	http.set_meta("callback", callback)
	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		print("(UserAuth): failed register request")
		if callback.is_valid():
			callback.call(FAILED, "failed register request")

func AuthWithPassword(identity: String, password: String, callback: Callable = Callable()):
	var body = JSON.stringify({
		'identity': identity,
		'password': password
	})
	var url = ProjectSettings.get_setting("pocketbase/base_url") + URL_authWithPassword
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][REQUEST][UserAuth] POST ", url)
		print("[PocketBase][REQUEST][UserAuth] Headers: ", headers)
		print("[PocketBase][REQUEST][UserAuth] Body: ", body)
	http.set_meta("callback", callback)
	var error = http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		body
	)
	if error != OK:
		print("(UserAuth): failed auth request")
		if callback.is_valid():
			callback.call(FAILED, "failed auth request")

func AuthWithGoogle():
	var bytes := Crypto.new().generate_random_bytes(16)
	uuid = "%02x%02x%02x%02x-%02x%02x-%02x%02x-%02x%02x-%02x%02x%02x%02x%02x%02x" % [
	bytes[0], bytes[1], bytes[2], bytes[3],
	bytes[4], bytes[5],
	bytes[6], bytes[7],
	bytes[8], bytes[9],
	bytes[10], bytes[11], bytes[12], bytes[13], bytes[14], bytes[15]]
	
	OS.shell_open("http://localhost:5173/game-google-auth/" + uuid)
	
	startPollingGoogle()

func startPollingGoogle():
	print('start polling func ', 1, ProjectSettings.get_setting("pocketbase/google_auth_polling_token_url"))
	if timerPolling.is_stopped():
		print('was stoped so we start')
		timerPolling.one_shot = false
		timerPolling.wait_time = 1
		timerPolling.start()
		timerPolling.timeout.connect(pollingGoogle)

func pollingGoogle():
	print("1", ProjectSettings.get_setting("pocketbase/base_url"))
	print("2", ProjectSettings.get_setting("pocketbase/google_auth_url"))
	print("3", ProjectSettings.get_setting("pocketbase/google_auth_polling_token_url"))
	var error := http.request(
		ProjectSettings.get_setting("pocketbase/google_auth_polling_token_url") + "/" + uuid,
		headers,
		HTTPClient.METHOD_GET
		)
	
	if error != OK:
		print('houston we have a problem')
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	http = HTTPRequest.new()
	http.request_completed.connect(_on_request_completed)
	
	timerPolling = Timer.new()
	add_child(http)
	add_child(timerPolling)


func _on_request_completed(
	_result: int,
	response_code: int,
	_headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	var response_text := body.get_string_from_utf8()
	var debug = false
	if ProjectSettings.has_setting("pocketbase/debug_api_requests"):
		debug = ProjectSettings.get_setting("pocketbase/debug_api_requests")
	if debug:
		print("[PocketBase][RESPONSE][UserAuth] code:", response_code)
		print("[PocketBase][RESPONSE][UserAuth] Body: ", response_text)
	var data = JSON.parse_string(response_text)
	var callback = http.get_meta("callback", Callable())
	if response_code == 200:
		timerPolling.stop()
		if typeof(data) == TYPE_DICTIONARY:
			if data.has("record"):
				currentUser = data.record
			if data.has("token"):
				currentUser.token = data.token
		if callback.is_valid():
			callback.call(OK, data)
	else:
		print(data)
		if callback.is_valid():
			callback.call(FAILED, data)
