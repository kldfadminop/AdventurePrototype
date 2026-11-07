extends Node

const TICK_INTERVAL: float = 5.0        # 探索推进间隔，保持原样
const AUTO_SAVE_INTERVAL: float = 60.0  # 自动存档间隔：1分钟

var player: Dictionary = {
	"name": "冒险者",
	"level": 1,
	"exp_points": 0,
	"max_hp": 100,
	"hp": 100,
	"max_sta": 100,
	"sta": 100,
	"max_hunger": 100,
	"hunger": 100,
	"max_thirst": 100,
	"thirst": 100,
	"atk": 5,
	"def": 2
}
var inventory: Dictionary = {
	"food": 2,
	"water": 2,
	"potion": 1,
	"wood": 0,
	"hide": 0,
	"gold": 10
}
var tick_timer: Timer = null
var auto_save_timer: Timer = null

func _ready() -> void:
	# 等待一帧所有autoload初始化完成
	await get_tree().process_frame
	# 创建5秒tick定时器
	tick_timer = Timer.new()
	tick_timer.wait_time = TICK_INTERVAL
	tick_timer.autostart = true
	tick_timer.timeout.connect(_on_tick)
	add_child(tick_timer)
	auto_save_timer = Timer.new()                        # 新增：独立的自动存档定时器
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.autostart = true
	auto_save_timer.timeout.connect(_on_auto_save)
	add_child(auto_save_timer)
	# 尝试加载存档
	var save_data: Dictionary = SaveManager.load_game()
	if save_data:
		if save_data.has("player"):
			player = save_data["player"]
		if save_data.has("inventory"):
			inventory = save_data["inventory"]
		GameLogger.log_info("读取存档成功，欢迎回来，%s" % player.get("name", "冒险者"))
	else:
		GameLogger.log_info("新游戏开始，欢迎来到小白的文字游戏！")
	EventBus.init_completed.emit()
	EventBus.stats_need_update.emit()
	EventBus.resource_changed.emit()
	EventBus.player_stat_changed.emit()

func _on_tick() -> void:
	EventBus.tick.emit(get_process_delta_time())
	# 如果在探索，执行探索逻辑
	if ExploreSystem.current_location_id != "":
		ExploreSystem.do_explore()

func _on_auto_save() -> void:                            # 每1分钟触发
	manual_save()

func manual_save() -> void:
	var save_data: Dictionary = {
		"player": player,
		"inventory": inventory,
		"version": 1
	}
	SaveManager.save_game(save_data)

func reset_game() -> void:
	SaveManager.delete_save()
	# 重置玩家数据
	player = {
		"name": "冒险者",
		"level": 1,
		"exp_points": 0,
		"max_hp": 100,
		"hp": 100,
		"max_sta": 100,
		"sta": 100,
		"max_hunger": 100,
		"hunger": 100,
		"max_thirst": 100,
		"thirst": 100,
		"atk": 5,
		"def": 2
	}
	# 重置背包初始物品
	inventory = {
		"food": 2,
		"water": 2,
		"potion": 1,
		"wood": 0,
		"hide": 0,
		"gold": 10
	}
	ExploreSystem.leave_location()
	BattleSystem.in_battle = false
	GameLogger.log_info("游戏已重置，开始新的冒险！")
	EventBus.stats_need_update.emit()
	EventBus.resource_changed.emit()
	EventBus.player_stat_changed.emit()
	EventBus.location_changed.emit("camp")

func go_to_location(loc_id: String) -> void:
	ExploreSystem.go_to_location(loc_id)

func go_to_camp() -> void:
	ExploreSystem.leave_location()
	EventBus.location_changed.emit("camp")
	GameLogger.log_info("你回到了营地")

func rest() -> void:
	if ExploreSystem.current_location_id != "":
		GameLogger.log_warn("探索中不能休息，请先返回营地")
		return
	# 检查食物水是否足够
	if int(inventory.get("food", 0)) < 1 or int(inventory.get("water", 0)) < 1:
		GameLogger.log_bad("没有足够的食物或水，无法休息！")
		return
	inventory["food"] = int(inventory.get("food", 0)) - 1
	inventory["water"] = int(inventory.get("water", 0)) - 1
	player["sta"] = min(int(player.get("max_sta", 100)), int(player.get("sta", 0)) + 30)
	player["hp"] = min(int(player.get("max_hp", 100)), int(player.get("hp", 0)) + 10)
	GameLogger.log_good("你休息了一会，消耗1干粮1清水，恢复30体力10气血")
	EventBus.player_stat_changed.emit()
	EventBus.resource_changed.emit()

func use_item(item_id: String) -> void:
	if int(inventory.get(item_id, 0)) <= 0:
		GameLogger.log_bad("你没有这个物品")
		return
	var item_data: Dictionary = GameData.ITEMS.get(item_id, {})
	if not item_data.get("can_use", false):
		GameLogger.log_warn("这个物品不能使用")
		return
	var effect: Dictionary = item_data.get("use_effect", {})
	# 应用效果
	for key in effect:
		var value: int = int(effect[key])
		if key == "hp":
			player[key] = clamp(int(player.get(key, 0)) + value, 0, int(player.get("max_hp", 100)))
		elif key == "sta":
			player[key] = clamp(int(player.get(key, 0)) + value, 0, int(player.get("max_sta", 100)))
		elif key == "hunger":
			player[key] = clamp(int(player.get(key, 0)) + value, 0, int(player.get("max_hunger", 100)))
		elif key == "thirst":
			player[key] = clamp(int(player.get(key, 0)) + value, 0, int(player.get("max_thirst", 100)))
	# 消耗物品
	inventory[item_id] = int(inventory.get(item_id, 0)) - 1
	GameLogger.log_good("使用了%s" % item_data.get("name", item_id))
	EventBus.player_stat_changed.emit()
	EventBus.resource_changed.emit()
