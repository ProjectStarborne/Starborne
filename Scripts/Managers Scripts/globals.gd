# Globals.gd (singleton autoload)
extends Node


# Track upgrade purchases globally
var upgrades_purchased = {
	"Warp Engine V.1": true,
	"Fuel Efficiency Module V.1": false,
	"Stellar Cartography Module": false,
	"Reinforced Hull Plating": false,
	"Warp Engine V.2": false,
	"Deep Space Scanners": false,
	"Dark Matter Fuel Cells": false
}

var track_logs: Array[bool] = [0, 0, 0, 0]

var inventory : Inventory = Inventory.new()
var ship_inventory : Inventory = Inventory.new()

var oxygen_leaking = false
var current_health = 100
var current_oxygen = 100
var current_level: int = 1  # default at starting level
# Global variable to hold the next level selected for travel
var next_level
#shaking variable to prevent player from leaving ship while its moving
var is_shaking = false

##### Upgrade Effects #####
var drill_level = 1
var oxygen_modifier = 0
var medkit_modifier = 0


##### CURRENCY SYSTEM #####
# Global credits variable to persist across levels
var credits: int = 250000

# Functions to manage credits
func add_credits(amount: int) -> void:
	credits += amount
	print("Credits added: ", amount, " Total credits: ", credits)

func remove_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		print("Credits removed: ", amount, " Remaining credits: ", credits)
		return true
	else:
		print("Not enough credits to remove. Current credits: ", credits)
		return false

func get_credits() -> int:
	return credits
