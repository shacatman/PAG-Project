extends Node

#Defines the BackgroundMusic autoload: playing the background music as long as the game is played.(loops)

func playMusic():
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.play()

func stopMusic():
	$AudioStreamPlayer.stop()
	
func playing():
	return $AudioStreamPlayer.playing

