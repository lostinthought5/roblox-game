local Spawning = {}
local DataStoring = require(script.Parent.DataStoring)
local CF = require(game:GetService("ReplicatedStorage").CommonFunctionality)

function Spawning.CharSpawning(plr, char)
	local success = pcall(function()
		local plrData = DataStoring.ReadData(plr)
		
		local currentPoint = CF.CheckpointByName[plrData.CurrentStage]
		local spawner = currentPoint.Spawner

		char:PivotTo(CFrame.new(spawner.Position + Vector3.new(0, 10, 0)))
	end)

	if not success then return end
end

return Spawning