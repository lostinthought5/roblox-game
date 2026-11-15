local CustomNameTags = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))

function CustomNameTags.CreateNameTag(plr, char)
	local humanoid = char:WaitForChild("Humanoid")
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None -- disables default engine nametag

	local head = char:WaitForChild("Head")
	local rootPart = char:WaitForChild("HumanoidRootPart")
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "CustomNameTag"
	billboard.Size = UDim2.new(0, 200, 0, 40)
	
	local mag = (head.CFrame.Position - rootPart.CFrame.Position).Magnitude 
	
	billboard.StudsOffset = Vector3.new(0, mag + 1.75, 0) -- Hovers slightly above the head
	billboard.Adornee = rootPart -- not head to prevent GUI movement
	billboard.MaxDistance = 20
	billboard.Parent = rootPart
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.RichText = true
	textLabel.TextScaled = true
	textLabel.Font = Enum.Font.Kalam
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.Parent = billboard
	
	local plrRole = plr:GetAttribute("Role")
	if plrRole and CF.PlrRoles[plrRole] then
		local colorData = CF.PlrRoles[plrRole]
		
		local gradientRole = CF.GradientEffect(`[{plrRole}]`, colorData["StartColor"], colorData["EndColor"])
		textLabel.Text = string.format("<b>%s <font color='#%s'>%s</font></b>", gradientRole, colorData["NameColor"], plr.DisplayName)
	else	
		textLabel.Text = plr.DisplayName
	end	
end

return CustomNameTags
