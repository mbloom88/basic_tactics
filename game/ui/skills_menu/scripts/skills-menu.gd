extends NinePatchRect

# Signals 
signal state_changed(menu, state)

# Child nodes
onready var _scroll = $VBoxContainer/ScrollContainer
onready var _skill_list = $VBoxContainer/ScrollContainer/SkillList
onready var _description = $VBoxContainer/SkillDescriptionPanel/Desription

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'idle': $State/Idle,
	'interact': $State/Interact,
	'exit': $State/Exit,
}

# Skills
export (PackedScene) var skill_option_scene

# Button handling
var _current_focus = null

# Scrolling
export (int) var _button_spacing = 10 # Based on SkillList vbox separation

# Actor info
var _actor_in_menu = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('interact')

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name):
	if state_name != 'previous':
		if _state_map[state_name] != _current_state:
			_current_state._exit(self)

	if state_name == 'previous':
		_state_stack.pop_front()
	else:
		var new_state = _state_map[state_name]
		_state_stack[0] = new_state

	_current_state = _state_stack[0]
	
	if state_name != 'previous':
		_current_state._enter(self)
	
	emit_signal('state_changed', self, state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func add_skills_to_list(actor):
	_actor_in_menu = actor
	var skills = _actor_in_menu.provide_skills()
	if _current_state == _state_map['interact']:
		_current_state.add_skills_to_list(self, skills)

#-------------------------------------------------------------------------------

func exit():
	_change_state('exit')

#-------------------------------------------------------------------------------

func interact():
	_change_state('interact')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_SkillOption_skill_focus_entered(skill_option):
	var index = skill_option.get_position_in_parent()
	var skill_ref = skill_option.provide_skill_reference()
	_scroll.scroll_vertical = \
		index * (skill_option.rect_size.y + _button_spacing)
	_description.bbcode_text = \
		'%s' % SkillsDatabase.lookup_description(skill_ref)

#-------------------------------------------------------------------------------

func _on_SkillOption_skill_selected(skill):
	if skill.reference == 'reload_weapon':
		_actor_in_menu.reload_current_weapon()
