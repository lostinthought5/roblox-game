local ClientComponents = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local UILogic = require(script.Parent.UserInterfaceLogic)
local VE = require(script.Parent.VisualEffects)
local GameSounds = require(script.Parent.GameSounds)
local localPlr = CF.Players.LocalPlayer
local debounce = false

local componentLogic = {
	["ButtonUI"] = function(button)
		if not button:IsDescendantOf(UILogic.PlrGui) then return end
		if button.Name == "ShiftLock" and CF.UserInputService.KeyboardEnabled then
			button.Parent.Parent:Destroy()
			
			return
		end
		
		if button:IsA("ImageButton") then
			VE.PopEffect(button, button.Parent)
		end
		
		button.MouseButton1Click:Connect(function()
			for guiName, logicTable in pairs(UILogic.ButtonLogic) do
				local gui = UILogic.PlrGui:FindFirstChild(guiName)
				
					if gui and button:IsDescendantOf(gui) then
						local buttonLogic = logicTable[button.Name]
						
						if buttonLogic then
							buttonLogic()
						else
							warn("undefined functionality")
						end
						
						break
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
			
			-- following function as ternary operators; logic trick
			local targetColor = isEnabled and onColor or offColor
			local targetPosition = isEnabled and onPosition or offPosition
			
			local toggleTween = CF.TweenService:Create(toggle, tweenInfo, {BackgroundColor3 = targetColor})
			local knobTween = CF.TweenService:Create(knob, tweenInfo, {Position = targetPosition})
		
			toggleTween:Play()
			knobTween:Play()
			
			local settingToggles = UILogic.ButtonLogic["SettingsGui"]
			local toggleLogic = settingToggles[toggle.Name]
			-- might need to change later
			if toggleLogic then toggleLogic(isEnabled) end
			
		end)
		
	end,
	
	["BouncePad"] = function(bouncePad)
		local alternateTypes = {
			["BouncePad2"] = 150,
		}
		
		local displacement = function()
			for padType, displacementAmount in alternateTypes do
				if bouncePad:HasTag(padType) then
					return alternateTypes[padType]
					
				end
			end
						
			return 100 -- default
		end
		
		displacement = displacement()
		local hitbox = bouncePad:WaitForChild("Hitbox")
		
		hitbox.Touched:Connect(function(touchingPart)
			local char = touchingPart.Parent
			local humanoid = char:FindFirstChild("Humanoid")
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			local padSound = GameSounds.SoundEffects.BouncePadSound
			
			if char ~= localPlr.Character then return end -- must be local plr specifically, will otherwise bug for others
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

		for _, component in components do -- should be O(n)
			task.spawn(logic, component)
		end 

		CF.CollectionService:GetInstanceAddedSignal(tag):Connect(logic)
	end
end

return ClientComponents