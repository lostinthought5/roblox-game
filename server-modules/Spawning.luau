local Spawning = {}
local DataStoring = require(script.Parent.DataStoring)
local CF = require(game:GetService("ReplicatedStorage").CommonFunctionality)

function Spawning.CharSpawning(plr, char)
	local success = pcall(function()
		local plrData = DataStoring.ReadData(plr)
		
		local currentPoint = CF.CheckpointByName[plrData["CurrentStage"]]
		local spawner = currentPoint.Spawner

		char:PivotTo(CFrame.new(spawner.Position + Vector3.new(0, 10, 0)))
	end)

	if not success then return end -- incomplete
	--[[
	local plrData = DataStoring.ReadData(plr)
	
	local checkpoint = CF.CheckpointByName[plrData["CurrentStage"
	if not checkpoint then return end
	
	local spawner = checkpoint.Spawner
	char:PivotTo(CFrame.new(spawner.Position + Vector3.new(0, 10, 0)))
	]]

end

return Spawning