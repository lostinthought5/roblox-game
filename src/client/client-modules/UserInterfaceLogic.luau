local UserInterfaceLogic = {}

local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local requestStageShift = CF.ReplicatedStorage:WaitForChild("RequestStageShift")
local VisualEffects = require(script.Parent.VisualEffects)
local localPlr = CF.Players.LocalPlayer

UserInterfaceLogic.PlrGui = localPlr:WaitForChild("PlayerGui")
local defaultGui = localPlr:WaitForChild("PlayerGui"):FindFirstChild("DefaultGui") or localPlr:WaitForChild("PlayerGui"):WaitForChild("DefaultGui") 
local settingsGui = localPlr:WaitForChild("PlayerGui"):WaitForChild("SettingsGui")
local shopGui = localPlr:WaitForChild("PlayerGui"):WaitForChild("ShopGui")

local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local settingsGuiFrame = settingsGui:WaitForChild("SettingsGuiFrame")
local shopGuiFrame = shopGui:WaitForChild("ShopGuiFrame")

local stageCounter = defaultGui:WaitForChild("StageCounterFrame")

local hideEnabled = false
local shiftLockEnabled = false

UserInterfaceLogic.ButtonLogic = { -- used to assign button functionality
	["DefaultGui"] = {
		["SettingsButton"] = function()
			defaultGui.Enabled = false
			settingsGui.Enabled = true
			settingsGuiFrame.Position = VisualEffects.GuiStartPosition -- this is to reset UI position, by default it is set to middle of the screen for editing 
			
			VisualEffects.GuiAnimationEffect(settingsGuiFrame, true)
		end,
		
		["ShopButton"] = function()
			-- may need tweaking, if client-side then perhaps hackers can get items easily
			defaultGui.Enabled = false
			shopGui.Enabled = true
			shopGuiFrame.Position = VisualEffects.GuiStartPosition
			
			VisualEffects.GuiAnimationEffect(shopGuiFrame, true)
		end,
		
		["NextButton"] = function()
			requestStageShift:FireServer("nextRequest")
		end,
		
		["PrevButton"] = function()
			requestStageShift:FireServer("prevRequest")
		end,
		
		["SkipButton"] = function() -- update so that can't be purchased if on last stage
			CF.MarketplaceService:PromptProductPurchase(localPlr, CF.DevProducts["SkipStageId"])
		end,
		
		["ShiftLock"] = function()
			shiftLockEnabled = not shiftLockEnabled
			VisualEffects.ShiftLock(shiftLockEnabled)
			
		end,
	},
	
	["SettingsGui"] = {
		["BackButton"] = function()
			VisualEffects.GuiAnimationEffect(settingsGuiFrame, false)
			
			settingsGui.Enabled = false
			defaultGui.Enabled = true
			
		end,
		
		["HidePlayersToggle"] = function(isEnabled)
			hideEnabled = isEnabled
			
			for _, plr in CF.Players:GetPlayers() do
				if plr ~= localPlr and plr.Character then
					VisualEffects.HidePlayer(plr.Character, hideEnabled)
				end
			end
		end,
		
	},
	
	["ShopGui"] = {
		["BackButton"] = function()
			VisualEffects.GuiAnimationEffect(shopGuiFrame, false)

			shopGui.Enabled = false
			defaultGui.Enabled = true
		end,
	},
}

function UserInterfaceLogic.DefaultUI(currentStage)
	stageCounter.StageText.Text = "Stage " .. CF.NumByCheckpoint[currentStage] -- could do this in a more specialized function instead
	stageCounter.StageText.ShadowText.Text = "Stage " .. CF.NumByCheckpoint[currentStage]	
end

-- will change following code

CF.Players.PlayerAdded:Connect(function(plr) -- to consider any subsequent players after localPlr
	plr.CharacterAdded:Connect(function(char)
		if hideEnabled then
			VisualEffects.HidePlayer(char, true)
		end
	end)
end)

for _, plr in CF.Players:GetPlayers() do
	if plr ~= localPlr then
		plr.CharacterAdded:Connect(function(char)
			if hideEnabled then
				VisualEffects.HidePlayer(char, true)
			end
		end)
	end
end

return UserInterfaceLogic
