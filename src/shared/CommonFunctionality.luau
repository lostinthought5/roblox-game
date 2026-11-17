--[[ This script is called from both the server and client scripts. It
defines variables and logic that is used often across different scripts,
most notably the hashmaps CheckpointByName, CheckpointByNum, and
NumByCheckpoint. The client and server both store their own copy of this 
script. ]]

local CommonFunctionality = {}

CommonFunctionality.TweenService = game:GetService("TweenService")
CommonFunctionality.TextChatService = game:GetService("TextChatService")
CommonFunctionality.CollectionService = game:GetService("CollectionService")
CommonFunctionality.MarketplaceService = game:GetService("MarketplaceService")
CommonFunctionality.UserInputService = game:GetService("UserInputService")
CommonFunctionality.RunService = game:GetService("RunService")

CommonFunctionality.ReplicatedStorage = game:GetService("ReplicatedStorage")
CommonFunctionality.ServerStorage = game:GetService("ServerStorage")
CommonFunctionality.Players = game:GetService("Players")

CommonFunctionality.PlrRoles = {
	["OWNER"] = {
		["RoleStartColor"] = Color3.fromRGB(255, 80, 83),
		["RoleEndColor"] = Color3.fromRGB(255, 252, 161),
		["NameColor"] = Color3.fromRGB(255, 105, 107):ToHex(),
		["TextColor"] = Color3.fromRGB(255, 255, 255):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(255, 121, 130),
		["BubbleEndColor"] = Color3.fromRGB(199, 197, 125),
	},
	
	["ADMIN"] = {
		["RoleStartColor"] = Color3.fromRGB(130, 255, 245), 
		["RoleEndColor"] = Color3.fromRGB(130, 138, 255),
		["NameColor"] = Color3.fromRGB(187, 254, 255):ToHex(),
		["TextColor"] = Color3.fromRGB(255, 255, 255):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(158, 235, 229),
		["BubbleEndColor"] = Color3.fromRGB(130, 138, 255),
	},
	
	-- following two are unimplemented 

	["DONOR"] = {
		["RoleStartColor"] = false, 
		["RoleEndColor"] = false,
		["NameColor"] = false,
		["TextColor"] = false,
		["BubbleColor"] = false,
	},
	
	["LEADERBOARD"] = {
		["RoleStartColor"] = false, 
		["RoleEndColor"] = false,
		["NameColor"] = false,
		["TextColor"] = false,
		["BubbleColor"] = false,
	},
	
	["GUEST"] = {
		["RoleStartColor"] = Color3.fromRGB(144, 131, 196),
		["RoleEndColor"] = Color3.fromRGB(144, 131, 196),
		["NameColor"] = Color3.fromRGB(253, 253, 253):ToHex(),
		["TextColor"] = Color3.fromRGB(189, 189, 189):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(27, 22, 29),
		["BubbleEndColor"] = Color3.fromRGB(27, 22, 29),
	}
}

CommonFunctionality.DevProducts = {  -- these are in-game purchasables 
	["SkipStageId"] = 3611264810, 
}

CommonFunctionality.CheckpointByName = {}
CommonFunctionality.CheckpointByNum = {}
CommonFunctionality.NumByCheckpoint = {}

local function registerCheckpoint(checkpoint)
	local stageNum = tonumber(string.match(checkpoint.Name, "%d+"))

	if stageNum then
		CommonFunctionality.CheckpointByName[checkpoint.Name] = checkpoint
		CommonFunctionality.CheckpointByNum[stageNum] = checkpoint
		CommonFunctionality.NumByCheckpoint[checkpoint] = stageNum

	end
end

function CommonFunctionality.InitializeCheckpoints()
	local checkpoints = CommonFunctionality.CollectionService:GetTagged("Checkpoint")
	
	for i, checkpoint in checkpoints do
		registerCheckpoint(checkpoint)
	end
	
	CommonFunctionality.CollectionService:GetInstanceAddedSignal("Checkpoint"):Connect(registerCheckpoint)  -- for client script
	
end

function CommonFunctionality.GradientEffect(plrTitle, startColor, endColor)
	local gradientText = ""
	local length = string.len(plrTitle)

	for i = 1, length do
		local letter = string.sub(plrTitle, i, i)
		local alpha = (i - 1) / (length - 1)  -- this is a in the linear interpolation formula

		local hexColor = startColor:Lerp(endColor, alpha):ToHex()
		gradientText = gradientText .. string.format("<font color='#%s'>%s</font>", hexColor, letter)	
	end

	return gradientText
end

return CommonFunctionality