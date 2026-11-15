local CollisionGrouping = {}

function CollisionGrouping.SetCollisionGroup(model)
	-- this assumes argument is a model, must alter for when argument is else
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
