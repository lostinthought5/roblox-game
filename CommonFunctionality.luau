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
		["StartColor"] = Color3.fromRGB(255, 80, 83),
		["EndColor"] = Color3.fromRGB(255, 252, 161),
		["NameColor"] = Color3.fromRGB(255, 105, 107):ToHex(),
		["TextColor"] = Color3.fromRGB(255, 255, 255):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(255, 121, 130),
		["BubbleEndColor"] = Color3.fromRGB(199, 197, 125),
	},
	
	["ADMIN"] = {
		["StartColor"] = Color3.fromRGB(130, 255, 245), 
		["EndColor"] = Color3.fromRGB(130, 138, 255),
		["NameColor"] = Color3.fromRGB(187, 254, 255):ToHex(),
		["TextColor"] = Color3.fromRGB(255, 255, 255):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(158, 235, 229),
		["BubbleEndColor"] = Color3.fromRGB(130, 138, 255),
	},
	
	["DONOR"] = {
		["StartColor"] = false, 
		["EndColor"] = false,
		["NameColor"] = false,
		["TextColor"] = false,
		["BubbleColor"] = false,
	},
	
	["LEADERBOARD"] = {
		["StartColor"] = false, 
		["EndColor"] = false,
		["NameColor"] = false,
		["TextColor"] = false,
		["BubbleColor"] = false,
	},
	
	["BOT"] = {
		["StartColor"] = Color3.fromRGB(19, 154, 4), 
		["EndColor"] = Color3.fromRGB(19, 154, 4),
		["NameColor"] = Color3.fromRGB(19, 154, 4):ToHex(),
		["TextColor"] = Color3.fromRGB(140, 140, 140):ToHex(),
		["BubbleStartColor"] = Color3.fromRGB(19, 154, 4),
		["BubbleEndColor"] = Color3.fromRGB(102, 62, 12),
	}
}

CommonFunctionality.DevProducts = {
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

function CommonFunctionality.InitializeCheckpoints() -- must run twice if ran on both server and client
	local checkpoints = CommonFunctionality.CollectionService:GetTagged("Checkpoint")
	
	-- task.spawn() here?
	for i, checkpoint in checkpoints do
		registerCheckpoint(checkpoint)
	end
	
	CommonFunctionality.CollectionService:GetInstanceAddedSignal("Checkpoint"):Connect(registerCheckpoint) -- for client script
	
end

function CommonFunctionality.GradientEffect(plrTitle, startColor, endColor)
	local gradientText = ""
	local length = string.len(plrTitle)

	for i = 1, length do
		local letter = string.sub(plrTitle, i, i)
		local alpha = (i - 1) / (length - 1)

		local hexColor = startColor:Lerp(endColor, alpha):ToHex() -- lerp calculation returns a color here 
		gradientText = gradientText .. string.format("<font color='#%s'>%s</font>", hexColor, letter)	
	end

	return gradientText
end

return CommonFunctionality