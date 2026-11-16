local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
CF.InitializeCheckpoints()

local serverScriptService = game:GetService("ServerScriptService")

local serverModules = {}
local moduleFolder = serverScriptService:FindFirstChild("server-modules")

for _, module in moduleFolder:GetChildren() do
	serverModules[module.Name] = require(module)
end

serverModules.ServerComponents.Initialize()

CF.Players.PlayerAdded:Connect(function(plr)
	serverModules.DataStoring.LoadData(plr)
end)

CF.Players.PlayerRemoving:Connect(function(plr)
	serverModules.DataStoring.SaveData(plr)
end)

local triggerSpawning = CF.ServerStorage:WaitForChild("TriggerSpawning")
triggerSpawning.Event:Connect(function(plr)
	if plr.Character then
		serverModules.CollisionGrouping.SetCollisionGroup(plr.Character)
		serverModules.Spawning.SpawnCharacter(plr, plr.Character)
		serverModules.CustomNameTags.CreateNameTag(plr, plr.Character)

	end

	plr.CharacterAdded:Connect(function(char)
		serverModules.CollisionGrouping.SetCollisionGroup(char)
		serverModules.Spawning.SpawnCharacter(plr, char)
		
		serverModules.CustomNameTags.CreateNameTag(plr, char)
	end)

end)

local requestStageShift = CF.ReplicatedStorage:WaitForChild("RequestStageShift")
requestStageShift.OnServerEvent:Connect(function(plr, clientRequest)
	serverModules.StageShifting.ShiftStage(plr, clientRequest)
end)

CF.MarketplaceService.ProcessReceipt = function(receiptInfo)
	return serverModules.DevProductPurchases.Purchase(receiptInfo)
end

game:BindToClose(serverModules.DataStoring.EmergencySave)

local requestStageSkip = CF.ReplicatedStorage:WaitForChild("RequestStageSkip")
requestStageSkip.OnServerEvent:Connect(function(plr) 
	serverModules.DevProductPurchases.PromptSkipPurchase(plr)
end)