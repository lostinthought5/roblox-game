-- below disables default health bar GUI
game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local localPlr = game:GetService("Players").LocalPlayer
CF.InitializeCheckpoints()

local clientModules = {}
local moduleFolder = localPlr.PlayerScripts:FindFirstChild("ClientScripts"):FindFirstChild("Modules")

for _, module in moduleFolder:GetChildren() do
	clientModules[module.Name] = require(module)	
end

clientModules["ClientComponents"].Initialize()

local sendVisualUpdate = CF.ReplicatedStorage:WaitForChild("SendVisualUpdate")
sendVisualUpdate.OnClientEvent:Connect(function(checkpoint)
	clientModules["VisualEffects"].CheckpointLightToggle(checkpoint)
end)

CF.TextChatService.OnIncomingMessage = function(message) -- engine callback
	return clientModules["ChatCustomization"].Restructure(message, "ChatMessage")
end

CF.TextChatService.OnBubbleAdded = function(message)
	return clientModules["ChatCustomization"].Restructure(message, "TextBubble")
end

local sendCurrentStage = CF.ReplicatedStorage:WaitForChild("SendCurrentStage")
sendCurrentStage.OnClientEvent:Connect(function(currentStage)
	clientModules["UserInterfaceLogic"].DefaultUI(currentStage) -- could use a more specialized function instead
end)

local shiftLockEnabled = false
CF.UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == Enum.KeyCode.LeftShift then
		shiftLockEnabled = not shiftLockEnabled
		clientModules["VisualEffects"].ShiftLock(shiftLockEnabled)
		
	end
end)

CF.Players.LocalPlayer.CharacterAdded:Connect(function(char) -- handles respawn bug for shift lock, should probably move
	if clientModules["VisualEffects"].LockActive then
		char:WaitForChild("Humanoid")
		char:WaitForChild("HumanoidRootPart")

		clientModules["VisualEffects"].ShiftLock(true)
	end
end)