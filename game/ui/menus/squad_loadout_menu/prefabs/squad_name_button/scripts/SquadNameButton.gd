extends Button

# Signals
signal just_toggled(button, actor_ref)
signal update_portrait(actor_ref)

# Actor info
var actor_ref = ""

################################################################################
# PUBLIC METHODS
################################################################################

func update_actor_ref(ref):
	actor_ref = ref

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_SquadNameButton_focus_entered():
	emit_signal('update_portrait', actor_ref)

#-------------------------------------------------------------------------------

func _on_SquadNameButton_mouse_entered():
	emit_signal('update_portrait', actor_ref)

#-------------------------------------------------------------------------------

func _on_SquadNameButton_pressed():
	emit_signal('just_toggled', self, actor_ref)
