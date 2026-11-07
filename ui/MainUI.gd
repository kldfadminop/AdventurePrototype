extends Control

@onready var tabs: TabContainer = $VBoxContainer/Tabs
@onready var camp_tab: Control = $VBoxContainer/Tabs/CampTab
@onready var map_tab: Control = $VBoxContainer/Tabs/MapTab
@onready var battle_tab: Control = $VBoxContainer/Tabs/BattleTab

func _ready() -> void:
	await EventBus.init_completed
	# 默认显示营地页
	tabs.current_tab = 0
	EventBus.battle_start.connect(_on_battle_start)
	EventBus.battle_end.connect(_on_battle_end)
	EventBus.location_changed.connect(_on_location_changed)

func _on_battle_start(_monster: Dictionary) -> void:
	# 战斗开始自动切到战斗页
	tabs.current_tab = 2

func _on_battle_end(_is_win: bool) -> void:
	# 战斗结束自动切回营地
	tabs.current_tab = 0

func _on_location_changed(new_loc: String) -> void:
	if new_loc == "camp":
		tabs.current_tab = 0
	else:
		tabs.current_tab = 1
