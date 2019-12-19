extends HBoxContainer

# Signals
signal skill_focus_entered(skill_option)

# Child nodes
onready var _skill_button = $SkillButton

################################################################################
# PRIVATE METHODS
################################################################################

func provide_skill_button():
	return _skill_button

#-------------------------------------------------------------------------------

func update_skill_info(skill):
	pass

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_SkillButton_focus_entered():
	emit_signal('skill_focus_entered', self)
