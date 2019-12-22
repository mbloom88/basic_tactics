extends Resource

class_name SkillReference

export (String) var skill_name = ""
export (PackedScene) var skill_scene
export (Texture) var icon
export (String, 'weapon', 'job') var skill_type = 'weapon'
export (String, 'self', 'friend', 'foe') var target = 'self'
export (String, MULTILINE) var description = ""