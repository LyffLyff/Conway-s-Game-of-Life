#21.09.22
#Conway's Game of Life
#
#Rules:
#-A dead cell with exactly 3 neighbours get's born
#-A living cell with LESS than 2 neighbours dies the next generation
#-A living cell with 2 or 3 neighbours stays alive
#-A living cell with more than 3 neighbours dies next generation

extends Node2D

#NODES
onready var wrld : TileMap = $World
onready var cam : Camera2D = $View
onready var play : TextureButton = $UI/MainUI/HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Play
onready var gen_amount : Label = $UI/MainUI/HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/GenAmount


#CONTANTS
var play_textures : Array = [
	preload("res://src/assets/icons/play_72px.png"),
	preload("res://src/assets/icons/stop_72px.png")
]


#VARIABLES
var gen : int = 1
var running : bool = false
var birthed_cells : PoolVector2Array = []
var killed_cells : PoolVector2Array = []
var cells_to_check : Array = []
var living_cells : Array = []


func _ready():
	
	self.set_physics_process(false)


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			#World2Map not neccessary since each tile is 1px
			#Therefore the global mouse position is the actual tile
			#but it's more accurate withz it sooooooo
			#Draw with mouse
			AddCell( wrld.world_to_map( get_global_mouse_position() ) )
		elif Input.is_mouse_button_pressed(BUTTON_RIGHT):
			var clicked_cell : Vector2 = wrld.world_to_map( get_global_mouse_position() )
			if living_cells.has( clicked_cell ):
				DeleteCell( clicked_cell )
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			match event.button_index:
				BUTTON_LEFT:
					#Click Single Cell
					AddCell( wrld.world_to_map( get_global_mouse_position() ) )
				BUTTON_RIGHT:
					var clicked_cell : Vector2 = wrld.world_to_map( get_global_mouse_position() )
					if living_cells.has( clicked_cell ):
						DeleteCell( clicked_cell )
	
	if event is InputEventKey:
		if event.is_pressed():
			match event.scancode:
				KEY_SPACE:
					#Advances by one Gen
					self.set_physics_process(true)


func _physics_process(var _delta : float):
	birthed_cells = []
	killed_cells = []
	
	GetAffectedCells()
	
	#Checking General Rules
	for i in cells_to_check:
		ApplyDeadRule(i, GetNeighbours(i) )

	#Apply Living Rule
	for i in living_cells:
		ApplyLivingRules(i, GetNeighbours(i))
	
	for i in birthed_cells:
		if !living_cells.has(i):
			living_cells.push_back(i)
	
	#Updating Changed Cells
	UpdateWorld()
	gen += 1
	gen_amount.set_text(str(gen))
	if !running:
		self.set_physics_process(false)


func UpdateWorld() -> void:
	#Updating Changed Cells
	for i in killed_cells:
		wrld.set_cellv(i,-1)
		if living_cells.has(i):
			living_cells.erase(i)
	for i in birthed_cells:
		wrld.set_cellv(i,0)


func BirthCell(var pos : Vector2) -> void:
	birthed_cells.push_back(pos)


func AddCell(var pos : Vector2) -> void:
	#Adds the cell directly and doesn't need to wait for next gen
	living_cells.push_back(pos)
	wrld.set_cellv(pos,0)


func DeleteCell(var pos : Vector2) -> void:
	#Deletes the living cell without waiting for the next generation
	wrld.set_cellv(pos,-1)
	living_cells.erase(pos)


func KillCell(var pos : Vector2) -> void:
	#wrld.set_cellv(pos,-1)
	killed_cells.push_back(pos)


func ApplyLivingRules(var living_cell : Vector2, var neighbours : int) -> void:
	#Applies rules that only affect living cells
	if neighbours < 2 or neighbours > 3:
		KillCell(living_cell)


func ApplyDeadRule(var pos : Vector2, var neighbours : int) -> void:
	if neighbours == 3:
		BirthCell(pos)


func GetAffectedCells() -> void:
	var temp : Vector2
	cells_to_check = []
	for i in living_cells:
		#Retrieving all cells that need to be checked for general rule
		for x in range(-1,2):
			for y in range(-1,2):
				if x == 0 && y == 0:
					continue
				temp = Vector2(i.x + x, i.y + y)
				#if !cells_to_check.has(temp) and !living_cells.has(temp):
				#"overchecking" tiles seems to be wayy faster than checking ecatly which need to be checked
				cells_to_check.push_back(temp)


func GetNeighbours(var pos : Vector2) -> int:
	var neighbours : int = 0
	
	for x in range(-1,2,1):
		for y in range(-1,2,1):
			if x == 0 && y == 0:
				continue;
			
			if wrld.get_cell(pos.x + x, pos.y + y) != -1:
				neighbours += 1
	return neighbours


func _draw():
	var size = get_viewport_rect().size  * cam.zoom / 2
	var cam_pos = cam.offset
	for i in range(int((cam_pos.x - size.x) / 1) - 1, int((size.x + cam_pos.x) / 1) + 1):
		draw_line(Vector2(i * 1, cam_pos.y + size.y + 100), Vector2(i * 1, cam_pos.y - size.y - 100), "111111")
	for i in range(int((cam_pos.y - size.y) / 1) - 1, int((size.y + cam_pos.y) / 1) + 1):
		draw_line(Vector2(cam_pos.x + size.x + 100, i * 1), Vector2(cam_pos.x - size.x - 100, i * 1), "111111")


func _on_Start_pressed():
	running = true
	self.set_physics_process(true)


func _on_Stop_pressed():
	self.set_physics_process(false)
	running = false


func _on_Play_pressed():
	gen = 1
	running = !running
	self.set_physics_process(running)
	play.texture_normal = play_textures[int(running)]
	
