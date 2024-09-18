extends Control

class_name UI

var gameMain: GameMain
func registerGameMain(gm: GameMain):
	gameMain = gm
	
var StateControlMap: Dictionary
func _ready():
	StateControlMap = {
		UIState.SELECT: Select,
		UIState.PLACINGS: Placings,
		UIState.MOVE: Move,
		UIState.TURN: Turn,
	}
	
enum UIState {
	SELECT,
	PLACINGS,
	MOVE,
	TURN
}
@export var Select: Control
@export var Placings: Control
@export var Move: Control
@export var Turn: Control
@export var SelectMoveButton: Button
func toggle_ui_on(state: UIState):
	visible = false
	visible = true
	var stateToToggle: Control = StateControlMap[state]
	stateToToggle.visible = true
	
	if state == UIState.SELECT and gameMain.SelectedPlayer:
		SelectMoveButton.visible = gameMain.SelectedPlayer.CanMove()
		
	
#### toggles UI off at all
func toggle_ui_off():
	visible = true
	visible = false
	
#### update ui: resting moves
@export var SelectRestingMoves: RichTextLabel
@export var TurnRestingMoves: RichTextLabel
@export var MoveRestingMoves: RichTextLabel
func update_resting_moves(RestingMoves: int):
	SelectRestingMoves.text = "Moves you can still do: " + str(RestingMoves)
	TurnRestingMoves.text = SelectRestingMoves.text
	MoveRestingMoves.text = SelectRestingMoves.text

#### update ui: resting placings
@export var RestingPlacings: RichTextLabel
func update_resting_placings(PlayersToBePlaced: int):
	RestingPlacings.text = "Players that can still be placed: " + str(PlayersToBePlaced)

@export var SelectPlayerMoves: RichTextLabel
@export var MovePlayerMoves: RichTextLabel
func update_player_moves(moves: int):
	SelectPlayerMoves.text = "Moves this player can do: " + str(moves)
	MovePlayerMoves.text = SelectPlayerMoves.text

#### runs with toggle UI on and off to turn all
#### elements off
func _on_visibility_changed() -> void:
	for child in get_children():
		child.visible = false
	
#### runs when in select mode and player presses quit
func _on_select_quit_button_pressed() -> void:
	gameMain.UndoSelectPlayer()

#### runs when in select mode and player presses move
func _on_select_move_button_pressed() -> void:
	if !gameMain.SelectedPlayer.CanMove(): return
	gameMain.SelectMovePlayer()

#### runs when in move mode and player presses quit
func _on_move_quit_button_pressed() -> void:
	gameMain.MoveQuitPlayer()
