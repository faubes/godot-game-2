extends Camera

export var min_distance = 0.5
export var max_distance = 3.5
export var angle_v_adjust = 0.0
export var autoturn_ray_aperture = 25
export var autoturn_speed = 50

var collision_exception = []
var max_height = 2.0
var min_height = 0

var look_direction : Vector3

func _ready():
	# Find collision exceptions for ray.
	var node = self
	while node:
		if node is RigidBody:
			collision_exception.append(node.get_rid())
			break
		else:
			node = node.get_parent()
	set_physics_process(true)
	# This detaches the camera transform from the parent spatial node.
	set_as_toplevel(true)
	look_direction = transform.origin - get_parent().get_global_transform().origin

func move_forward(d : float):
	print("camera forward")
	print(transform.origin)
	transform.origin += d*look_direction.normalized()

func move_up(d : float):
	transform.origin += d * look_direction.cross(self.transform.basis[1]).normalized()

func _physics_process(dt):
	var target = get_parent().get_global_transform().origin
	look_direction = look_direction.move_toward(target, dt*autoturn_speed)
	look_at(look_direction, Vector3.UP)
	
# this is an old camera script that came attached. Leaving it for future reference re: basis
# alternative way to do rotations / like quaternions

# 	Regular delta follow.
#	# Check ranges.
#	if delta.length() < min_distance:
#		delta = delta.normalized() * min_distance
#	elif  delta.length() > max_distance:
#		delta = delta.normalized() * max_distance
#
#	# Check upper and lower height.
#	if delta.y > max_height:
#		delta.y = max_height
#	if delta.y < min_height:
#		delta.y = min_height
#	# Check autoturn.
#	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())
#
#	var col_left = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(autoturn_ray_aperture)).xform(delta), collision_exception)
#	var col = ds.intersect_ray(target, target + delta, collision_exception)
#	var col_right = ds.intersect_ray(target, target + Basis(Vector3.UP, deg2rad(-autoturn_ray_aperture)).xform(delta), collision_exception)
#
#	if !col.empty():
#		# If main ray was occluded, get camera closer, this is the worst case scenario.
#		delta = col.position - target
#	elif !col_left.empty() and col_right.empty():
#		# If only left ray is occluded, turn the camera around to the right.
#		delta = Basis(Vector3.UP, deg2rad(-dt * autoturn_speed)).xform(delta)
#	elif col_left.empty() and !col_right.empty():
#		# If only right ray is occluded, turn the camera around to the left.
#		delta = Basis(Vector3.UP, deg2rad(dt  *autoturn_speed)).xform(delta)
#	# Do nothing otherwise, left and right are occluded but center is not, so do not autoturn.
#
#	# Apply lookat.
#	if delta == Vector3():
#		delta = (pos - target).normalized() * 0.0001
#
#	pos = target + delta
#	look_at_from_position(pos, target, Vector3.UP)
#
#	# Turn a little up or down.
#	var t = get_transform()
#	t.basis = Basis(t.basis[0], deg2rad(angle_v_adjust)) * t.basis
#	set_transform(t)
