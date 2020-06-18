local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
emP = Tunnel.getInterface("emp_minerador")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local selecionado = 1
-----------------------------------------------------------------------------------------------------------------------------------------
-- RESIDENCIAS
-----------------------------------------------------------------------------------------------------------------------------------------
local locs = {
	[1] = { 2956.11,2772.93,40.22 },
	[2] = { 2957.54,2772.76,40.32 },
	[3] = { 2953.58,2770.19,39.59 },
	[4] = { 2952.57,2768.19,40.03 },
	[5] = { 2948.31,2767.55,39.91 },
	[6] = { 2947.96,2765.65,40.55 },
	[7] = { 2942.52,2760.60,42.82 },
	[8] = { 2943.45,2756.52,43.66 },
	[9] = { 2947.35,2754.58,43.97 },
	[10] = { 2954.03,2754.14,43.96 },
	[11] = { 2955.20,2756.07,44.32 },
	[12] = { 2959.33,2758.81,42.57 },
	[13] = { 2959.82,2765.70,41.92 },
	[14] = { 2958.33,2767.20,41.42 },
	[15] = { 2974.34,2745.34,43.91 },
	[16] = { 2983.58,2763.12,43.66 },
	[17] = { 2988.45,2753.75,43.52 },
	[18] = { 2991.07,2776.31,43.78 },
	[19] = { 2959.03,2819.98,43.69 },
	[20] = { 2956.01,2820.06,43.19 },
	[21] = { 2951.13,2816.52,42.92 },
	[22] = { 2948.04,2820.89,43.61 },
	[23] = { 2944.52,2820.23,43.53 },
	[24] = { 2944.25,2818.68,43.53 },
	[25] = { 2938.35,2813.00,43.44 },
	[26] = { 2936.61,2814.16,44.02 },
	[27] = { 2925.64,2796.38,41.47 },
	[28] = { 2925.34,2794.84,41.51 },
	[29] = { 2925.83,2792.54,41.23 },
	[30] = { 2927.94,2789.11,40.65 },
	[31] = { 2928.14,2790.74,40.80 },
	[32] = { 2930.75,2786.90,40.14 },
	[33] = { 2934.45,2784.03,40.09 },
	[34] = { 2936.94,2774.47,39.66 },
	[35] = { 2938.30,2774.27,39.74 },
	[36] = { 2937.25,2771.71,39.90 },
	[37] = { 2939.04,2769.32,39.63 }
}
-----------------------------------------------------------------------------------------------------------------------------------------
-- ENTREGAS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5)
		if not servico then
			local ped = GetPlayerPed(-1)
			if not IsPedInAnyVehicle(ped) then
				local x,y,z = table.unpack(GetEntityCoords(ped))
				local distance = Vdist(x,y,z,locs[selecionado][1],locs[selecionado][2],locs[selecionado][3])
				if distance <= 100.0 then
					DrawMarker(21,locs[selecionado][1],locs[selecionado][2],locs[selecionado][3]-0.3,0,0,0,0,180.0,130.0,0.6,0.8,0.5,255,0,0,150,1,0,0,1)
					if distance <= 1.2 and IsControlJustPressed(1,38) and emP.checkWeight() and GetEntityModel(GetPlayersLastVehicle()) == -1705304628 then
						servico = true
						vRP.DeletarObjeto()
						TriggerEvent("cancelando",true)
						SetEntityCoords(ped,locs[selecionado][1]+0.0001,locs[selecionado][2]+0.0001,locs[selecionado][3]+0.0001-1,1,0,0,1)
						vRP.CarregarObjeto("amb@world_human_const_drill@male@drill@base","base","prop_tool_jackham",15,28422)
						SetTimeout(10000,function()
							servico = false
							vRP.DeletarObjeto()
							vRP._stopAnim(false)
							TriggerEvent("cancelando",false)
							backentrega = selecionado
							while true do
								if backentrega == selecionado then
									selecionado = math.random(#locs)
								else
									break
								end
								Citizen.Wait(10)
							end
							emP.checkPayment()
						end)
					end
				end
			end
		end
	end
end)