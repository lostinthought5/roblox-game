--[[ This script is called from Main.server when the player joins
the game or dies. It spawns the player character at the stage they
were on previously. ]]

local Spawning = {}
local DataStoring = require(script.Parent.DataStoring)
local CF = require(game:GetService("ReplicatedStorage").CommonFunctionality)

function Spawning.SpawnCharacter(plr, char)
	local success = pcall(function()
		local plrData = DataStoring.ReadData(plr)
		
		local currentPoint = CF.CheckpointByName[plrData.CurrentStage]
		local spawner = currentPoint.Spawner

		char:PivotTo(CFrame.new(spawner.Position + Vector3.new(0, 10, 0)))
	end)

	if not success then return end
end

return Spawning