tool
extends HBoxContainer

# Signals
signal response_selected(option, text)

# Child nodes
onready var _portrait = $CharacterPortrait
onready var _anim = $AnimationPlayer
onready var _name = $VBoxContainer/CharacterName
onready var _vbox = $VBoxContainer
onready var _scroll = $VBoxContainer/DialoguePanel/ScrollContainer
onready var _responses = $VBoxContainer/DialoguePanel/ScrollContainer/Responses

# Dialogue box alignments
export (String, 'top', 'bottom') var box_alignment = 'top' \
	setget set_box_alignment
export (String, 'left', 'right') var portrait_alignment = 'left' \
	setget set_portrait_alignment

# Option buttons info
export (int) var _button_spacing = 4 # Based on theme's vbox separation
var _response_dictionary = {}
var _total_responses = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	set_process_input(false)
	
	if not Engine.is_editor_hint():
		deactivate('instant_out')

################################################################################
# PRIVATE METHODS
################################################################################

func _disable_response_buttons():
	for response in _responses.get_children():
		response.focus_mode = Control.FOCUS_NONE
		response.disabled = true

#-------------------------------------------------------------------------------

func _enable_response_buttons():
	for response in _responses.get_children():
		response.focus_mode = Control.FOCUS_ALL
		response.disabled = false

################################################################################
# PUBLIC METHODS
################################################################################

func activate(type):
	match type:
		'fade_in':
			_anim.play("fade-in")
		'instant_in':
			_anim.play("instant-in")

#-------------------------------------------------------------------------------

func clear_responses():
	for response in _responses.get_children():
		response.queue_free()
	
	_total_responses = 0
	_scroll.scroll_vertical = 0

#-------------------------------------------------------------------------------

func deactivate(type):
	match type:
		'fade_out':
			_anim.play("fade-out")
		'instant_out':
			_anim.play("instant-out")

#-------------------------------------------------------------------------------

func update_name_plate(actor_name):
	if actor_name['nick']:
		_name.text = '%s "%s" %s' % [actor_name['first'], 
			actor_name['nick'], actor_name['last']]
	else:
		_name.text = '%s %s' % [actor_name['first'], actor_name['last']]

#-------------------------------------------------------------------------------

func update_responses(responses):
	_response_dictionary = responses
	
	for response in responses.keys():
		var button = Button.new()
		button.align = Button.ALIGN_LEFT
		button.text = responses[response]
		button.name = response
		button.connect("focus_entered", self, "_on_Response_focus_entered")
		button.connect("pressed", self, "_on_Response_pressed")
		_responses.add_child(button)
		
		_total_responses += 1

#-------------------------------------------------------------------------------

func update_portrait(portrait):
	_portrait.texture = portrait

################################################################################
# SETTERS
################################################################################

func set_box_alignment(value):
	if is_inside_tree():
		box_alignment = value
		
		match value:
			'top':
				_vbox.move_child(_name, 0)
				_vbox.alignment = VBoxContainer.ALIGN_BEGIN
			'bottom':
				var last_index = _vbox.get_child_count() - 1
				_vbox.move_child(_name, last_index)
				_vbox.alignment = VBoxContainer.ALIGN_END

#-------------------------------------------------------------------------------

func set_portrait_alignment(value):
	if is_inside_tree():
		portrait_alignment = value
	
		match value:
			'left':
				move_child(_portrait, 0)
				_name.align = Label.ALIGN_LEFT
			'right':
				var last_index = get_child_count() - 1
				move_child(_portrait, last_index)
				_name.align = Label.ALIGN_RIGHT 

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name in ['fade-in', 'instant-in']:
		_enable_response_buttons()
		_responses.get_child(0).grab_focus()
	elif anim_name in ['fade-out', 'instant-out']:
		clear_responses()

#-------------------------------------------------------------------------------

func _on_Response_focus_entered():
	var focused_button = get_focus_owner()
	var index = focused_button.get_position_in_parent()
	_scroll.scroll_vertical = \
		index * (focused_button.rect_size.y + _button_spacing)

#-------------------------------------------------------------------------------

func _on_Response_pressed():
	var focused_button = get_focus_owner()
	var index = focused_button.get_position_in_parent()

	for response in _response_dictionary.keys():
		if focused_button.name == response:
			emit_signal("response_selected", response, \
				_response_dictionary[response])
			_disable_response_buttons()
