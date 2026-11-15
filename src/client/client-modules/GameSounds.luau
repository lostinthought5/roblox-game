local GameSounds = {}

-- imcomplete
GameSounds.SoundEffects = game:GetService("SoundService"):WaitForChild("SoundEffects")
GameSounds.Music = game:GetService("SoundService"):WaitForChild("Music")

function GameSounds.PlaySoundEffect(sound)
	sound:Play()
end

return GameSounds
