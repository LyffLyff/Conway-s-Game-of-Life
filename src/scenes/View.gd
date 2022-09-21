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
		get_parent().update()
		self.offset.y += 0.5 * zoom.x * 10
	if Input.is_action_pressed("ui_up"):
		get_parent().update()
		self.offset.y -= 0.5 * zoom.x * 10
	if Input.is_action_pressed("ui_left"):
		get_parent().update()
		self.offset.x -= 0.5 * zoom.x * 10
	if Input.is_action_pressed("ui_right"):
		get_parent().update()
		self.offset.x += 0.5 * zoom.x * 10
