# actor.gd
class_name Actor extends Spatial

## Handles Wario's visuals/animation

export (NodePath) var visual_path
onready var visual = get_node_or_null(visual_path)

func _ready() -> void:
	# Set animation
	var anim : AnimationPlayer = visual.get_node("AnimationPlayer")
	anim.play("DefaultWarioBase")

## Called when user starts recording their voice
func _started_recording() -> void:
	# Set animation
	var anim : AnimationPlayer = visual.get_node("AnimationPlayer")
	anim.play("TalkingWarioListen")
	
## Called when user is done recording their voice
func _voice_recieved(player : AudioStreamPlayer) -> void:
	# Set animation
	var anim : AnimationPlayer = visual.get_node("AnimationPlayer")
	anim.play("WarioTalking")
	
	# Get jaw bone
	var skeleton : Skeleton = visual.get_node("Armature/Skeleton")
	var jaw := skeleton.find_bone("Talk")
	var base_pose := skeleton.get_bone_custom_pose(jaw)
	var target_pose = base_pose
	var current_pose = base_pose
	
	# Prepare spectrum analyzer
	var bus := AudioServer.get_bus_index("Wario")
	var spectrum : AudioEffectSpectrumAnalyzerInstance = AudioServer.get_bus_effect_instance(bus, 0)
	
	while player.is_playing():
		# Poll audio playback bus
		var db := spectrum.get_magnitude_for_frequency_range(1000, 10000).length()
		db *= 100
		
		# Rotate jawbone
		target_pose = base_pose.rotated(Vector3.FORWARD, db)
		current_pose = current_pose.interpolate_with(target_pose, 0.2)
		skeleton.set_bone_custom_pose(jaw, current_pose)
		
		# Wait a frame
		yield(get_tree(), "idle_frame")
	
	# Reset pose
	skeleton.set_bone_custom_pose(jaw, base_pose)

