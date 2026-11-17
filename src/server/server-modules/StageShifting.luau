--[[ This script is called from Main.server when the client requests
moving a checkpoint forward or backward. It shifts the player to the
next or previous checkpoint if it exists, by calling the Spawning script. ]]

local StageShifting = {}

local CF = require(game:GetService("ReplicatedStorage").CommonFunctionality)
local DataStoring = require(script.Parent.DataStoring)
local Spawning = require(script.Parent.Spawning)
local sendCurrentStage = CF.ReplicatedStorage.SendCurrentStage

local requestResponses = {
	["prevRequest"] = function(currentNum, furthestNum)
		return CF.CheckpointByNum[currentNum - 1]
	end,
	
	["nextRequest"] = function(currentNum, furthestNum)
		local requestedPoint = CF.CheckpointByNum[currentNum + 1]

		if requestedPoint and CF.NumByCheckpoint[requestedPoint] <= furthestNum then
			return requestedPoint
		end

		return nil
	end,
}

function StageShifting.ShiftStage(plr, clientRequest)
	local success = pcall(function()
		local plrData = DataStoring.ReadData(plr)
		local currentNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData.CurrentStage]]
		local furthestNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData.FurthestStage]]

		local serverResponse = requestResponses[clientRequest]
		local requestedPoint = serverResponse(currentNum, furthestNum)

		DataStoring.UpdatePlrData(plr, nil, requestedPoint.Name)
		sendCurrentStage:FireClient(plr, requestedPoint)
		Spawning.SpawnCharacter(plr, plr.Character)
	end)

	if not success then return end
end

return StageShifting
