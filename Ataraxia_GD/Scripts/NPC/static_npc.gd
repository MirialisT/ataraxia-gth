extends Character
class_name StaticNPC
# TODO: UPDATE IT PLS
@export var npc_name = "changeme"
@export_enum("Human", "Elf", "HighElf", "HalfElf", "BeastMan") var race_name: String
@export_enum("Male", "Female", "BeastMale", "BeastFemale") var sex: String
@onready var race = $PropertyController/RaceController.get_race(race_name, npc_name)
@onready var stats_handler = $PropertyController/StatsController.StatsHandler.new()
@onready var body = $PropertyController/BodyController.Body.new()

#var inputs = {
	#"move_right": Vector2.RIGHT,
	#"move_left": Vector2.LEFT,
	#"move_up": Vector2.UP,
	#"move_down": Vector2.DOWN
	#}
		
func get_hit(bodypart_name: String, damage_amount: int, bleed_severity: int):
	print("%s got hit by player in %s by %d with bleed severity %d" % [npc_name, bodypart_name, damage_amount, bleed_severity])
	body.bodypart_get_hit(bodypart_name, damage_amount, bleed_severity)
	if !body.is_alive: handle_death()
	else: update_hbar()

func _mouse_enter() -> void:
	# TODO: maybe change to RichText + statuses?
	$PanelContainer/Label.text = "%s %s %s\n%d/%d\n" % [npc_name, sex, race_name, body.get_current_health(), body.get_max_health()]
	$PanelContainer/Label.text += "Alive: %s, consious: %s" % [body.is_alive, body.is_consious]
	$PanelContainer/Label.visible = true
	$PanelContainer.visible = true

func _mouse_exit() -> void:
	$PanelContainer/Label.visible = false
	$PanelContainer.visible = false
	
func _ready():
	TimeProcesser.process_time.connect(_on_time_process)
	sprite_handler()
	stats_handler.modify_stats(race.get_race_buffs())
	$hbar.max_value = body.get_max_health()
	print("%s %s, level %d, spare points %d" % [race.race_name, npc_name, stats_handler.level, stats_handler.spare_points])
	print("Current race buffs: ", race.get_race_buffs())
	print("Current stats: ", stats_handler.get_stats_dict())
	print("%d/%d" % [body.get_max_health(), body.get_current_health()])
	update_hbar()
	print("\n")

func handle_death():
	$hbar.queue_free()

func update_hbar():
	$hbar.value = body.get_current_health()

func ping():
	if body.is_consious: return "Pong"
	else: return "silence"

func fix_position():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * tile_size/2

func sprite_handler():
	# TODO: art-related
	# draw better sprites x(
	var sprite_name: String = race_name + sex
	$Sprite2D.texture = load("res://Sprites/NPC/%s/%s.png" % [race_name, sprite_name])
	if sex == "Male":
		pronouns["third_face"] = "he"
		pronouns["possesive"] = "his"
	if sex == "Female":
		pronouns["third_face"] = "she"
		pronouns["possesive"] = "her"
	if sex in ["BeastMale", "BeastFemale"]:
		pronouns["third_face"] = "it"
		pronouns["possesive"] = "it's"
#func _process(_delta) -> void:
	#if !stats_handler.is_alive: queue_free()

#func collision_handler(direction):
	#var raycast_x = tile_size * inputs[direction][0]
	#var raycast_y = tile_size * inputs[direction][1]
	#$RayCast2D.target_position = Vector2(raycast_x, raycast_y)
	#$RayCast2D.force_raycast_update()
	#return !$RayCast2D.is_colliding()

func _on_time_process(time_amount: int):
	print("%s processing time %d" % [npc_name, time_amount])
	update_hbar()
