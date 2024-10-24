extends Control

# Gives access to both grid containers
@onready var inventory_grid_container: GridContainer = %InventoryGridContainer
@onready var ship_grid_container: GridContainer = %ShipGridContainer

# Player's inventory
@onready var inv : Inventory
@onready var ship_inv : Inventory

# Open ship storage UI and populate the grid container slots for both sides
func open():
	pass
