extends Node3D
class_name GameMain

@export var MainCamera: Camera3D
var Ui: UI = null

## manipulate player
### select
var SelectedPlayer: Player = null
func SelectPlayer(player: Player):
	if !player: 
		print("Select Player with null call")
		return
		
	player.Select()
	SelectedPlayer = player
	
	ChangeStateTo(States.SELECTED, [player])

func UndoSelectPlayer():
	if !SelectedPlayer: 
		print("Undo Select Player with null call")
		return
	
	SelectedPlayer.UndoSelect()
	SelectedPlayer = null
	
	ChangeStateTo(States.TURN)

func SelectMovePlayer():
	ChangeStateTo(States.MOVE)

### move
func MovePlayer(to: Vector3):
	if SelectedPlayer.Move(to):
		decrease_resting_moves()
		
	MoveQuitPlayer()
	
func MoveQuitPlayer():
	if State == States.MOVE:
		SelectPlayer(SelectedPlayer)
	
### instantiate players
var OriginalPlayersToBePlaced: int = 10
var PlayersToBePlaced: int = OriginalPlayersToBePlaced
func place_player(position: Vector3, type: PlayerTypes):
	_instantiate_player(position, type)
	PlayersToBePlaced -= 1
	if PlayersToBePlaced == 0:
		ChangeStateTo(States.TURN)
		
	Ui.update_resting_placings(PlayersToBePlaced)
		
#### to know what kind of player to instantiate
enum PlayerTypes {
	PLAYER,
	DEFENDER
}
var PlayerScene = load("res://player.tscn")
var DefenderScene = load("res://defender.tscn")
var PlayerTypeMap: Dictionary = {
	PlayerTypes.PLAYER: PlayerScene,
	PlayerTypes.DEFENDER: DefenderScene,
}
		
var PlayersInGame: Array[Player] = []
func _instantiate_player(instantiate_position: Vector3, type: PlayerTypes):
	var player = PlayerTypeMap[type].instantiate()
	add_child(player)
	PlayersInGame.append(player)
	player.position = Vector3(instantiate_position.x, position.y, instantiate_position.z)

## game
### states
enum States {
	BASE,
	AWAIT_TURN,
	PLACE,
	TURN,
	SELECTED,
	MOVE,
}
var State: States = States.PLACE

func ChangeStateTo(state: States, opt=[]):
	State = state
	
	if State == States.PLACE:
		MainCamera.make_current()
		
		Ui.update_resting_placings(PlayersToBePlaced)
		Ui.toggle_ui_on(Ui.UIState.PLACINGS)
		
	elif State == States.TURN:
		MainCamera.make_current()
		
		Ui.update_resting_moves(RestingMoves)
		Ui.toggle_ui_on(Ui.UIState.TURN)
		
	elif State == States.SELECTED:
		var player = opt[0]
		
		player.PlayerCamera.make_current()
		
		Ui.update_player_moves(player.GetMoveCount())
		Ui.toggle_ui_on(Ui.UIState.SELECT)
		
	elif State == States.MOVE:
		Ui.toggle_ui_on(Ui.UIState.MOVE)
	
	if State == States.AWAIT_TURN:
		Ui.toggle_ui_off()
 
### start
func _ready() -> void:
	var UIScene = load("res://ui.tscn")
	Ui = UIScene.instantiate()
	Ui.registerGameMain(self)
	add_child(Ui)
	
	ChangeStateTo(States.PLACE)

## get input
func _input(event):
	if event.is_action_pressed("click"):
		var result: Dictionary = get_clicked_object()
		if result.is_empty(): return
		var obj = result.get("collider", null)
		
		if State == States.PLACE:
			if not obj is StaticBody3D: return
			place_player(result.get("position", Vector3(0,0,0)), PlayerTypes.DEFENDER)
			
		if State == States.TURN:
			if not obj is Player: return
			SelectPlayer(obj)
			
		elif State == States.SELECTED:
			if not obj is Player: return
			UndoSelectPlayer()
			SelectPlayer(obj)
				
		elif State == States.MOVE:
			if not obj is StaticBody3D: return
			MovePlayer(result.get("position", Vector3(0,0,0)))
			
## global func to get what was clicked
func get_clicked_object() -> Dictionary:	
	if has_clicked_ui_element(): return {}
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var ray_length = 1000
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var space = get_world_3d().direct_space_state
	var ray_query = PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	var raycast_result = space.intersect_ray(ray_query)

	return raycast_result
	
func has_clicked_ui_element():
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	var clicked_ui_element = viewport.gui_get_hovered_control()

	return clicked_ui_element != Ui

### turn regulation
func _end_turn():
	ChangeStateTo(States.AWAIT_TURN)
	
	## DEBUG ##
	_reset_turn()

func _reset_turn():
	reset_resting_Moves()
	for player in PlayersInGame: player.Restart()
	ChangeStateTo(States.TURN)
	
### resting moves
var OriginalRestingMoves: int = 8
var RestingMoves: int = OriginalRestingMoves

#### check if player can still make moves
func can_still_make_moves() -> bool:
	return RestingMoves > 0

func decrease_resting_moves():
	RestingMoves -= 1
	Ui.update_resting_moves(RestingMoves)
	
	if RestingMoves == 0:
		UndoSelectPlayer()
		_end_turn()
	
func reset_resting_Moves():
	RestingMoves = OriginalRestingMoves
	Ui.update_resting_moves(RestingMoves)
