--[[ This script is called by Main.client by the TextChatService callbacks.
It restyles a player's chat messages and bubbles based on their role's defined 
colors in the CommonFunctionality script. ]]

local ChatCustomization = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))

local chatLogic = {
	["ChatMessage"] = function(message, plrRole, colorData)
		local chatProperties = Instance.new("TextChatMessageProperties")
		local gradientRole = CF.GradientEffect(`[{plrRole}]`, colorData.RoleStartColor, colorData.RoleEndColor)
		
		-- PrefixText is the player's display name by default
		chatProperties.PrefixText = string.format("%s <font color='#%s'>%s</font>", gradientRole, colorData.NameColor, message.PrefixText)	
		chatProperties.Text = string.format("<font color='#%s'>%s</font>", colorData.TextColor, message.Text)
		
		return chatProperties	
	end,
	
	["TextBubble"] = function(message, plrRole, colorData)
		local bubbleProperties = Instance.new("BubbleChatMessageProperties")
		bubbleProperties.TextColor3 = Color3.fromHex(colorData.TextColor)
		bubbleProperties.BackgroundTransparency = 0
		bubbleProperties.FontFace = Font.fromEnum(Enum.Font.Kalam)
		bubbleProperties.Text = string.format("<b>%s</b>", message.Text)
		bubbleProperties.TextSize = 30
		
		local gradientUI = Instance.new("UIGradient")
		gradientUI.Color = ColorSequence.new(colorData.BubbleStartColor, colorData.BubbleEndColor)
		gradientUI.Parent = bubbleProperties
		gradientUI.Rotation = 90  -- makes the gradient run top to bottom
		
		return bubbleProperties
	end,
}

function ChatCustomization.Restructure(message, chatComponent)
	local success, restructured = pcall(function()  -- in case something is undefined
		local plr = CF.Players:GetPlayerByUserId(message.TextSource.UserId)
		local plrRole = plr:GetAttribute("Role")

		local colorData = CF.PlrRoles[plrRole]
		local logic = chatLogic[chatComponent]

		return logic(message, plrRole, colorData)

	end)

	if not success then return end
	
	return restructured
end

return ChatCustomization