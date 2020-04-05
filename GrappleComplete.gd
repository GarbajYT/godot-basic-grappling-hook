extends KinematicBody

var speed = 7
var acceleration = 50
var gravity = 20
var jump = 10

var grappling = false
var hookpoint = Vector3()
var hookpoint_get = false

var mouse_sensitivity = 0.03

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3() 

onready var head = $Head
onready var grapplecast = $Head/Camera/GrappleCast
onready var bonker = $HeadBonker

func _ready():
	pass
	
func _input(event):
	
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity)) 
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity)) 
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func grapple():
	if Input.is_action_just_pressed("ability"):
		if grapplecast.is_colliding():
			if not grappling:
				grappling = true
				
	if grappling:
		fall.y = 0
		if not hookpoint_get:
			hookpoint = grapplecast.get_collision_point() + Vector3(0, 2.25, 0)
			hookpoint_get = true
		if hookpoint.distance_to(transform.origin) > 1:
			if hookpoint_get:
				transform.origin = lerp(transform.origin, hookpoint, 0.05)
		else:
			grappling = false
			hookpoint_get = false
	if bonker.is_colliding():
		grappling = false
		hookpoint = null
		hookpoint_get = false
		global_translate(Vector3(0, -1, 0))

func _physics_process(delta):
	
	direction = Vector3()
	
	move_and_slide(fall, Vector3.UP)
	
	if not is_on_floor():
		fall.y -= gravity * delta
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		fall.y = jump
	
	grapple()	
		
	if Input.is_action_pressed("move_forward"):
	
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		
		direction += transform.basis.z
		
	if Input.is_action_pressed("move_left"):
		
		direction -= transform.basis.x			
		
	elif Input.is_action_pressed("move_right"):
		
		direction += transform.basis.x
			
		
	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta) 
	velocity = move_and_slide(velocity, Vector3.UP) 
	
