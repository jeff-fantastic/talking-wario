class_name WarioListen extends Node

## Handles Wario's listening pattern
## and audio manipulation

const STR_LISTEN = [
	"Wario is not listening...",
	"Wario is listening..."
]

export (NodePath) var label_listening_path
onready var label_listening : Label = get_node(label_listening_path)
export (NodePath) var input_spinner_path
onready var input_spinner : OptionButton = get_node(input_spinner_path)

var listening_state : bool = false
var effect : AudioEffect
var recording : AudioStreamSample

func _ready() -> void:
	# Get input bus
	var idx := AudioServer.get_bus_index("AudioIn")
	effect = AudioServer.get_bus_effect(idx, 0)
	
	# Get available input devices
	var inp = AudioServer.capture_get_device_list()
	for v in inp:
		input_spinner.add_item(v)

func _on_button_press(toggle : bool) -> void:
	# Set listening state
	listening_state = toggle
	label_listening.text = STR_LISTEN[1] if listening_state else STR_LISTEN[0]
	
	# Toggle recording
	effect.set_recording_active(listening_state)
	if listening_state:
		$record.stream = AudioStreamMicrophone.new()
		$record.playing = true
	
	# If inactive, play sound back to user
	if !listening_state:
		recording = effect.get_recording()
		$playback.stream = recording
		$playback.play()

func _audio_input_selected(input : int) -> void:
	# Set input
	AudioServer.capture_device = input_spinner.get_item_text(input)
	print(AudioServer.capture_get_device())
