extends Camera2D


#CONSTANTS
const MIN_ZOOM : float = 0.05
const MAX_ZOOM : float = 5.0


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			
			#ZOOMING IN/OUT
			if event.button_index == BUTTON_WHEEL_DOWN:
				if zoom.x < MAX_ZOOM:
					self.set_zoom(zoom + Vector2(0.05,0.05))
					get_parent().update()
			elif event.button_index == BUTTON_WHEEL_UP:
				if zoom.x > MIN_ZOOM:
					self.set_zoom(zoom - Vector2(0.025,0.025))
					get_parent().update()


func _process(var _delta : float):
	if Input.is_action_pressed("ui_down"):
		self.offset.y += 0.5 * zoom.x * 10
		get_parent().update()
	if Input.is_action_pressed("ui_up"):
		self.offset.y -= 0.5 * zoom.x * 10
		get_parent().update()
	if Input.is_action_pressed("ui_left"):
		self.offset.x -= 0.5 * zoom.x * 10
		get_parent().update()
	if Input.is_action_pressed("ui_right"):
		self.offset.x += 0.5 * zoom.x * 10
		get_parent().update()
