extends PanelContainer

@onready var level_label: Label = $VBoxContainer/TopRow/LevelLabel
@onready var atk_label: Label = $VBoxContainer/TopRow/AtkLabel
@onready var def_label: Label = $VBoxContainer/TopRow/DefLabel
@onready var gold_label: Label = $VBoxContainer/TopRow/GoldLabel
@onready var save_btn: Button = $VBoxContainer/TopRow/ButtonRow/SaveBtn
@onready var reset_btn: Button = $VBoxContainer/TopRow/ButtonRow/ResetBtn
@onready var hp_bar: ProgressBar = $VBoxContainer/BarsGrid/HpRow/HpBar
@onready var hp_label: Label = $VBoxContainer/BarsGrid/HpRow/HpLabel
@onready var sta_bar: ProgressBar = $VBoxContainer/BarsGrid/StaRow/StaBar
@onready var sta_label: Label = $VBoxContainer/BarsGrid/StaRow/StaLabel
@onready var hunger_bar: ProgressBar = $VBoxContainer/BarsGrid/HungerRow/HungerBar
@onready var hunger_label: Label = $VBoxContainer/BarsGrid/HungerRow/HungerLabel
@onready var thirst_bar: ProgressBar = $VBoxContainer/BarsGrid/ThirstRow/ThirstBar
@onready var thirst_label: Label = $VBoxContainer/BarsGrid/ThirstRow/ThirstLabel
@onready var exp_bar: ProgressBar = $VBoxContainer/BarsGrid/ExpRow/ExpBar
@onready var exp_label: Label = $VBoxContainer/BarsGrid/ExpRow/ExpLabel

func _ready() -> void:
	if save_btn:
		save_btn.pressed.connect(GameState.manual_save)
	if reset_btn:
		reset_btn.pressed.connect(func(): GameState.reset_game())
	EventBus.stats_need_update.connect(_refresh)
	EventBus.player_stat_changed.connect(_refresh)
	EventBus.resource_changed.connect(_refresh)
	await EventBus.init_completed
	_refresh()

func _refresh() -> void:
	if not level_label:
		return
	var p: Dictionary = GameState.player
	var inv: Dictionary = GameState.inventory
	level_label.text = "等级:%d" % p.get("level", 1)
	atk_label.text = "攻击:%d" % p.get("atk", 5)
	def_label.text = "防御:%d" % p.get("def", 2)
	gold_label.text = "金币:%d" % inv.get("gold", 0)
	# 进度条
	var max_hp: int = p.get("max_hp", 100)
	hp_bar.max_value = max_hp
	hp_bar.value = p.get("hp", 100)
	hp_label.text = "气血:%d/%d" % [p.get("hp", 100), max_hp]
	var max_sta: int = p.get("max_sta", 100)
	sta_bar.max_value = max_sta
	sta_bar.value = p.get("sta", 100)
	sta_label.text = "体力:%d/%d" % [p.get("sta", 100), max_sta]
	var max_hunger: int = p.get("max_hunger", 100)
	hunger_bar.max_value = max_hunger
	hunger_bar.value = p.get("hunger", 100)
	hunger_label.text = "饱食:%d/%d" % [p.get("hunger", 100), max_hunger]
	var max_thirst: int = p.get("max_thirst", 100)
	thirst_bar.max_value = max_thirst
	thirst_bar.value = p.get("thirst", 100)
	thirst_label.text = "饮水:%d/%d" % [p.get("thirst", 100), max_thirst]
	var need_exp: int = p.get("level", 1) * 50
	exp_bar.max_value = need_exp
	exp_bar.value = p.get("exp_points", 0)
	exp_label.text = "经验:%d/%d" % [p.get("exp_points", 0), need_exp]
