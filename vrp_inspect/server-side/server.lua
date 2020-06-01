-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
-----------------------------------------------------------------------------------------------------------------------------------------
cRP = {}
Tunnel.bindInterface("vrp_inspect",cRP)
vCLIENT = Tunnel.getInterface("vrp_inspect")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local opened = {}
-----------------------------------------------------------------------------------------------------------------------------------------
-- /INSPECT
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("inspect",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		local nplayer = vRPclient.nearestPlayer(source,1)
		if nplayer then
			local nuser_id = vRP.getUserId(nplayer)
			if not vRP.hasPermission(nuser_id,"Police") then
				local nsource = vRP.getUserSource(parseInt(nuser_id))
				if vRP.hasPermission(user_id,"Police") then
					vRPclient._playAnim(source,true,{"oddjobs@shop_robbery@rob_till","loop"},true)
					vRPclient._playAnim(nplayer,true,{"random@arrests@busted","idle_a"},true)
					vCLIENT.toggleCarry(nplayer,source)

					TriggerClientEvent("cancelando",nplayer,true)

					local weapons = vRPclient.replaceWeapons(nsource,{})
					for k,v in pairs(weapons) do
						vRP.giveInventoryItem(parseInt(nuser_id),"wbody|"..k,1)
						if parseInt(v.ammo) > 0 then
							vRP.giveInventoryItem(parseInt(nuser_id),"wammo|"..k,parseInt(v.ammo))
						end
					end
					opened[parseInt(user_id)] = parseInt(nuser_id)
					vCLIENT.openInspect(source)
				else
					if not vRP.wantedReturn(nuser_id) then
						local policia = vRP.numPermission("Police")
						if parseInt(#policia) > 4 then
							local h = vCLIENT.entityHeading(source)
							if vRPclient.getHealth(nplayer) >= 102 then
								local request = vRP.request(nplayer,"You are being searched, do you to allow it?",60)
								if request then
									vRPclient._playAnim(source,true,{"oddjobs@shop_robbery@rob_till","loop"},true)
									vRPclient._playAnim(nplayer,true,{"random@arrests@busted","idle_a"},true)
									vCLIENT.toggleCarry(nplayer,source)

									TriggerClientEvent("cancelando",nplayer,true)

									local weapons = vRPclient.replaceWeapons(nsource,{})
									for k,v in pairs(weapons) do
										vRP.giveInventoryItem(parseInt(nuser_id),"wbody|"..k,1)
										if parseInt(v.ammo) > 0 then
											vRP.giveInventoryItem(parseInt(nuser_id),"wammo|"..k,parseInt(v.ammo))
										end
									end
									opened[parseInt(user_id)] = parseInt(nuser_id)
									vCLIENT.openInspect(source)
								else
									TriggerClientEvent("Notify",source,"negado","Refused magazine request.",5000)
								end
							end
						else
							TriggerClientEvent("Notify",source,"negado","System currently unavailable.",5000)
						end
					end
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- OPENCHEST
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.openChest()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local ninventory = {}
		local uinventory = {}

		local inv = vRP.getInventory(parseInt(opened[user_id]))
		if inv then
			for k,v in pairs(inv) do
				if vRP.itemBodyList(k) then
					table.insert(ninventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(k), index = vRP.itemIndexList(k), key = k, peso = vRP.getItemWeight(k) })
				end
			end
		end

		local inv2 = vRP.getInventory(parseInt(user_id))
		if inv2 then
			for k,v in pairs(inv2) do
				if vRP.itemBodyList(k) then
					table.insert(uinventory,{ amount = parseInt(v.amount), name = vRP.itemNameList(k), index = vRP.itemIndexList(k), key = k, peso = vRP.getItemWeight(k) })
				end
			end
		end

		return ninventory,uinventory,vRP.getInventoryWeight(parseInt(user_id)),vRP.getInventoryMaxWeight(parseInt(user_id)),vRP.getInventoryWeight(parseInt(opened[user_id])),vRP.getInventoryMaxWeight(parseInt(opened[user_id]))
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- STOREITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.storeItem(itemName,amount)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		local nsource = vRP.getUserSource(parseInt(opened[user_id]))
		if user_id and nsource then
			if parseInt(amount) > 0 then
				if vRP.getInventoryWeight(parseInt(opened[user_id]))+vRP.getItemWeight(itemName)*parseInt(amount) <= vRP.getInventoryMaxWeight(parseInt(opened[user_id])) then
					if vRP.tryGetInventoryItem(parseInt(user_id),itemName,parseInt(amount)) then
						vRP.giveInventoryItem(parseInt(opened[user_id]),itemName,parseInt(amount))
						TriggerClientEvent("vrp_inspect:Update",source,"updateChest")
					end
				else
					TriggerClientEvent("Notify",source,"negado","The <b>backpack</b> is full.",5000)
				end
			else
				local inv = vRP.getInventory(parseInt(user_id))
				if inv and inv[itemName] ~= nil then
					if vRP.getInventoryWeight(parseInt(opened[user_id]))+vRP.getItemWeight(itemName)*parseInt(inv[itemName].amount) <= vRP.getInventoryMaxWeight(parseInt(opened[user_id])) then
						if vRP.tryGetInventoryItem(parseInt(user_id),itemName,parseInt(inv[itemName].amount)) then
							vRP.giveInventoryItem(parseInt(opened[user_id]),itemName,parseInt(inv[itemName].amount))
							TriggerClientEvent("vrp_inspect:Update",source,"updateChest")
						end
					else
						TriggerClientEvent("Notify",source,"negado","The <b>backpack</b> is full.",5000)
					end
				end
			end
		end
	end
	return false
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- TAKEITEM
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.takeItem(itemName,amount)
	local source = source
	if itemName then
		local user_id = vRP.getUserId(source)
		local nsource = vRP.getUserSource(parseInt(opened[user_id]))
		if user_id and nsource then
			if parseInt(amount) > 0 then
				if vRP.getInventoryWeight(parseInt(user_id))+vRP.getItemWeight(itemName)*parseInt(amount) <= vRP.getInventoryMaxWeight(parseInt(user_id)) then
					if vRP.tryGetInventoryItem(parseInt(opened[user_id]),itemName,parseInt(amount)) then
						vRP.giveInventoryItem(parseInt(user_id),itemName,parseInt(amount))
						TriggerClientEvent("vrp_inspect:Update",source,"updateChest")
					end
				else
					TriggerClientEvent("Notify",source,"negado","The <b>backpack</b> is full.",5000)
				end
			else
				local inv = vRP.getInventory(parseInt(opened[user_id]))
				if inv and inv[itemName] ~= nil then
					if vRP.getInventoryWeight(parseInt(user_id))+vRP.getItemWeight(itemName)*parseInt(inv[itemName].amount) <= vRP.getInventoryMaxWeight(parseInt(user_id)) then
						if vRP.tryGetInventoryItem(parseInt(opened[user_id]),itemName,parseInt(inv[itemName].amount)) then
							vRP.giveInventoryItem(parseInt(user_id),itemName,parseInt(inv[itemName].amount))
							TriggerClientEvent("vrp_inspect:Update",source,"updateChest")
						end
					else
						TriggerClientEvent("Notify",source,"negado","The <b>backpack</b> is full.",5000)
					end
				end
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESETINSPECT
-----------------------------------------------------------------------------------------------------------------------------------------
function cRP.resetInspect()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id and opened[parseInt(user_id)] then
		local nplayer = vRP.getUserSource(parseInt(opened[parseInt(user_id)]))
		if nplayer then
			vCLIENT.toggleCarry(nplayer,source)
			TriggerClientEvent("cancelando",nplayer,false)
		end

		opened[parseInt(user_id)] = nil
		vRPclient._stopAnim(source,false)
	end
end