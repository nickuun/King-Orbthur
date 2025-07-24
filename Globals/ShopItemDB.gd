extends Node

var shop_items := [
	{
		"name": "Speed Syringe",
		"price": 8,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Pizza.png"),
		"effect": "temp_speed_up",
		"available_for_sale": true,
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Increases your base speed permanently."
	},
	{
		"name": "Heart Container",
		"price": 10,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Fruit_Apple.png"),
		"effect": "perm_hp_up",
		"available_for_sale": true,
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grants extra max lifepoints."
	},
	{
		"name": "Chonker Shroom",
		"price": 6,
		"texture": preload("res://Sprites/Pixel_Icons/Hats_Astronaut_Helm_Space_Suit.png"),
		"effect": "perm_size_speed_trade",
		"available_for_sale": false,
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grow big. Get slower."
	},
	{
		"name": "Orb Stabilizer",
		"price": 9,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Baby_Pacifier_Easy.png"),
		"effect": "temp_ball_slow",
		"available_for_sale": true,
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Reduces orb speed permanently."
	},
		{
		"name": "Heal Up",
		"type": "battle",  # "battle", "active", or "passive"
		"price": 5,
		"available_for_sale": true,
		"effect": "heal",
		"texture": preload("res://Sprites/Pixel_Icons/Alchemy_Potion_Vial_Bottle_Huge_Cube_Square_Empty.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Restores a bit of health. Feels good."
	},
	{
		"name": "Orb Grow",
		"type": "battle",
		"price": 7,
		"available_for_sale": true,
		"effect": "temp_ball_grow",
		"texture": preload("res://Sprites/Pixel_Icons/Food_Baby_Pacifier_Easy.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Temporarily increases orb size."
	},
	{
		"name": "Player Grow",
		"type": "battle",
		"price": 7,
		"available_for_sale": true,
		"effect": "temp_player_grow",
		"texture": preload("res://Sprites/Pixel_Icons/Hats_Astronaut_Helm_Space_Suit.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Temporarily increases player size."
	},
	{
		"name": "Lifesteal Serum",
		"type": "battle",
		"price": 9,
		"available_for_sale": true,
		"effect": "temp_lifesteal",
		"texture": preload("res://Sprites/Pixel_Icons/Food_Fruit_Apple.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grants temporary lifesteal."
	},
	{
		"name": "Shop Discount Card",
		"type": "passive",
		"price": 12,
		"available_for_sale": true,
		"effect": "perm_shop_discount",
		"texture": preload("res://Sprites/Pixel_Icons/Food_Pizza.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Permanently reduces shop prices."
	},
	{
	"name": "Coin Magnetizer",
	"type": "battle",
	"effect": "temp_coin_hit",
	"price": 0,
	"available_for_sale": false,
	"texture": preload("res://Sprites/Pixel_Icons/Food_Pizza.png"),
	"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
	"flavour": "Bricks drop coins even when tapped!"
},

]
