--[[ This script acts as the main client, calling module scripts from 
client-modules/ when needed. It mostly handles visuals and UI, though it
contains some logic related to the ShiftLock function in the VisualEffects
script. It also calls the CommonFunctionality script like its counterpart
Main.server ]]

-- below disables default health bar GUI
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local localPlr = game:GetService("Players").LocalPlayer
CF.InitializeCheckpoints()

local clientModules = {}
local moduleFolder = localPlr.PlayerScripts:FindFirstChild("client-modules")

for _, module in moduleFolder:GetChildren() do
	clientModules[module.Name] = require(module)	
end

clientModules.ClientComponents.Initialize()

local sendVisualUpdate = CF.ReplicatedStorage:WaitForChild("SendVisualUpdate")
sendVisualUpdate.OnClientEvent:Connect(function(checkpoint)
	clientModules.VisualEffects.HighlightCheckpoint(checkpoint)
end)

-- engine callback which displays returned value in-chat
CF.TextChatService.OnIncomingMessage = function(message)
	return clientModules.ChatCustomization.Restructure(message, "ChatMessage")
end

-- engine callback which displays a text bubble above a player's head
CF.TextChatService.OnBubbleAdded = function(message)
	return clientModules.ChatCustomization.Restructure(message, "TextBubble")
end

local sendCurrentStage = CF.ReplicatedStorage:WaitForChild("SendCurrentStage")
sendCurrentStage.OnClientEvent:Connect(function(currentStage)
	clientModules.UserInterfaceLogic.UpdateStageCounter(currentStage)
end)

local shiftLockEnabled = false
CF.UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockEnabled = not shiftLockEnabled
		clientModules.VisualEffects.ShiftLock(shiftLockEnabled)
		
	end
end)

CF.Players.LocalPlayer.CharacterAdded:Connect(function(char)  -- forces shift lock to remain on upon death
	if clientModules.VisualEffects.LockActive then
		char:WaitForChild("Humanoid")
		char:WaitForChild("HumanoidRootPart")

		clientModules.VisualEffects.ShiftLock(true)
	end
end)