extends Node

var current_location_id: String = ""

func go_to_location(loc_id: String) -> void:
    current_location_id = loc_id
    var loc_data: Dictionary = GameData.LOCATIONS.get(loc_id, {})
    GameLogger.log_info("你来到了%s" % loc_data.get("name", "未知地点"))
    EventBus.location_changed.emit(loc_id)

func leave_location() -> void:
    current_location_id = ""

func do_explore() -> void:
    if current_location_id == "":
        return
    if BattleSystem.in_battle:
        return
    # 消耗体力/饱食/饮水
    GameState.player["sta"] = max(0, int(GameState.player.get("sta", 100)) - 5)
    GameState.player["hunger"] = max(0, int(GameState.player.get("hunger", 100)) - 3)
    GameState.player["thirst"] = max(0, int(GameState.player.get("thirst", 100)) - 4)
    # 属性过低自动返回营地
    if int(GameState.player.get("sta", 0)) <= 0:
        GameLogger.log_warn("体力耗尽，你回到了营地休息")
        GameState.go_to_camp()
        return
    if int(GameState.player.get("hunger", 0)) <= 0 or int(GameState.player.get("thirst", 0)) <= 0:
        GameLogger.log_bad("你太饿/太渴了，不得不返回营地")
        GameState.go_to_camp()
        return
    var loc_data: Dictionary = GameData.LOCATIONS.get(current_location_id, {})
    # 30%概率遇怪
    var monsters: Array = loc_data.get("monsters", [])
    if monsters.size() > 0 and randf() < 0.3:
        var monster_id: String = monsters[randi() % monsters.size()]
        BattleSystem.start_battle(monster_id)
        return
    # 20%概率随机事件
    var events: Array = loc_data.get("events", [])
    if events.size() > 0 and randf() < 0.2:
        var event_id: String = events[randi() % events.size()]
        _trigger_event(event_id)
        return
    # 否则采集资源
    _gather_resources(loc_data.get("gather", {}))
    EventBus.player_stat_changed.emit()
    EventBus.resource_changed.emit()

func _gather_resources(gather_data: Dictionary) -> void:
    for item_id in gather_data:
        var count: int = int(gather_data[item_id])
        if randf() < 0.7: # 70%概率获得
            GameState.inventory[item_id] = int(GameState.inventory.get(item_id, 0)) + count
            GameLogger.log_good("采集到%s x%d" % [GameData.ITEMS.get(item_id, {}).get("name", item_id), count])

func _trigger_event(event_id: String) -> void:
    var event_data: Dictionary = GameData.EVENTS.get(event_id, {})
    GameLogger.log_info(event_data.get("text", "发生了一件事"))
    var effects: Dictionary = event_data.get("effects", {})
    for key in effects:
        var value: int = int(effects[key])
        if key == "hp" or key == "sta":
            GameState.player[key] = clamp(int(GameState.player.get(key, 0)) + value, 0, int(GameState.player.get("max_" + key, 100)))
        else:
            GameState.inventory[key] = int(GameState.inventory.get(key, 0)) + value