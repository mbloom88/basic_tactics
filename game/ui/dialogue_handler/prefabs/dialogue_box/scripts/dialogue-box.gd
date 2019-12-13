tool
extends HBoxContainer

# Signals
signal dialogue_finished

# Child nodes
onready var _portrait = $CharacterPortrait
onready var _anim = $AnimationPlayer
onready var _typer = $CharacterTyper
onready var _name = $VBoxContainer/CharacterName
onready var _prompt = $VBoxContainer/DialoguePanel/VBoxContainer/Prompt
onready var _vbox = $VBoxContainer
onready var _continue = $VBoxContainer/DialoguePanel/ContinueIndicator

# Dialogue box alignments
export (String, 'top', 'bottom') var box_alignment = 'top' \
	setget set_box_alignment
export (String, 'left', 'right') var portrait_alignment = 'left' \
	setget set_portrait_alignment

# Prompt info
export (float) var _character_display_speed = 0.025
var _can_speed_up = false
var _can_continue = false

################################################################################
# VIRTUAL METHODS
################################################################################

func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		_update_dialogue_box()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			_update_dialogue_box()

#-------------------------------------------------------------------------------

func _ready():
	set_process_input(false)
	
	if not Engine.is_editor_hint():
		deactivate('instant_out')
		_typer.wait_time = _character_display_speed

#-------------------------------------------------------------------------------

func _update_dialogue_box():
	if _can_speed_up:
		_show_all_prompt_characters()
	elif _can_continue:
		set_process_input(false)
		_can_continue = false
		hide_continue_indicator()
		emit_signal("dialogue_finished")

################################################################################
# PRIVATE METHODS
################################################################################

func _show_all_prompt_characters():
	_typer.stop()
	_can_speed_up = false
	_prompt.visible_characters = _prompt.bbcode_text.length()
	blink_continue_indicator()
	_can_continue = true

################################################################################
# PUBLIC METHODS
################################################################################

func activate(type):
	match type:
		'fade_in':
			_anim.play("fade-in")
		'instant_in':
			_anim.play("instant-in")
		'just_play':
			type_out_dialogue()
			_can_speed_up = true
			set_process_input(true)

#-------------------------------------------------------------------------------

func blink_continue_indicator():
	_continue.blink()

#-------------------------------------------------------------------------------

func clear_dialogue():
	_prompt.clear()

#-------------------------------------------------------------------------------

func deactivate(type):
	match type:
		'fade_out':
			_anim.play("fade-out")
		'instant_out':
			_anim.play("instant-out")

#-------------------------------------------------------------------------------

func hide_continue_indicator():
	_continue.invisible()

#-------------------------------------------------------------------------------

func instantly_show_dialogue():
	_prompt.visible_characters = _prompt.bbcode_text.length()

#-------------------------------------------------------------------------------

func type_out_dialogue():
	_typer.start()

#-------------------------------------------------------------------------------

func update_current_dialogue(dialogue):
	_prompt.visible_characters = 0
	_prompt.bbcode_text = dialogue

#-------------------------------------------------------------------------------

func update_name_plate(actor_name):
	if actor_name['nick']:
		_name.text = '%s "%s" %s' % [actor_name['first'], 
			actor_name['nick'], actor_name['last']]
	else:
		_name.text = '%s %s' % [actor_name['first'], actor_name['last']]

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
	if anim_name in ['fade-in', 'instant_in']:
		type_out_dialogue()
		_can_speed_up = true
		set_process_input(true)
	elif anim_name in ['fade-out', 'instant_out']:
		clear_dialogue()

#-------------------------------------------------------------------------------

func _on_CharacterTyper_timeout():
	_prompt.visible_characters += 1
	
	if _prompt.visible_characters == _prompt.bbcode_text.length():
		_show_all_prompt_characters()
