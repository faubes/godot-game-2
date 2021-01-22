extends KinematicBody

# load prefabs
var laser = preload("res://Prefab/Weapon/Laser.tscn")
var gun = preload("res://Prefab/Weapon/Gun.tscn")
var waypoint = preload("res://Prefab/Waypoint.tscn")
var pointer = preload("res://Prefab/Cursor/Pointer.tscn")

export(int) var MAX_SPEED = 2

#Sonready var box = $CSGBox
onready var collisionShape = $CollisionShape
onready var camera = $Camera

onready var nav = get_parent() # player must be child of navigation

var target # object detected by raycast
var cursor_object
var cursor = []

var path = []
var path_node = 0

var weapon
var weapon_object # for storing the instance, not the preloaded scene
var weapons = []

var last_event_position : Vector2

#var direction : Vector3 = Vector3.ZERO
var velocity : Vector3 = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	weapons = [laser, gun]
	cursor = [pointer]

func get_ui_input() -> Vector2:
	return Vector2(Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right"),
		Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down"))

# don't need delta for move_and_slide
func _physics_process(delta):
#	if (transform.origin.y < 0):
#		transform.origin = Vector3.ZERO + 5*Vector3.UP
#		print("Teleport to start")
#		return
	var ui_input = get_ui_input()
	#if (ui_input == Vector2.ZERO):
	if (ui_input.length() < 0.1):
		velocity = pathfinderAppliedForce(velocity)
	else:
		velocity = controllerAppliedForce(ui_input)
	velocity += 0.98*Vector3.DOWN*delta
	velocity = move_and_slide(velocity*MAX_SPEED, Vector3.UP)
	if target:
		if (translation.distance_to(target.position) > 1):
			var target_on_plane = target.position.project(Vector3.LEFT) + target.position.project(Vector3.RIGHT)
			look_at(target_on_plane, Vector3.UP)#	if (is_on_floor()):
#		print("On floor")
#	if (is_on_wall()):
#		print("on wall")
#	if (!is_on_floor()):
#		velocity += 0.98*Vector3.DOWN
#		print("Not on floor?")
		#velocity += Vector3.DOWN*0.98*delta # Fall faster
		#velocity = move_and_slide(Vector3.DOWN, Vector3.UP)

func pathfinderAppliedForce(v):
	if path.size() >= 0 and path_node < path.size():
#		print("use path ", path)
		#velocity = velocity.move_toward(move_along_path(), MAX_SPEED*delta)
		v = move_toward_next_path_node()
	else:
		v = v.move_toward(Vector3.ZERO, MAX_SPEED)
	return v

func move_toward_next_path_node():
	if path.empty():
		return Vector3.ZERO
	var v : Vector3
	for n in path:
		v = n - transform.origin
		if v.length() > 0.1:
			continue
	return v
		
func controllerAppliedForce(ui_input):
		path = []
		path_node = 0
		return velocity.move_toward(Vector3(ui_input.x, 0, ui_input.y), 1.0)
	

func _input(event):
	if (event.is_action_pressed("ui_focus_next")): #tab
		if weapon_object:
			weapons.append(weapon)
			self.remove_child(weapon_object)
		weapon = weapons.pop_front()
		weapon_object = weapon.instance()
		self.add_child(weapon_object)
		
	if (event.is_action_pressed("mouse_wheel_up")):
		camera.move_forward(1)
	if (event.is_action_pressed("mouse_wheel_down")):
		camera.move_forward(-1)
	if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)
		if event.is_action_pressed("mouse_left_click"):
			click(event)
	elif event is InputEventMouseMotion:
		if (last_event_position.distance_to(event.position) > 0.1):
			if !cursor_object:
				cursor_object = cursor.back().instance()
				add_child(cursor_object)
			var hit = cameraCast(event)
			if hit:
				cursor_object.visible = true
				cursor_object.transform.origin = hit.position
	#		else:
	#			cursor_object.visible = false


func cameraCast(event):
	var from = camera.project_ray_origin(event.position)
	var to = from + camera.project_ray_normal(event.position) * 1000
	var space_state = get_world().get_direct_space_state()
	var hit = space_state.intersect_ray(from, to)
	return hit


func click(event):
#	if hit is KinematicCollision:
#		print("hit kinematicCollision")
	var hit = cameraCast(event)
	if hit is StaticBody:
		print("hit staticbody")
	if hit:
		target = hit
		var waypoint_obj = waypoint.instance()
		waypoint_obj.transform.origin = hit.position
		get_parent().add_child(waypoint_obj)
	if hit and hit.collider is Node:
		if (hit.collider.get_groups().has("object")):
			use_object(hit)
		if (hit.collider.get_groups().has("enemy")):
			attack(hit)
	

func use_object(hit):
	if (hit.collider.get_groups().has("chest")):
		print("chest")
	elif (hit.collider.get_groups().has("floor")):
#		print("floor")
		nav_to(hit)

func nav_to(hit):
	path = nav.get_simple_path(transform.origin, hit.position)
	path_node = 0
	var i = 0
	for n in path:
		i += 1
		if fmod(i, 5) == 0:
			var waypoint_obj = waypoint.instance()
			waypoint_obj.transform.origin = n + Vector3.UP*0.5
			get_parent().add_child(waypoint_obj)


func attack(hit):
	if weapon.has_method("shoot"):
		weapon.shoot(hit)
	print("Hai-ya!")
