extends LineEdit

signal newTask(task : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("intro"):
		if self.has_focus():
			if self.text.length() > 3:
				newTask.emit(self.text)
				self.clear()
				self.grab_focus()
			else:
				self.clear()
				self.grab_focus()
		get_viewport().set_input_as_handled()
