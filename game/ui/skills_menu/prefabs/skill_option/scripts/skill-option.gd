extends HBoxContainer

# Signals
signal skill_focus_entered(skill_option)
signal skill_selected(skill)

# Child nodes
onready var _skill_button = $SkillButton
onready var _skill_cost = $SkillCost

# Skill info
var _assigned_skill = null

################################################################################
# PRIVATE METHODS
################################################################################

func provide_skill_button():
	return _skill_button

#-------------------------------------------------------------------------------

func provide_skill_reference():
	return _assigned_skill.reference

#-------------------------------------------------------------------------------

func update_skill_info(skill):
	_assigned_skill = skill
	var stats = skill.provide_skill_stats()
	_skill_button.text = '%s' % SkillsDatabase.lookup_name(skill.reference)
	if stats.cost > -1:
		_skill_cost.text = '%s' % stats.cost
	else:
		_skill_cost.text = 'N/A'

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_SkillButton_focus_entered():
	emit_signal('skill_focus_entered', self)

#-------------------------------------------------------------------------------

func _on_SkillButton_pressed():
	emit_signal('skill_selected', _assigned_skill)
