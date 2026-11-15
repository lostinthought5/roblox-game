local EncodingService = game:GetService("EncodingService")
local VisualEffects = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local GameSounds = require(script.Parent.GameSounds)
local currentCam = workspace.CurrentCamera
local localPlr = CF.Players.LocalPlayer

local blurEffect = game:GetService("Lighting"):WaitForChild("BlurEffect")
local cameraOffset = Instance.new("Vector3Value")

VisualEffects.GuiStartPosition = UDim2.new(-0.5 ,0 ,0.5 ,0)
VisualEffects.GuiEndPosition = UDim2.new(0.5, 0, 0.5, 0)

local animationInfo = {
	["Default"] = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["Fov"] = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["ShiftLock"] = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["GradientUI"] = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0),
}

local screenAnimations = {
	["GuiAnimation"] = function(frameUI, screenPosition)
		return CF.TweenService:Create(frameUI, animationInfo["Default"], {Position = screenPosition})
	end,

	["GradientAnimation"] = function(gradientUI)
		return CF.TweenService:Create(gradientUI, animationInfo["GradientUI"], {Rotation = 360})
	end,
	
	["BlurAnimation"] = function(blurSize)
		return CF.TweenService:Create(blurEffect, animationInfo["Default"], {Size = blurSize})
	end,
	
	["FovAnimation"] = function(fovSize)
		return CF.TweenService:Create(currentCam, animationInfo["Fov"], {FieldOfView = fovSize})
	end,
	
	["ShiftLockAnimation"] = function(vectorValue)
		return CF.TweenService:Create(cameraOffset, animationInfo["ShiftLock"], {Value = vectorValue})
	end,
}

local previousPoint
function VisualEffects.CheckpointLightToggle(checkpoint)
	local currentPoint = checkpoint
	if previousPoint then
		previousPoint.Spawner.Color = Color3.fromRGB(48, 48, 48)
	end

	checkpoint.Spawner.Color = Color3.fromRGB(189, 101, 174)
	GameSounds.PlaySoundEffect(GameSounds.SoundEffects.CheckpointSound)
	previousPoint = currentPoint

end

function VisualEffects.PopEffect(button, parentUI)
	local function scale(scaleUp)
		local scaleUI = parentUI:FindFirstChild("UIScale")
		local hoverSound = GameSounds.SoundEffects.ButtonHoverSound
		if not scaleUI then return end
		
		scaleUI.Scale = scaleUp and 1.15 or 1
		if scaleUI.Scale ~= 1 then GameSounds.PlaySoundEffect(hoverSound) end
	end
		
	button.MouseEnter:Connect(function() scale(true) end)
	button.MouseLeave:Connect(function() scale(false) end)
	button.MouseButton1Click:Connect(function() scale(false) end)
end

function VisualEffects.GuiAnimationEffect(frameUI, moveInward)
	local guiPosition = moveInward and VisualEffects.GuiEndPosition or VisualEffects.GuiStartPosition
	local blurSize = moveInward and 24 or 0 
	local fovSize = moveInward and 60 or 70
	
	local guiAnimation = screenAnimations["GuiAnimation"](frameUI, guiPosition)
	local blurAnimation = screenAnimations["BlurAnimation"](blurSize)
	local fovAnimation = screenAnimations["FovAnimation"](fovSize)
	
	guiAnimation:Play()
	blurAnimation:Play() 
	fovAnimation:Play()
	fovAnimation.Completed:Wait()

	local backgroundUI = frameUI:FindFirstChild("SettingsFrame") or frameUI:FindFirstChild("ShopFrame")
	local gradientUI = backgroundUI:FindFirstChild("UIStroke"):FindFirstChild("UIGradient")
	local gradientAnimation = screenAnimations["GradientAnimation"](gradientUI)

	if not moveInward then
		gradientAnimation:Cancel()
		gradientUI.Rotation = 0

		return
	end

	-- breaks once function is called more than once, need to fix
	gradientAnimation:Play()
