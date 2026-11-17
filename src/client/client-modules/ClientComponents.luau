--[[ This script is immediately called by Main.client. It defines universal logic
for client-side UI and client-based objects such as bounce pads. UI elements with
the ButtonUI tag are menu buttons, whereas those with ToggleUI are toggles in
the Settings GUI. UI-specific logic does not reside here, it resides in the
UserInterfaceLogic script. ]]

local ClientComponents = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local UILogic = require(script.Parent.UserInterfaceLogic)
local VisualEffects = require(script.Parent.VisualEffects)
local GameSounds = require(script.Parent.GameSounds)
local localPlr = CF.Players.LocalPlayer
local debounce = false

local componentLogic = {
	["ButtonUI"] = function(button)
		if not button:IsDescendantOf(UILogic.PlrGui) then return end
		if button.Name == "ShiftLock" and CF.UserInputService.KeyboardEnabled then 
			local shiftFrame = button.Parent.Parent
			local rightSideFrame = shiftFrame.Parent
			local skipFrame = rightSideFrame.SkipFrame

			shiftFrame:Destroy() -- done because keyboard users don't need the button
			
			rightSideFrame.Size = UDim2.new(rightSideFrame.Size.X,  -- halves the vertical sizing of the frame; also affects horizontal because of the aspect ratio
								UDim.new(rightSideFrame.Size.Y.Scale / 2, rightSideFrame.Size.Y.Offset))
			
			rightSideFrame.UIAspectRatioConstraint.AspectRatio *= 2 -- doubles the affected horizontal

			skipFrame.Size = UDim2.new(skipFrame.Size.X,  -- resets the skip frame back to its proper size
							UDim.new(skipFrame.Size.Y.Scale * 2, skipFrame.Size.Y.Offset))
			return
		end
		
		if button:IsA("ImageButton") then
			local buttonFrame = button.Parent
			local sideFrame = buttonFrame.Parent.Parent

			VisualEffects.PopEffect(button, buttonFrame, sideFrame)
		end
		
		button.MouseButton1Click:Connect(function()
			for guiName, logicTable in pairs(UILogic.ButtonLogic) do
				local gui = UILogic.PlrGui:FindFirstChild(guiName)
				
					if gui and button:IsDescendantOf(gui) then
						local buttonLogic = logicTable[button.Name]
						
						if buttonLogic then buttonLogic() end
					end
			end
		end)
	end,
	
	["ToggleUI"] = function(toggle)
		local knob = toggle:WaitForChild("Knob")
		local isEnabled = false
		
		local offColor = Color3.fromRGB(72, 63, 90)
		local onColor = Color3.fromRGB(174, 181, 245)
		local offPosition = UDim2.new(0.3, 0, 0.5, 0)
		local onPosition = UDim2.new(0.7, 0, 0.5, 0)
		local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		
		toggle.MouseButton1Click:Connect(function()
			isEnabled = not isEnabled
			
			local targetColor = isEnabled and onColor or offColor
			local targetPosition = isEnabled and onPosition or offPosition
			
			local toggleTween = CF.TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = targetColor})
			local knobTween = CF.TweenService:Create(knob, tweenInfo, {Position = targetPosition})
		
			toggleTween:Play()
			knobTween:Play()
			
			local settingToggles = UILogic.ButtonLogic.SettingsGui
			local toggleLogic = settingToggles[toggle.Name]

			if toggleLogic then toggleLogic(isEnabled) end
			
		end)
		
	end,
	
	["BouncePad"] = function(bouncePad)
		local alternateTypes = {
			["BouncePad2"] = 150,
		}
		
		local DEFAULT_DISPLACEMENT = 100
		local displacement = function()
			for padType, displacementAmount in alternateTypes do
				if bouncePad:HasTag(padType) then
					return alternateTypes[padType]
					
				end
			end
						
			return DEFAULT_DISPLACEMENT
		end
		
		displacement = displacement()
		local hitbox = bouncePad:WaitForChild("Hitbox")
		
		hitbox.Touched:Connect(function(touchingPart)
			local char = touchingPart.Parent
			local humanoid = char:FindFirstChild("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			local padSound = GameSounds.SoundEffects.BouncePadSound
			
			if char ~= localPlr.Character then return end  -- must be local plr specifically, will otherwise bug for others
			if humanoid and rootPart and not debounce then
				debounce = true
				GameSounds.PlaySoundEffect(padSound)
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				rootPart.AssemblyLinearVelocity = Vector3.new(rootPart.AssemblyLinearVelocity.X, displacement, rootPart.AssemblyLinearVelocity.Z)
				
				task.delay(0.5, function() debounce = false end)
			end
		end)
	end,
}

function ClientComponents.Initialize()
	for tag, logic in pairs(componentLogic) do 
		local components = CF.CollectionService:GetTagged(tag)

		for _, component in components do
			task.spawn(logic, component)  -- multithreads here
		end 

		CF.CollectionService:GetInstanceAddedSignal(tag):Connect(logic)
	end
end

return ClientComponents