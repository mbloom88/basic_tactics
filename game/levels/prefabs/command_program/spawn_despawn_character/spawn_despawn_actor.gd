"""
Spawns a character that exists in the level at a specified location. Enable
'Editable Children' in the right-click menu within the scene to be able to move
the child Position2D node to set the target position to spawn the actor in.

If a character is despawned, the character will be placed at the origin of the 
level (0, 0).
"""
extends Node

# Child nodes
onready var _spawn = $SpawnLocation.position

# Scene info
var _manager = null
export (NodePath) var _actor_scene_path
var _actor = null
export (NodePath) var _battleground_scene_path
var _battleground = null
export (String, 'in', 'out') var _spawn_type = 'in'
export (String, 'instant', 'slow') var _fade_mode = 'instant'
export (float) var _fade_speed = 0.5

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_actor.disconnect("alpha_modulate_completed", self, \
		"_on_Actor_alpha_modulate_completed")
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func spawn_despawn_character():
	if _spawn_type == 'in':
		var map_cell = _battleground.world_to_map(_spawn)
		var world_position = _battleground.offset_world_position(map_cell)
		_actor.position = world_position
	
	match _fade_mode:
		'instant':
			_actor.modulate_alpha_channel(_spawn_type, _fade_mode)
		'slow':
			_actor.modulate_alpha_channel(_spawn_type, _fade_mode, \
				_fade_speed)

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_actor = get_node(_actor_scene_path)
	_actor.connect("alpha_modulate_completed", self, \
		"_on_Actor_alpha_modulate_completed")
	_battleground = get_node(_battleground_scene_path)
		
	spawn_despawn_character()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_alpha_modulate_completed():
	if _spawn_type == 'out':
		_actor.position = Vector2()
	
	end()
