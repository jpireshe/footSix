extends Area3D

class_name MoveArea

var Collider: CylinderShape3D
var Circle: CSGCylinder3D

func _ready():
	Collider = $Collision.shape
	Circle = $Circle
	
func define_radius(radius: float):
	Collider.radius = radius
	Circle.radius = radius
	
func on():
	self.visible = true

func off():
	self.visible = false
	
	
