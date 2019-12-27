tool
extends NinePatchRect

# Child nodes
onready var _hbox = $HBoxContainer
onready var _portrait = $HBoxContainer/NeutralPortait
onready var _actor_name = \
	$HBoxContainer/VBoxContainer/StatPanel/VBoxContainer/ActorName
onready var _actor_level_job = \
	$HBoxContainer/VBoxContainer/StatPanel/VBoxContainer/ActorLevelJob
onready var _hp = \
	$HBoxContainer/VBoxContainer/StatPanel/VBoxContainer/HPContainer

# Box alignments
export (String, 'left', 'right') var box_alignment = 'left' \
	setget set_box_alignment

# Actor info
var current_actor = null setget set_current_actor, get_current_actor

################################################################################
# PRIVATE METHODS
################################################################################

func _refresh_actor_stats(info):
	_hp.update_info(info)

#-------------------------------------------------------------------------------

func _setup_character():
	var actor_name = ActorDatabase.lookup_name(current_actor.reference)
	var info = current_actor.provide_job_info()
		
	# Set name, level, job
	if actor_name['nick']:
		_actor_name.text = '%s "%s" %s' % [actor_name['first'], 
			actor_name['nick'], actor_name['last']]
	else:
		_actor_name.text = '%s %s' % [actor_name['first'], actor_name['last']]
	
	_actor_level_job.text = 'Level %s - %s' % [info['level'], info['job_name']]
	_refresh_actor_stats(info)
	
	# Set portrait
	_portrait.texture = ActorDatabase.lookup_portrait(current_actor.reference)

#-------------------------------------------------------------------------------

func _setup_object():
	var actor_name = ActorDatabase.lookup_name(current_actor.reference)
	var info = current_actor.provide_job_info()
	
	# Set name, level, job
	_actor_name.text = '%s' % actor_name['first']
	_actor_level_job.text = ""
	_refresh_actor_stats(info)
	
	# Set portrait
	_portrait.texture = null

################################################################################
# PUBLIC METHODS
################################################################################

func clear_actor():
		current_actor.disconnect('stats_modified', self, 
			'_on_Actor_stats_modified')
		current_actor = null

#-------------------------------------------------------------------------------

func load_actor(actor):
	"""
	Args:
		- actor (Object)
	"""
	# Check if cyling back to previous actor
	if current_actor == actor:
		return
	
	# If moving from previous actor, disconnect previous actor
	if is_instance_valid(current_actor):
		current_actor.disconnect('stats_modified', self, 
			'_on_Actor_stats_modified')
	
	current_actor = actor
	current_actor.connect('stats_modified', self, '_on_Actor_stats_modified')
	var actor_type = ActorDatabase.lookup_type(current_actor.reference)
	
	if actor_type in ['ally', 'enemy', 'npc']:
		_setup_character()
	elif actor_type == 'object':
		_setup_object()

################################################################################
# SETTERS
################################################################################

func set_box_alignment(value):
	if is_inside_tree():
		box_alignment = value
	
		match value:
			'left':
				_hbox.alignment = BoxContainer.ALIGN_BEGIN
				_hbox.move_child(_portrait, 0)
				_actor_name.align = Label.ALIGN_LEFT
				_actor_level_job.align = Label.ALIGN_LEFT
			'right':
				var last_index = _hbox.get_child_count() - 1
				_hbox.alignment = BoxContainer.ALIGN_END
				_hbox.move_child(_portrait, last_index)
				_actor_name.align = Label.ALIGN_RIGHT
				_actor_level_job.align = Label.ALIGN_RIGHT

################################################################################
# SETTERS
################################################################################

func  set_current_actor(value):
	current_actor = value # Object actor

################################################################################
# GETTERS
################################################################################

func get_current_actor():
	return current_actor

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_stats_modified():
	var info = current_actor.provide_job_info()
	_refresh_actor_stats(info)
