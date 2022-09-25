using Godot;
using System;

/*
Conway's Game of Life
Rules:
-A dead cell with exactly 3 neighbours get's born
-A living cell with LESS than 2 neighbours dies the next generation
-A living cell with 2 or 3 neighbours stays alive
-A living cell with more than 3 neighbours dies next generation
*/

public class Main : Node2D
{

	//NODES
	private TileMap wrld;
	private Camera2D cam;
	private TextureButton play;
	private Label gen_amount;
	private CanvasLayer top_ui;

	//CONSTANTS
	private Resource stop_texture = (Texture)ResourceLoader.Load("res://src/assets/icons/stop_72px.png");
	private Resource play_texture = (Texture)ResourceLoader.Load("res://src/assets/icons/play_72px.png");
	bool menu_loaded = false;
	 Godot.Vector2 x = new Vector2(2,2);

	//VARIABLES
	uint gen = 1;
	bool running = false;
	private Godot.Collections.Array<Vector2> birthed_cells = new Godot.Collections.Array<Vector2>();
	private Godot.Collections.Array<Vector2> killed_cells = new Godot.Collections.Array<Vector2>();
	private Godot.Collections.Array<Vector2> cells_to_check = new Godot.Collections.Array<Vector2>();
	private Godot.Collections.Array<Vector2> living_cells = new Godot.Collections.Array<Vector2>();


	public override void _Draw()
	{
		Godot.Vector2 size = this.GetViewportRect().Size * cam.Zoom / x;
		Godot.Vector2 pos = cam.Offset;
		Godot.Vector2 neg_diff = pos - size;
		Godot.Vector2 pos_diff = pos + size;
		for(Int32 i = (int)neg_diff.x - 1; i < (int)pos_diff.x + 1; i++){
			DrawLine(new Vector2(i, pos_diff.y + 100), new Vector2(i, neg_diff.y - 100), new Color("222222") );
		}
		for(Int32 i = (int)neg_diff.y - 1; i < (int)pos_diff.y + 1; i++){
			DrawLine(new Vector2(pos_diff.x + 100, i), new Vector2(neg_diff.x - 100, i * 1), new Color("222222") );
		}
	}

	public override void _Ready()
	{
		//Initializing Node Refs
		play = GetNode<TextureButton>("MainUI/MainUI/HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/Play");
		cam = GetNode<Camera2D>("View");
		wrld = GetNode<TileMap>("World");
		gen_amount = GetNode<Label>("MainUI/MainUI/HBoxContainer/VBoxContainer/PanelContainer/HBoxContainer/HBoxContainer/GenAmount");
		top_ui = GetNode<CanvasLayer>("TopUI");

		//Ready
		this.SetPhysicsProcess(false);

	}


	public override void _UnhandledInput(InputEvent @event)
	{
		if(@event is InputEventMouseMotion){
			if( Input.IsMouseButtonPressed( ((int)ButtonList.Left)) ){
				GD.Print( wrld.WorldToMap( GetGlobalMousePosition() ) );
				AddCell( wrld.WorldToMap( GetGlobalMousePosition() ) );
			}
			else if( Input.IsMouseButtonPressed( ((int)ButtonList.Right)) ){
				DeleteCell( wrld.WorldToMap( GetGlobalMousePosition() ) );
			}
		}

	}

	public override void _Input(InputEvent @event)
	{
		if( Input.IsActionJustPressed("AddCell") ){
			AddCell( wrld.WorldToMap( GetGlobalMousePosition() ) );
		}
		else if( Input.IsActionJustPressed("DeleteCell") ){
			DeleteCell( wrld.WorldToMap( GetGlobalMousePosition() ) );
		}
		else if( Input.IsActionJustPressed("ClearGrid") ){
			ClearGrid();
		}
		else if( Input.IsActionJustPressed("NextGen") ){
			OnNextGenPressed();
		}
		else if( Input.IsActionJustPressed("ToggleSim") ){
			OnPlayPressed();
		}
	}

	public override void _PhysicsProcess(float delta)
	{
		birthed_cells.Resize(0);
		killed_cells.Resize(0);
		
		GetAffectedCells();
	   
		for(int i = 0; i < cells_to_check.Count; i++){
			ApplyDeadRule( cells_to_check[i], GetNeighbours( cells_to_check[i] ) );
		}

		for(int i = 0; i < living_cells.Count; i++){
			ApplyLivingRules( living_cells[i], GetNeighbours( living_cells[i] ) );
		}

		for(int i = 0; i < birthed_cells.Count; i++){
			if( !living_cells.Contains( birthed_cells[i] ) ){
				living_cells.Add( birthed_cells[i] );
			}
		}

		UpdateWorld();
		gen += 1;
		gen_amount.Text = Godot.GD.Str(gen);
		if(!running){
			this.SetPhysicsProcess(false);
		}
	}

