extends Node

var log_list: PackedStringArray = PackedStringArray()
var log_ui: RichTextLabel = null
var log_file_path: String = "res://log/" + Time.get_datetime_string_from_system().replace(":", "-") + ".log"

func _ready() -> void:
	# 创建日志目录
	var dir: DirAccess = DirAccess.open("res://")
	if not dir.dir_exists("log"):
		dir.make_dir("log")

func set_ui(ui_node: RichTextLabel) -> void:
	log_ui = ui_node
	# 显示已有日志
	for line in log_list:
		log_ui.append_text(line + "\n")

func _write_to_file(text: String) -> void:
	# GDScript 4.6 正确追加写入方式：WRITE_READ模式+seek_end
	var file: FileAccess = FileAccess.open(log_file_path, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line("[%s] %s" % [Time.get_datetime_string_from_system(), text])
		file.close()

func add_log(text: String, color: String = "#ffffff") -> void:
	var colored_line: String = "[color=%s]%s[/color]" % [color, text]
	log_list.append(colored_line)
	if log_list.size() > 500:
		log_list.remove_at(0)
	if log_ui:
		log_ui.append_text(colored_line + "\n")
		# 自动滚动到底部
		log_ui.scroll_to_line(log_ui.get_line_count())
	_write_to_file(text)
	EventBus.log_added.emit()

func log_info(text: String) -> void:
	add_log("[信息] " + text, "#cccccc")

func log_good(text: String) -> void:
	add_log("[成功] " + text, "#55ff55")

func log_warn(text: String) -> void:
	add_log("[警告] " + text, "#ffff55")

func log_bad(text: String) -> void:
	add_log("[错误] " + text, "#ff5555")

func log_battle(text: String) -> void:
	add_log("[战斗] " + text, "#ffaa00")
