--[[ This script is called by the VisualEffects and ClientComponents scripts.
It stores access to the sound assets stored in the engine as well as a functon
to play them. ]]

local GameSounds = {}

GameSounds.SoundEffects = game:GetService("SoundService"):WaitForChild("SoundEffects")
GameSounds.Music = game:GetService("SoundService"):WaitForChild("Music")

function GameSounds.PlaySoundEffect(sound)
	sound:Play()
end

return GameSounds
