local TouchInputService = game:GetService("TouchInputService")
local ServerComponents = {}

local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local DS = require(script.Parent.DataStoring)
local sendCurrentStage = CF.ReplicatedStorage:WaitForChild("SendCurrentStage")
local sendVisualUpdate = CF.ReplicatedStorage:WaitForChild("SendVisualUpdate")

local plrsPrevPoints = {}

local componentLogic = {
	["Checkpoint"] = function(checkpoint)
		checkpoint.Hitbox.Touched:Connect(function(touchingPart)
			local char = touchingPart.Parent
			local plr = CF.Players:GetPlayerFromCharacter(char)
			if not plr then return end
			
			local plrData = DS.ReadData(plr)
			if not plrData then return end
			
			local currentPoint = checkpoint
			if plrsPrevPoints[plr.UserId] == currentPoint then return end
			plrsPrevPoints[plr.UserId] = currentPoint
			
			local currentNum = CF.NumByCheckpoint[checkpoint]
			local furthestNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData["FurthestStage"]]]
			
			if currentNum > furthestNum then
				DS.UpdatePlrData(plr, checkpoint.Name)
			end
			
			DS.UpdatePlrData(plr, nil, checkpoint.Name)
			sendCurrentStage:FireClient(plr, checkpoint)
			sendVisualUpdate:FireClient(plr, checkpoint)
			
		end)
	end,
	
	["KillBrick"] = function(killBrick)
		killBrick.Touched:Connect(function(touchingPart)
			local char = touchingPart.Parent
			local humanoid = char:FindFirstChild("Humanoid")
			if humanoid then humanoid.Health = 0 end
			
		end)
	end,
	
	["MovingPlatform"] = function(platformModel)
		local platformTypes = {
			["SlowPlatform"] = {15, 1},
		}

		local platformValues = function()
			for platformType, values in platformTypes do
				if platformModel:HasTag(platformType) then
					return values
				end
			end

			return {20, 0.5} -- default values
		end

		platformValues = platformValues()
		local studsPerSec, waitTime = platformValues[1], platformValues[2]

		local platform = platformModel:FindFirstChild("Platform")
		local waypoint = platformModel:FindFirstChild("Waypoint")
		if not platform or not waypoint then return end

		local startCFrame = platform.CFrame
		local endCFrame = waypoint.CFrame
		local distanceVector = endCFrame.Position - startCFrame.Position

		local travelTime = distanceVector.Magnitude / studsPerSec -- in seconds

		-- velocity vector needed to travel through that distance vector in that time frame
		local forwardVelocity = distanceVector / travelTime
		local backwardVelocity = -forwardVelocity

		local tweenInfo = TweenInfo.new(travelTime, Enum.EasingStyle.Linear)
		local forwardTween = CF.TweenService:Create(platform, tweenInfo, {CFrame = endCFrame})
		local backwardTween = CF.TweenService:Create(platform, tweenInfo, {CFrame = startCFrame})
		
		task.spawn(function()
			while true do
				local function movePlatform(moveForward)
					platform.AssemblyLinearVelocity = moveForward and forwardVelocity or backwardVelocity
					local tween = moveForward and forwardTween or backwardTween
					tween:Play()
					tween.Completed:Wait()
					
					platform.AssemblyLinearVelocity = Vector3.zero
					task.wait(waitTime)
				end
				
				movePlatform(true)
				movePlatform(false)
				
			end
		end)
	end,
} 

function ServerComponents.Initialize()
	for tag, logic in pairs(componentLogic) do 
		local components = CF.CollectionService:GetTagged(tag)
		
		for _, component in components do -- should be O(n)
			task.spawn(logic, component)
		end 
		
		CF.CollectionService:GetInstanceAddedSignal(tag):Connect(logic)
	end
	
	-- following is to prevent excessive memory use
	CF.Players.PlayerRemoving:Connect(function(plr)
		plrsPrevPoints[plr.UserId] = nil
	end)
end

return ServerComponents
