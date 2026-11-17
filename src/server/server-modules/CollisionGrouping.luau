--[[ This script is called by Main.server when a player joins. It prevents
players from being collidable to each other by assigning a custom collision
group made in the engine to each of their character's parts. ]]

local CollisionGrouping = {}

function CollisionGrouping.SetCollisionGroup(model)
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end
	
	model.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			part.CollisionGroup = "Players"
		end
	end)
end

return CollisionGrouping
