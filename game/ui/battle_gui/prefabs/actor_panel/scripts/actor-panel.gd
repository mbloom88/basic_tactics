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
onready var _armor = \
	$HBoxContainer/VBoxContainer/StatPanel/VBoxContainer/ArmorContainer
onready var _shields = \
	$HBoxContainer/VBoxContainer/StatPanel/VBoxContainer/ShieldContainer

# Box alignments
export (String, 'left', 'right') var box_alignment = 'left' \
	setget set_box_alignment

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	if not Engine.is_editor_hint():
		hide_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func hide_gui():
	visible = false

#-------------------------------------------------------------------------------

func load_actor_info(actor):
	"""
	Args:
		- actor (Object)
	"""
	var actor_name  = ActorDatabase.lookup_name(actor.reference)
	var info = actor.provide_job_info()
	
	# Set name, level, job
	if actor_name['nick']:
		_actor_name.text = '%s "%s" %s' % [actor_name['first'], 
			actor_name['nick'], actor_name['last']]
	else:
		_actor_name.text = '%s %s' % [actor_name['first'], actor_name['last']]
	
	_actor_level_job.text = 'Level %s - %s' % [info['level'], info['job_name']]
	_hp.update_info(info)
	_armor.update_info(info)
	_shields.update_info(info)
	
	# Set portrait
	_portrait.texture = ActorDatabase.lookup_portrait(actor.reference)

#-------------------------------------------------------------------------------

func show_gui():
	visible = true

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
