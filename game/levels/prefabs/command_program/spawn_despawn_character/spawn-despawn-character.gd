"""
Spawns a character that exists in the level at a specified location. The 
location is established by adding a Position2D node as a child of this command
program node.

If a character is despawned, the character will be placed at the origin of the 
level (0, 0).
"""
extends Node

var _manager = null
export (NodePath) var _character_scene_path
var _character = null
export (String, 'in', 'out') var _spawn_type = 'in'
export (String, 'instant', 'slow') var _fade_mode = 'instant'
export (float) var _fade_speed = 0.5

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_character.disconnect("alpha_modulate_completed", self, \
		"_on_Character_alpha_modulate_completed")
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func spawn_despawn_character():
	if _spawn_type == 'in':
		_character.position = get_child(0).position
	
	match _fade_mode:
		'instant':
			_character.modulate_alpha_channel(_spawn_type, _fade_mode)
		'slow':
			_character.modulate_alpha_channel(_spawn_type, _fade_mode, \
				_fade_speed)

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_character = get_node(_character_scene_path)
	_character.connect("alpha_modulate_completed", self, \
		"_on_Character_alpha_modulate_completed")
		
	spawn_despawn_character()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Character_alpha_modulate_completed():
	if _spawn_type == 'out':
		_character.position = Vector2()
	
	end()
