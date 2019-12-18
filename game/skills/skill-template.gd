"""
-1 indicates infinite use.
"""
extends Resource

class_name SkillTemplate

export (String, 'none', 'ammo', 'nano') var resource_type = 'none'
export (int) var resource_per_use
