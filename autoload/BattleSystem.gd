extends Node

var current_monster: Dictionary = {}
var in_battle: bool = false

func start_battle(monster_id: String) -> void:
	if in_battle:
		return
	current_monster = GameData.MONSTERS[monster_id].duplicate(true)
	in_battle = true
	GameLogger.log_battle("遭遇了%s！" % current_monster.get("name", "怪物"))
	EventBus.battle_start.emit(current_monster)

func player_attack(is_heavy: bool) -> void:
	if not in_battle:
		return
	var hit_chance: float = 0.9
	var damage: int = max(1, int(GameState.player.get("atk", 1)) - int(current_monster.get("def", 0)))
	var crit_text: String = ""
	if is_heavy:
		hit_chance = 0.5
		damage = int(damage * 2)
		crit_text = "重击，"
	# 命中判定
	if randf() > hit_chance:
		GameLogger.log_battle("你的%s攻击落空了！" % crit_text)
	else:
		current_monster["hp"] -= damage
		GameLogger.log_battle("你用%s对%s造成%d点伤害！" % [crit_text, current_monster.get("name", "怪物"), damage])
		EventBus.battle_turn_update.emit()
		if int(current_monster.get("hp", 0)) <= 0:
			_battle_win()
			return
	# 怪物反击
	_monster_attack()

func _monster_attack() -> void:
	var damage: int = max(1, int(current_monster.get("atk", 1)) - int(GameState.player.get("def", 0)))
	GameState.player["hp"] = max(0, int(GameState.player.get("hp", 100)) - damage)
	GameLogger.log_battle("%s对你造成%d点伤害！" % [current_monster.get("name", "怪物"), damage])
	EventBus.player_stat_changed.emit()
	EventBus.battle_turn_update.emit()
	if int(GameState.player.get("hp", 0)) <= 0:
		_battle_lose()

func try_flee() -> void:
	if not in_battle:
		return
	if randf() < 0.6:
		GameLogger.log_battle("你成功逃跑了！")
		_end_battle(false)
		GameState.go_to_camp()
	else:
		GameLogger.log_battle("逃跑失败！")
		_monster_attack()

func _battle_win() -> void:
	GameLogger.log_good("你击败了%s！" % current_monster.get("name", "怪物"))
	# 获得经验金币
	var exp_gain: int = int(current_monster.get("exp", 0))
	var gold_gain: int = int(current_monster.get("gold", 0))
	GameState.player["exp_points"] = int(GameState.player.get("exp_points", 0)) + exp_gain
	GameState.player["gold"] = int(GameState.player.get("gold", 0)) + gold_gain
	GameLogger.log_good("获得%d经验，%d金币" % [exp_gain, gold_gain])
	# 掉落物品
	var drop: Dictionary = current_monster.get("drop", {})
	for item_id in drop:
		var count: int = int(drop[item_id])
		GameState.inventory[item_id] = int(GameState.inventory.get(item_id, 0)) + count
		GameLogger.log_good("获得%s x%d" % [GameData.ITEMS.get(item_id, {}).get("name", item_id), count])
	# 检查升级
	_check_level_up()
	EventBus.resource_changed.emit()
	EventBus.player_stat_changed.emit()
	_end_battle(true)
	GameState.go_to_camp()

func _battle_lose() -> void:
	GameLogger.log_bad("你被%s击败了，回到营地休息..." % current_monster.get("name", "怪物"))
	GameState.player["hp"] = int(GameState.player.get("max_hp", 100) / 2)
	EventBus.player_stat_changed.emit()
	_end_battle(false)
	GameState.go_to_camp()

func _end_battle(is_win: bool) -> void:
	in_battle = false
	current_monster = {}
	EventBus.battle_end.emit(is_win)

func _check_level_up() -> void:
	var need_exp: int = int(GameState.player.get("level", 1)) * 50
	while int(GameState.player.get("exp_points", 0)) >= need_exp:
		GameState.player["exp_points"] = int(GameState.player.get("exp_points", 0)) - need_exp
		GameState.player["level"] = int(GameState.player.get("level", 1)) + 1
		# 升级属性提升
		GameState.player["max_hp"] = int(GameState.player.get("max_hp", 100)) + 10
		GameState.player["hp"] = int(GameState.player.get("max_hp", 100))
		GameState.player["atk"] = int(GameState.player.get("atk", 5)) + 2
		GameState.player["def"] = int(GameState.player.get("def", 2)) + 1
		GameLogger.log_good("升级了！当前等级：%d，气血上限+10，攻击+2，防御+1" % int(GameState.player.get("level", 1)))
		EventBus.level_up.emit(int(GameState.player.get("level", 1)))
		need_exp = int(GameState.player.get("level", 1)) * 50
