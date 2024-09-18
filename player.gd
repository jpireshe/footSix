extends CharacterBody3D
class_name Player

@export var PlayerCamera: Camera3D
var MoveCircle: MoveArea

var OriginalCamera: Camera3D
var OriginalMoveRange: float = 4.0
var MoveRange: float = OriginalMoveRange
var MoveDecay: float = 0.8
var MoveTarget: Vector3
var OriginalMoveCount: int = 3
var MoveCount: int = OriginalMoveCount
var DesiredPosition: Vector3 = Vector3(0, 0, 0)

var Speed: float = 5.0

func _ready() -> void:
	MoveCircle = $MoveArea
	MoveCircle.define_radius(MoveRange)
	
func _physics_process(delta: float) -> void:
	if(DesiredPosition.length() == 0 or position == DesiredPosition): return
	
	var toWalk: Vector3 = (DesiredPosition - position).normalized()
	velocity.x = toWalk.x * Speed
	velocity.z = toWalk.z * Speed
		
	move_and_slide()
		
func Select():
	MoveCircle.on()
	
func UndoSelect():
	MoveCircle.off()
	
func Move(to: Vector3) -> bool:
	if !CanMove(): return false
	
	var dist: float = (position - to).length()
	if dist > MoveRange: return false
	
	DesiredPosition = to
	
	MoveCount -= 1
	UpdateMoveRange()
	return true
	
func UpdateMoveRange():
	MoveRange *= MoveDecay
	MoveCircle.define_radius(MoveRange)
	
func ResetMoveRange():
	MoveRange = OriginalMoveRange
	MoveCircle.define_radius(MoveRange)
	
func ResetMoveCount():
	MoveCount = OriginalMoveCount
	
func Restart():
	ResetMoveCount()
	ResetMoveRange()
	
func GetMoveCount() -> int:
	return MoveCount
	
func CanMove() -> bool:
	return MoveCount > 0
