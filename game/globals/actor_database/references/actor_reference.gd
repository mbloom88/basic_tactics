extends Resource

class_name ActorReference

export (PackedScene) var actor_scene
export (String) var first_name = ""
export (String) var nick_name = ""
export (String) var last_name = ""
export (String, 'ally', 'enemy', 'npc') var type = 'ally'
export (bool) var unlocked = false
export (Dictionary) var expressions = {}
