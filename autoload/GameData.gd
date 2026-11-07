extends Node

# 物品数据：key为物品ID
const ITEMS: Dictionary = {
	"food": {"name": "干粮", "desc": "普通干粮，恢复20点饱食度", "can_use": true, "use_effect": {"hunger": 20}},
	"water": {"name": "清水", "desc": "干净的饮用水，恢复30点饮水度", "can_use": true, "use_effect": {"thirst": 30}},
	"potion": {"name": "治疗药水", "desc": "恢复30点气血", "can_use": true, "use_effect": {"hp": 30}},
	"wood": {"name": "木材", "desc": "建造材料", "can_use": false},
	"hide": {"name": "兽皮", "desc": "制作材料", "can_use": false},
	"gold": {"name": "金币", "desc": "通用货币", "can_use": false}
}

# 怪物数据
const MONSTERS: Dictionary = {
	"slime": {"name": "史莱姆", "hp": 20, "atk": 3, "def": 0, "exp": 10, "gold": 5, "drop": {"wood": 1}},
	"wolf": {"name": "野狼", "hp": 40, "atk": 8, "def": 2, "exp": 25, "gold": 15, "drop": {"hide": 1, "food": 1}},
	"bear": {"name": "黑熊", "hp": 80, "atk": 15, "def": 5, "exp": 60, "gold": 40, "drop": {"hide": 3, "potion": 1}}
}

# 地点数据：key为地点ID
const LOCATIONS: Dictionary = {
	"forest": {"name": "新手森林", "req_level": 1, "monsters": ["slime"], "gather": {"wood": 2, "food": 1}, "events": ["find_potion", "meet_traveler"]},
	"mountain": {"name": "野狼坡", "req_level": 3, "monsters": ["wolf"], "gather": {"hide": 1, "wood": 1}, "events": ["find_hide", "rest_spot"]},
	"cave": {"name": "黑熊洞", "req_level": 7, "monsters": ["bear"], "gather": {"gold": 10}, "events": ["find_treasure", "trap"]}
}

# 随机事件数据
const EVENTS: Dictionary = {
	"find_potion": {"text": "你在草丛里发现了一瓶治疗药水！", "effects": {"potion": 1}},
	"meet_traveler": {"text": "你遇到了旅行商人，他给了你5金币", "effects": {"gold": 5}},
	"find_hide": {"text": "你捡到了一张完整的兽皮", "effects": {"hide": 1}},
	"rest_spot": {"text": "你发现了一个休息点，恢复了20点体力", "effects": {"sta": 20}},
	"find_treasure": {"text": "你找到了一个宝箱，获得30金币！", "effects": {"gold": 30}},
	"trap": {"text": "你踩中了陷阱，损失了10点气血", "effects": {"hp": -10}}
}
