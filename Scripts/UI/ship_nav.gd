extends Control

"""
The ship navigation system needs to know what level upgrades the player has to
allow for the unlocking of certain asteroids.

Also want there to be random events (comets) that can be ventured, depending on
the player level
"""

@onready var player = %Player
# Upgrade level variable
var upgrade_level

func open():
	show()
	upgrade_level = player.upgrade_level
	display_poi(upgrade_level)
	
func display_poi(upgrade_level : int):
	pass
