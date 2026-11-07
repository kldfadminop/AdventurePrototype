extends Node

# 全局事件信号，所有信号必须先声明再使用
signal init_completed()
signal tick(delta: float)
signal player_stat_changed()
signal resource_changed()
signal stats_need_update()
signal log_added()
signal battle_start(monster: Dictionary)
signal battle_end(is_win: bool)
signal battle_turn_update()
signal level_up(new_level: int)
signal location_changed(new_loc: String)
