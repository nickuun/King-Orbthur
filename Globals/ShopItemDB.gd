extends Node

var shop_items := [
	{
		"name": "Speed Boots",
		"price": 8,
		"type": "passive",
		"texture": preload("res://Sprites/Items/Active&Passive/CustomItemSprite02.png"),
		"effect": "perm_speed_up",
		"available_for_sale": true,
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Increases your base speed permanently."
	},
	{
		"name": "Heart Container",
		"price": 10,
		"texture": preload("res://Sprites/Pixel_Icons/Food_Fruit_Apple.png"),
		"effect": "perm_hp_up",
		"available_for_sale": false,
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
		"available_for_sale": false,
		"duration": 5.0,
		"scene": preload("res://Sprites/Items/CustomIcons2.png"),
		"flavour": "Reduces orb speed permanently."
	},
		{
		"name": "Heal Up",
		"type": "battle",  # "battle", "active", or "passive"
		"price": 5,
		"available_for_sale": false,
		"duration": 5.0, #REMOVE REFACTOR refactor Nick
		"effect": "heal",
		"texture": preload("res://Sprites/Pixel_Icons/Alchemy_Potion_Vial_Bottle_Huge_Cube_Square_Empty.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Restores a bit of health. Feels good."
	},
	{
		"name": "Orb Grow",
		"type": "battle",
		"price": 7,
		"available_for_sale": false,
		"duration": 5.0,
		"effect": "temp_ball_grow",
		"texture": preload("res://Sprites/Items/CustomIcons15.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Temporarily increases orb size."
	},
	{
		"name": "Player Grow",
		"type": "battle",
		"price": 7,
		"available_for_sale": false,
		"duration": 5.0,
		"effect": "perm_player_grow",
		"texture": preload("res://Sprites/Items/CustomIcons6.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Temporarily increases player size."
	},
	{
		"name": "Player Speed BattlePickup",
		"type": "battle",
		"price": 7,
		"available_for_sale": false,
		"duration": 5.0,
		"effect": "temp_speed_up",
		"texture": preload("res://Sprites/Items/CustomIcons5.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Temporarily increases player speed."
	},
	{
		"name": "Lifesteal Serum",
		"type": "battle",
		"price": 9,
		"available_for_sale": false,
		"effect": "temp_lifesteal",
		"texture": preload("res://Sprites/Pixel_Icons/Food_Fruit_Apple.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Grants temporary lifesteal."
	},
	{
		"name": "Shop Discount Card",
		"type": "passive",
		"price": 12,
		"available_for_sale": false,
		"effect": "perm_shop_discount",
		"texture": preload("res://Sprites/Pixel_Icons/Food_Pizza.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Permanently reduces shop prices."
	},
	{
		"name": "Coin Frenzy",
		"type": "battle",
		"effect": "temp_coin_hit",
		"price": 0,
		"available_for_sale": false,
		"duration": 5.0,
		"texture": preload("res://Sprites/Items/CustomIcons19.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Bricks drop coins on-hit."
	},
	{
		"name": "Speed Booster",
		"type": "active",
		"price": 12,
		"available_for_sale": true,
		"effect": "active_speed_boost",
		"texture": preload("res://Sprites/Items/Active&Passive/CustomItemSprite05.png"),
		"flavour": "ACTIVE: Tap to double your speed temporarily."
	},
	{
		"name": "Orb Grower",
		"type": "active",
		"price": 10,
		"available_for_sale": true,
		"effect": "active_orb_grow",
		"texture": preload("res://Sprites/Items/Active&Passive/CustomItemSprite09.png"),
		"flavour": "ACTIVE: Temporarily enlarges the orb."
	},
	{
		"name": "Duration Boost",
		"type": "passive",
		"price": 10,
		"available_for_sale": true,
		"effect": "perm_duration_boost",
		"texture": preload("res://Sprites/Items/Active&Passive/CustomItemSprite03.png"),
		"scene": preload("res://Scenes&Scripts/Pickups/battle_pickup.tscn"),
		"flavour": "Increases the duration of Battle Pickups."
	}
]