end

function VisualEffects.HidePlayer(char, isEnabled)
	local function hideCharDescendants(object)
		if object:IsA("BasePart") then	
			object.LocalTransparencyModifier = isEnabled and 1 or 0
			
			local nameTag = object:FindFirstChild("CustomNameTag")
			if nameTag then nameTag.Enabled = not isEnabled end

		elseif object:IsA("Decal") then -- decals don't have the modifier
			object.Transparency = isEnabled and 1 or 0
		end
	end
	
	for _, object in char:GetDescendants() do
		hideCharDescendants(object)
	end
	
	char.DescendantAdded:Connect(function(object)
		hideCharDescendants(object)
	end)
end

VisualEffects.LockActive = false
function VisualEffects.ShiftLock(shiftLockEnabled)
	local function lock(rootPart, humanoid)
		local function updateCam()
			if not rootPart or not rootPart.Parent or humanoid.Health <= 0 then
				CF.RunService:UnbindFromRenderStep("UpdateCamera")
				return
			end
			
			local currentHeadPos = rootPart.Position + Vector3.new(0, 1.5, 0)
			currentCam.CFrame = CFrame.new(currentHeadPos) * currentCam.CFrame.Rotation * CFrame.new(cameraOffset.Value)			
			
			if VisualEffects.LockActive then
				local camLook = currentCam.CFrame.LookVector
				local flatLook = Vector3.new(camLook.X, 0, camLook.Z) -- to maintain a strictly horizontal view
				
				if flatLook.Magnitude > 0.001 then -- to prevent a math logic crash
					rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLook)
				end

			else
				local distanceToTarget = (cameraOffset.Value - Vector3.new(0, 0, 12)).Magnitude
				if distanceToTarget < 0.1 then
					CF.RunService:UnbindFromRenderStep("UpdateCamera")
					cameraOffset.Value = Vector3.zero -- Reset for the next toggle
					return	
				end
			end
		end
		
		CF.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		CF.UserInputService.MouseIconEnabled = false -- hides cursor
		humanoid.AutoRotate = false  -- property forces char to face direction they walk towards
		
		local headHeight = rootPart.Position + Vector3.new(0, 1.5, 0)
		localPlr.CameraMinZoomDistance = 2
		
		local camDistance = (currentCam.CFrame.Position - headHeight).Magnitude
		cameraOffset.Value = Vector3.new(0, 0, camDistance)
		
		local shiftAnimation = screenAnimations["ShiftLockAnimation"](Vector3.new(1.75, 0, 10))
		shiftAnimation:Play()
		
		local priority = Enum.RenderPriority.Camera.Value + 1
		CF.RunService:BindToRenderStep("UpdateCamera", priority, updateCam)
	end
	
	local function unlock(humanoid)
		CF.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		CF.UserInputService.MouseIconEnabled = true
		humanoid.AutoRotate = true
		
		-- Force Roblox's own zoom memory to match 12 studs as needed
		localPlr.CameraMinZoomDistance = 12
		localPlr.CameraMaxZoomDistance = 12

		-- Unlock the zoom after the tween finishes
		task.delay(0.25, function()
			localPlr.CameraMinZoomDistance = 0.5
			localPlr.CameraMaxZoomDistance = 25
		end)

		-- Tween to a fixed Default position
		local shiftAnimation = screenAnimations["ShiftLockAnimation"](Vector3.new(0, 0, 12))
		shiftAnimation:Play()
	end
	
	local char = localPlr.Character
	local humanoid = char and char:FindFirstChild("Humanoid")
	local rootPart = char and char:FindFirstChild("HumanoidRootPart")
	if not humanoid or not rootPart then return end
	
	VisualEffects.LockActive = shiftLockEnabled
	if shiftLockEnabled then lock(rootPart, humanoid) else unlock(humanoid) end
	
end

return VisualEffects