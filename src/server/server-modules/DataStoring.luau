local DataStoring = {}

local dataStoreService = game:GetService("DataStoreService")
local plrDataStore = dataStoreService:GetDataStore("plrObbyData")
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local triggerSpawning = CF.ServerStorage:WaitForChild("TriggerSpawning")

local currentPlayers = {}  -- of form userID : dataTable
local savingFor = {}

function DataStoring.AddPlayers(plr, plrData)
	currentPlayers[plr.UserId] = plrData
end

function DataStoring.UpdatePlrData(plr, furthestStage, currentStage)  -- arguments must be strings
	local plrData = currentPlayers[plr.UserId]
	if not plrData then return end
	
	if furthestStage then
		plrData.FurthestStage = furthestStage
	end

	if currentStage then
		plrData.CurrentStage = currentStage
	end
end

function DataStoring.ReadData(plr)
	if not currentPlayers[plr.UserId] then return end
	return currentPlayers[plr.UserId]
end

function DataStoring.PlrRemove(plr)
	currentPlayers[plr.UserId] = nil
end

local defaultData = {  -- more keys may be added
	CurrentStage = "Checkpoint1",
	FurthestStage = "Checkpoint1",
	Role = "GUEST",
}

local function repeatAttempt(plr, callback)
	local MAX = 3
	local attempt = 0

	for i = attempt, MAX do
		local success, plrData = pcall(callback)

		if success then
			return true, plrData
		end
		
		if attempt < MAX then  -- to minimize waiting time
			task.wait(2)
		end
	end
	
	return false
end

function DataStoring.DataRetrieval(plr)
	local success, plrData = repeatAttempt(plr, function()
		return plrDataStore:GetAsync(plr.UserId)
	end)


	if plr.Parent == nil then return end
	
	if not success then 
		plr:Kick("Player save file failed to load. Rejoin to prevent data loss!") 
		return  -- crucial, otherwise data is overwritten
	end
	if not plrData then
		plrData = table.clone(defaultData)
		
	elseif type(plrData) ~= "table" then
		plr:Kick("Player save file is corrupted. Rejoin to prevent data loss!")
		return  -- same as above

	else
		for key, value in pairs(defaultData) do
			if plrData[key] == nil then
				plrData[key] = value
				
			end
		end
	end

	DataStoring.AddPlayers(plr, plrData)
	if plrData.Role then plr:SetAttribute("Role", plrData.Role) end
	triggerSpawning:Fire(plr)

end

function DataStoring.DataStore(plr)  -- saves progress upon leaving
	if savingFor[plr.UserId] then return end
	savingFor[plr.UserId] = true
	
	local plrData = DataStoring.ReadData(plr)
	if not plrData then 
		savingFor[plr.UserId] = nil
		return 
	end

	local success = repeatAttempt(plr, function()
		return plrDataStore:SetAsync(plr.UserId, plrData)
	end)

	if not success then
		warn("COULD NOT SAVE DATA FOR: " .. plr.UserId)
	end

	DataStoring.PlrRemove(plr)
	savingFor[plr.UserId] = nil
	
end

function DataStoring.EmergencySave()
	local dataToSave = 0
	for _, plr in CF.Players:GetPlayers() do
		dataToSave += 1
		
		task.spawn(function()  -- multithreads; handles all players simultaneously
			DataStoring.DataStore(plr)
			dataToSave -= 1
			
		end)
	end
	
	while dataToSave > 0 do  -- necessary, for loop above runs instantaneously
		task.wait(0.5)
	end
end

return DataStoring