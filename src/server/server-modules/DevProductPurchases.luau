local DevProductPurchases = {}
local CF = require(game:GetService("ReplicatedStorage"):WaitForChild("CommonFunctionality"))
local DataStoring = require(script.Parent.DataStoring)
local Spawning = require(script.Parent.Spawning)

local purchaseLogic = {
	[CF.DevProducts["SkipStageId"]] = function(plr)
		local plrData = DataStoring.ReadData(plr)
		if not plrData then return Enum.ProductPurchaseDecision.NotProcessedYet end

		local furthestNum = CF.NumByCheckpoint[CF.CheckpointByName[plrData["FurthestStage"]]]
		local nextCheckpoint = CF.CheckpointByNum[furthestNum + 1]
		if nextCheckpoint then
			DataStoring.UpdatePlrData(plr, nextCheckpoint.Name, nextCheckpoint.Name)
			Spawning.CharSpawning(plr, plr.Character)

			return Enum.ProductPurchaseDecision.PurchaseGranted
		else
			print("transaction not handled") -- could add a server text messege here instead 
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
	end,
}

function DevProductPurchases.Purchase(receiptInfo)
	local plr = CF.Players:GetPlayerByUserId(receiptInfo["PlayerId"])
	if not plr then return Enum.ProductPurchaseDecision.NotProcessedYet end -- in case plr leaves before transaction
	
	local productLogic = purchaseLogic[receiptInfo["ProductId"]]
	if productLogic then 
		return productLogic(plr) 
	else
		warn("product nonexistent")
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	
end

return DevProductPurchases
