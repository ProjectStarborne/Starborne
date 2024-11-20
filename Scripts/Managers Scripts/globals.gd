# Globals.gd (singleton autoload)
extends Node


# Track upgrade purchases globally
var upgrades_purchased = {
	"Warp Engine V.1": false,
	"Fuel Efficiency Module V.1": false,
	"Stellar Cartography Module": false,
	"Reinforced Hull Plating": false,
	"Warp Engine V.2": false,
	"Deep Space Scanners": false,
	"Dark Matter Fuel Cells": false
}

# Global credits variable to persist across levels
var credits: int = 100

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
