extends LineEdit

signal newTask(task : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("intro"):
		if self.has_focus():
			if self.text.length() > 3:
				newTask.emit(self.text)
				self.text = ""
			else:
				self.text = ""
