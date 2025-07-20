extends Node2D

@onready var ShopItemHolderScene = preload("res://Scenes&Scripts/Shop/shop_item_holder.tscn")

const ROWS := 2
const COLUMNS := 3
const COLUMNSPACING := 60

var start_pos := Vector2.ZERO
var offset = 0

func _ready():
	var db = load("res://Globals/ShopItemDB.gd").new()
	var items = db.shop_items.duplicate()
	items.shuffle()
	
	for i in range(min(items.size(), ROWS * COLUMNS)):
		var item_data = items[i]
		var holder = ShopItemHolderScene.instantiate()
		holder.position += Vector2(offset,0)
		offset += COLUMNSPACING
		self.call_deferred("add_child", holder)
		holder.setup(item_data)
	
