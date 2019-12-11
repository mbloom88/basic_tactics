extends Node2D

var _actor = null

func _ready():
	_actor = ActorDatabase.provide_actor_object('test_ally_001')
	add_child(_actor)
