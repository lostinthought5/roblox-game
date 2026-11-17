--[[ This script is called from Main.client when the Shift key is pressed and
to highlight current checkpoints, from the ClientComponents script when 
from ClientComponents to assign the PopEffect function to UI buttons, and from
the UserInterfaceLogic script for all other functions. 

It handles the GUI open/close animations and their animated border gradient, 
checkpoint lighting and player hiding, and the custom shift lock feature, which 
locks the player's camera to their mouse. ]]

local VisualEffects = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local GameSounds = require(script.Parent.GameSounds)
local currentCam = workspace.CurrentCamera
local localPlr = CF.Players.LocalPlayer

local blurEffect = game:GetService("Lighting"):WaitForChild("BlurEffect")
local cameraOffset = Instance.new("Vector3Value") -- reference to be animated in shift locking

VisualEffects.GuiStartPosition = UDim2.new(-0.5 ,0 ,0.5 ,0)
VisualEffects.GuiEndPosition = UDim2.new(0.5, 0, 0.5, 0)

local animationInfo = {
	["Default"] = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["Fov"] = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["ShiftLock"] = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	["GradientUI"] = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false, 0), -- the -1 loops the animation
}

local screenAnimations = {
	["GuiAnimation"] = function(frameUI, screenPosition)
		return CF.TweenService:Create(frameUI, animationInfo.Default, {Position = screenPosition})
	end,

	["GradientAnimation"] = function(gradientUI)
		return CF.TweenService:Create(gradientUI, animationInfo.GradientUI, {Rotation = 360})
	end,
	
	["BlurAnimation"] = function(blurSize)
		return CF.TweenService:Create(blurEffect, animationInfo.Default, {Size = blurSize})
	end,
	
	["FovAnimation"] = function(fovSize)
		return CF.TweenService:Create(currentCam, animationInfo.Fov, {FieldOfView = fovSize})
	end,
	
	["ShiftLockAnimation"] = function(vectorValue)
		return CF.TweenService:Create(cameraOffset, animationInfo.ShiftLock, {Value = vectorValue})
	end,
}

local previousPoint
function VisualEffects.HighlightCheckpoint(checkpoint)
	local currentPoint = checkpoint
	if previousPoint then
		previousPoint.Spawner.Color = Color3.fromRGB(48, 48, 48)
	end

	checkpoint.Spawner.Color = Color3.fromRGB(189, 101, 174)
	GameSounds.PlaySoundEffect(GameSounds.SoundEffects.CheckpointSound)
	previousPoint = currentPoint

end

function VisualEffects.PopEffect(button, buttonFrame, sideFrame)
	local function scale(scaleUp)
		local buttonFrameScale = buttonFrame:FindFirstChild("UIScale")
		local sideFrameScale = sideFrame:FindFirstChild("UIScale")
		local hoverSound = GameSounds.SoundEffects.ButtonHoverSound
		if not buttonFrameScale and not sideFrameScale then return end

		local DEFAULT_SCALE_VALUE = 1 
		
		buttonFrameScale.Scale = scaleUp and 1.15 or DEFAULT_SCALE_VALUE
		sideFrameScale.Scale = scaleUp and 1.05 or DEFAULT_SCALE_VALUE
		if buttonFrameScale.Scale ~= DEFAULT_SCALE_VALUE then GameSounds.PlaySoundEffect(hoverSound) end
	end
		
	button.MouseEnter:Connect(function() scale(true) end)
	button.MouseLeave:Connect(function() scale(false) end)
	button.MouseButton1Click:Connect(function() scale(false) end)
end

function VisualEffects.GuiAnimationEffect(frameUI, moveInward)
	local guiPosition = moveInward and VisualEffects.GuiEndPosition or VisualEffects.GuiStartPosition
	local DEFAULT_BLUR_SIZE = 0
	local DEFAULT_FOV_SIZE = 70

	local blurSize = moveInward and 24 or DEFAULT_BLUR_SIZE
	local fovSize = moveInward and 60 or DEFAULT_FOV_SIZE
	
	local guiAnimation = screenAnimations.GuiAnimation(frameUI, guiPosition)
	local blurAnimation = screenAnimations.BlurAnimation(blurSize)
	local fovAnimation = screenAnimations.FovAnimation(fovSize)
	
	guiAnimation:Play()
	blurAnimation:Play() 
	fovAnimation:Play()
	fovAnimation.Completed:Wait()

	local backgroundUI = frameUI:FindFirstChild("SettingsFrame") or frameUI:FindFirstChild("ShopFrame")
	local gradientUI = backgroundUI:FindFirstChild("UIStroke"):FindFirstChild("UIGradient")
	local gradientAnimation = screenAnimations.GradientAnimation(gradientUI)

	if not moveInward then
		gradientAnimation:Cancel()
		gradientUI.Rotation = 0

		return
	end

	gradientAnimation:Play()
end

function VisualEffects.HidePlayer(char, isEnabled)
	local function hideCharDescendants(object)
		local DEFAULT_TRANSPARENCY = 0
		if object:IsA("BasePart") then	
			object.LocalTransparencyModifier = isEnabled and 1 or DEFAULT_TRANSPARENCY
			
			local nameTag = object:FindFirstChild("CustomNameTag")
			if nameTag then nameTag.Enabled = not isEnabled end

		elseif object:IsA("Decal") then  -- done because decals don't have the modifier
			object.Transparency = isEnabled and 1 or DEFAULT_TRANSPARENCY
		end
	end
	
	for _, object in char:GetDescendants() do
		hideCharDescendants(object)
	end
	
	char.DescendantAdded:Connect(function(object)
		hideCharDescendants(object)
	end)
end

VisualEffects.LockActive = false -- this is to tell Main.client if shift lock should be applied on character respawn
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
				local flatLook = Vector3.new(camLook.X, 0, camLook.Z)  -- to maintain a strictly horizontal view
				
				if flatLook.Magnitude > 0.001 then  -- to prevent a math logic crash
					rootPart.CFrame = CFrame.lookAt(rootPart.Position, rootPart.Position + flatLook)
				end

			else  -- begins unlocking 
				-- render step runs until the offset tween reaches the default (0, 0, 12),
				local distanceToTarget = (cameraOffset.Value - Vector3.new(0, 0, 12)).Magnitude
				if distanceToTarget < 0.1 then
					CF.RunService:UnbindFromRenderStep("UpdateCamera")
					cameraOffset.Value = Vector3.zero  -- reset for the next shift toggle
					return	
				end
			end
		end
		
		CF.UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
		CF.UserInputService.MouseIconEnabled = false
		humanoid.AutoRotate = false  -- property forces char to face direction they walk towards; true by default
		
		local headHeight = rootPart.Position + Vector3.new(0, 1.5, 0)
		localPlr.CameraMinZoomDistance = 2
		
		local camDistance = (currentCam.CFrame.Position - headHeight).Magnitude  -- constant
		cameraOffset.Value = Vector3.new(0, 0, camDistance)
		
		local shiftAnimation = screenAnimations.ShiftLockAnimation(Vector3.new(1.75, 0, 10))
		shiftAnimation:Play()
		
		local priority = Enum.RenderPriority.Camera.Value + 1  -- to ovveride engine
		CF.RunService:BindToRenderStep("UpdateCamera", priority, updateCam) -- calls updateCam at every rendered frame
	end
	
	local function unlock(humanoid)
		CF.UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		CF.UserInputService.MouseIconEnabled = true
		humanoid.AutoRotate = true
		
		-- forces max and min zooming to 12 studs; restored after 0.25 secs
		localPlr.CameraMinZoomDistance = 12
		localPlr.CameraMaxZoomDistance = 12

		-- resets after tween below finishes playing
		task.delay(0.25, function()
			localPlr.CameraMinZoomDistance = 0.5
			localPlr.CameraMaxZoomDistance = 25
		end)

		-- tween to a fixed Default position
		local shiftAnimation = screenAnimations.ShiftLockAnimation(Vector3.new(0, 0, 12))
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