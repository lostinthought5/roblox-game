-- game:GetService("DataStoreService"):GetDataStore("plrObbyData"):RemoveAsync(10783656763)
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
CF.InitializeCheckpoints()

local serverScriptService = game:GetService("ServerScriptService")
local startPlrs = game:GetService("StarterPlayer")
print(startPlrs.EnableMouseLockOption)

local serverModules = {}
local serverScripts = serverScriptService:FindFirstChild("ServerScripts")
local moduleFolder = serverScripts:FindFirstChild("Modules")

for _, module in moduleFolder:GetChildren() do
	serverModules[module.Name] = require(module)
end

serverModules["ServerComponents"].Initialize()

CF.Players.PlayerAdded:Connect(function(plr)
	serverModules["DataStoring"].DataRetrieval(plr)
end)

CF.Players.PlayerRemoving:Connect(function(plr)
	serverModules["DataStoring"].DataStore(plr)
end)

local triggerSpawning = CF.ServerStorage:WaitForChild("TriggerSpawning")
triggerSpawning.Event:Connect(function(plr)
	if plr.Character then
		serverModules["CollisionGrouping"].SetCollisionGroup(plr.Character)
		serverModules["Spawning"].CharSpawning(plr, plr.Character)
		serverModules["CustomNameTags"].CreateNameTag(plr, plr.Character)

	end

	plr.CharacterAdded:Connect(function(char)
		serverModules["CollisionGrouping"].SetCollisionGroup(char)
		serverModules["Spawning"].CharSpawning(plr, char)
		
		-- testing code below
		serverModules["CustomNameTags"].CreateNameTag(plr, char)
	end)

end)

local requestStageShift = CF.ReplicatedStorage:WaitForChild("RequestStageShift")
requestStageShift.OnServerEvent:Connect(function(plr, clientRequest)
	serverModules["StageShifting"].ShiftStage(plr, clientRequest)
end)

CF.MarketplaceService.ProcessReceipt = function(receiptInfo)
	serverModules["DevProductPurchases"].Purchase(receiptInfo)
end

game:BindToClose(serverModules["DataStoring"].EmergencySave)

print("FINALLY WORKING")