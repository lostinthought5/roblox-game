--[[ This script is called from Main.server when a potential in-game
purchase occurs. It confirms the purchase is possible first. Enum decisions
NotProcessedYet and PurchaseGranted mean that a purchase went through but
is invalid (refunded after some time), and that it was successfully granted, 
respectively. ]]

local DevProductPurchases = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local DataStoring = require(script.Parent.DataStoring)
local Spawning = require(script.Parent.Spawning)

local purchaseLogic = {
	[CF.DevProducts.SkipStageId] = function(plr)
		local plrData = DataStoring.ReadData(plr)
		if not plrData then return Enum.ProductPurchaseDecision.NotProcessedYet end

		local furthestNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData.FurthestStage]]
		local nextCheckpoint = CF.CheckpointByNum[furthestNum + 1]
		if nextCheckpoint then
			DataStoring.UpdatePlrData(plr, nextCheckpoint.Name, nextCheckpoint.Name)
			Spawning.SpawnCharacter(plr, plr.Character)

			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end,
}

function DevProductPurchases.Purchase(receiptInfo)
	local plr = CF.Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not plr then return Enum.ProductPurchaseDecision.NotProcessedYet end  -- in case plr leaves before transaction
	
	local productLogic = purchaseLogic[receiptInfo.ProductId]
	if productLogic then 
		return productLogic(plr) 
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
end

function DevProductPurchases.PromptSkipPurchase(plr)
	local plrData = DataStoring.ReadData(plr)
		if not plrData then return end

		local furthestNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData.FurthestStage]]
		local nextCheckpoint = CF.CheckpointByNum[furthestNum + 1]

		if not nextCheckpoint then return end  -- crucial so that players may not purchase if on last stage
		
		CF.MarketplaceService:PromptProductPurchase(plr, CF.DevProducts.SkipStageId)  -- prompts the actual purchase
end

return DevProductPurchases
