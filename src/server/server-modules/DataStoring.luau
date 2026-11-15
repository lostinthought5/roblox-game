local DataStoring = {}

local dataStoreService = game:GetService("DataStoreService")
local plrDataStore = dataStoreService:GetDataStore("plrObbyData")
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local triggerSpawning = CF.ServerStorage:WaitForChild("TriggerSpawning")

local currentPlayers = {} -- of form userID : dataTable
local savingFor = {}

-- data storing incomplete; needs further tweaking REMEMBER

function DataStoring.AddPlayers(plr, plrData)
	currentPlayers[plr.UserId] = plrData
end

function DataStoring.UpdatePlrData(plr, furthestStage, currentStage) -- should use a callback instead
	--arguments must be strings
	local plrData = currentPlayers[plr.UserId]
	if not plrData then return end
	
	if furthestStage then
		plrData["FurthestStage"] = furthestStage
	end

	if currentStage then
		plrData["CurrentStage"] = currentStage
	end
end

function DataStoring.ReadData(plr)
	if not currentPlayers[plr.UserId] then return end
	return currentPlayers[plr.UserId]
end

function DataStoring.PlrRemove(plr)
	currentPlayers[plr.UserId] = nil
end

local defaultData = {
	-- may add more keys as needed
	CurrentStage = "Checkpoint1",
	FurthestStage = "Checkpoint1",
	Role = "GUEST",
}

function DataStoring.DataRetrieval(plr)
	local success, plrData = pcall(function()
		return plrDataStore:GetAsync(plr.UserId)
	end)
	
	if not success then plr:Kick("Player save file failed to load. Rejoin to prevent data loss!") end
	if not plrData then
		plrData = table.clone(defaultData)
		
	elseif type(plrData) ~= "table" then
		plr:Kick("Player save file is corrupted. Rejoin to prevent data loss!")

	else
		for key, value in pairs(defaultData) do
			if plrData[key] == nil then -- if nonexistent
				plrData[key] = value
				
			end
		end
	end

	print(plrData)
	DataStoring.AddPlayers(plr, plrData)
	if plrData["Role"] then plr:SetAttribute("Role", plrData["Role"]) end
	triggerSpawning:Fire(plr)

end

function DataStoring.DataStore(plr)
	if savingFor[plr.UserId] then return end
	savingFor[plr.UserId] = true
	
	local plrData = DataStoring.ReadData(plr)
	if not plrData then 
		savingFor[plr.UserId] = nil
		return 
	end

	local attempt, max = 0, 3
	local success
	
	repeat
		success = pcall(function()
			plrDataStore:SetAsync(plr.UserId, plrData)
		end)

		if not success then
			attempt += 1
			warn("FAILED TO SAVE DATA x" .. attempt) -- only prints in console in-game
			task.wait(2)

		end

	until success or attempt >= max
	DataStoring.PlrRemove(plr)
	savingFor[plr.UserId] = nil
	
end

function DataStoring.EmergencySave()
	local dataToSave = 0
	for _, plr in CF.Players:GetPlayers() do
		dataToSave += 1
		
		task.spawn(function() -- multithreads; handles all players in-game
			DataStoring.DataStore(plr)
			dataToSave -= 1
			
		end)
	end
	
	while dataToSave > 0 do -- necessary, for loop above runs instantaneously
		task.wait(0.5)
	end
end

return DataStoring