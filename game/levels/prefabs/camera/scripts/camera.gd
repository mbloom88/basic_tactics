extends Camera2D

# Signals
signal moved_to_location
signal tracking_added(actor)
signal tracking_removed(actor)

# Child nodes
onready var _tween_move = $TweenMove

# Target info
var _current_actor = null

# Action info
export (float) var _camera_pan_speed = 0.25
var _target_location = Vector2()
var _current_action = ""

################################################################################
# PUBLIC METHODS
################################################################################

func move_to_location(location, move_speed):
	if not _current_action:
		_current_action = 'move'
		
	_tween_move.interpolate_property(
		self,
		'position',
		position,
		location,
		move_speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	
	_tween_move.start()

#-------------------------------------------------------------------------------

func track_actor(actor):
	if _current_actor:
		untrack_actor()
	
	_current_actor = actor
	
	_current_actor.connect(
		'camera_move_requested',
		self,
		'_on_Actor_camera_move_requested')
		
	var location = _current_actor.position
	_current_action = 'track'
	move_to_location(location, _camera_pan_speed)

#-------------------------------------------------------------------------------

func untrack_actor():
	_current_actor.disconnect(
		'camera_move_requested',
		self,
		'_on_Actor_camera_move_requested')
	
	emit_signal('tracking_removed', _current_actor)
	_current_actor = null

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_camera_move_requested(location, move_speed):
	move_to_location(location, move_speed)

#-------------------------------------------------------------------------------

func _on_TweenMove_tween_completed(object, key):
	match _current_action:
		'move':
			emit_signal('moved_to_location')
		'track':
			emit_signal('tracking_added', _current_actor)
	
	_current_action = ""