	public void UpdateWorld(){
		//Updating Changed Cells on Tilemap
		for(int i = 0; i < killed_cells.Count; i ++){
			
			wrld.SetCellv( killed_cells[i], -1 );
		   
			if( living_cells.Contains( killed_cells[i] ) ){
				living_cells.Remove(killed_cells[i]);
			}
		}
		for(int i = 0; i < birthed_cells.Count; i ++){
			wrld.SetCellv( birthed_cells[i], 0 );
		}
	}

	public void BirthCell(Vector2 pos){
		birthed_cells.Add(pos);
	}

	public void AddCell(Vector2 pos){
		//Adds the cell directly and doesn't need to wait for next gen
		gen = 1;
		gen_amount.Text = Godot.GD.Str(gen);
		if( !living_cells.Contains(pos) ){
			 living_cells.Add(pos);
		}
		wrld.SetCellv(pos,0);
	}

	public void DeleteCell(Vector2 pos){
		//Deletes the living cell without waiting for the next generation
		gen = 1;
		gen_amount.Text = Godot.GD.Str(gen);
		wrld.SetCellv(pos,-1);
		living_cells.Remove(pos);
	}

	public void KillCell(Vector2 pos){
		killed_cells.Add(pos);
	}

	public void ApplyLivingRules(Vector2 living_cell, int neighbours){
		//Applies rules that only affect living cells
		if(neighbours < 2 || neighbours > 3){
			KillCell(living_cell);
		}
	}

	public void ApplyDeadRule(Vector2 living_cell, int neighbours){
		//Applies rules that only affect dead cells
		if(neighbours == 3){
			BirthCell(living_cell);
		}
	}

	public void GetAffectedCells(){
		Godot.Vector2 temp;
		cells_to_check.Resize(0);
		for(int i = 0; i < living_cells.Count; i++){
			//Retrieving all cells that need to be checked for general rule
			for(short x = -1; x < 2; x++){
				for(short y = -1; y < 2; y++){
					if(x == 0 && y == 0){
						continue;
					}
					temp = new Vector2( living_cells[i].x + x, living_cells[i].y + y );
					if( !cells_to_check.Contains(temp) && !living_cells.Contains(temp) ){
						cells_to_check.Add(temp);
					}
				}
			}
		}
	}

	public int GetNeighbours(Vector2 pos){
		Vector2 temp;
		int neighbours = 0;
		for(short x = -1; x < 2; x++){
			for(short y = -1; y < 2; y++){
				
				if(x == 0 && y == 0){
					continue;
				}

				temp = new Vector2((int)(pos.x) + x, (int)(pos.y) + y);
				
				if( wrld.GetCellv( temp ) == 0 ){
					neighbours++;
				}
			}
		}
		return neighbours;
	}

	public void ClearGrid(){
		birthed_cells.Resize(0);
		killed_cells.Resize(0);
		living_cells.Resize(0);
		wrld.Clear();
	}

	public void OnStartPressed(){
		running = true;
		this.SetPhysicsProcess(true);
	}

	public void OnStopPressed(){
		running = false;
		this.SetPhysicsProcess(false);
	}

	public void OnPlayPressed(){
		gen = 1;
		running = !running;
		this.SetPhysicsProcess(running);
		switch(running){
			case true:
				play.TextureNormal = (Texture)stop_texture;
			break;
			case false:
				play.TextureNormal = (Texture)play_texture;
			break;
		}
	}

	public void OnNextGenPressed(){
		this.SetPhysicsProcess(true);
	}

	public void OnSettingsPressed(){
		//Stopping Simulation
		running = true;
		OnPlayPressed();
		cam.SetProcess(false);
		cam.SetProcessInput(false);

		//Loading Menu
		Godot.Control Menu = (Control)((PackedScene)ResourceLoader.Load("res://src/scenes/Menu.tscn")).Instance();
		Godot.Error _err = Menu.Connect("tree_exited",cam,"set_process", new Godot.Collections.Array{true});
		_err = Menu.Connect("tree_exited",cam,"set_process_input", new Godot.Collections.Array{true} );
		top_ui.AddChild(Menu);
	}

}
