local ESX = nil
local spawned = false
local started = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    local count = 0
    local function checkHash()
        local ped = GetPlayerPed(-1)
        local mhash = GetEntityModel(ped)
        --print(mhash)
        for index, lhash in pairs(cfg.hashesList) do
            if mhash == lhash then
                if not spawned then
                    Citizen.Wait(5000)
                    spawned = true

                    local ped = GetPlayerPed(-1)

                    ESX.TriggerServerCallback('esx_vita:getVita', function(table)
                        local oldvita = GetEntityHealth(ped)
                        local vita = table.vita
                        if oldvita ~= vita + 100 then
                            startClock()
                            TriggerEvent("esx_vita:impostaVita", vita)
                            SetPlayerHealthRechargeMultiplier(table.player, 0.0)
                            if vita <= 0 then
                                startDeadStatus(ped)
                            end
                        else
                            startClock()
                        end
                    end)
                end
            else
                if count ~= tonumber(cfg.secondsCheck) then
                    count = count + 1
                    Citizen.Wait(1000)
                    checkHash()
                end
            end
        end
    end
    checkHash()
end)

-- qui setto il valore della vita appena il giocatore
-- spawna, o comunque, quando chiamo l'evento.
RegisterNetEvent("esx_vita:impostaVita")
AddEventHandler("esx_vita:impostaVita", function(vita)
    local ped = GetPlayerPed(-1)
    if vita > 0 then
        local n = math.floor(vita + 100)
        SetEntityHealth(ped, n)
    end
end)

-- questo ciclo salva la vita al giocatore sul db
-- ogni tot mintui
function startClock()
    if not started then
        started = true
        Citizen.CreateThread(function()
            while spawned do
            	-- controllo della scelta del tempo dal config
            	if cfg.updateCheckType == "minuti" then
                	Citizen.Wait(cfg.updateCheck * 60000)
            	elseif cfg.updateCheckType == "secondi" then
                	Citizen.Wait(cfg.updateCheck * 1000)
            	elseif cfg.updateCheckType == "millisecondi" then
                	Citizen.Wait(cfg.updateCheck)
            	else
                	Citizen.Wait(2000)
            	end

            	local ped = GetPlayerPed(-1)
            	local vita = GetEntityHealth(ped)
            	if ped ~= nil and vita ~= nil and vita > 0 then
                	local n = math.floor(vita)
                	TriggerServerEvent("esx_vita:saveVita", n)
            	end
        	end
    	end)
	end
end


function startDeadStatus(ped)
    Citizen.CreateThread(function()
        DoScreenFadeOut(800)

        while not IsScreenFadedOut() do
            Citizen.Wait(10)
        end
        ESX.TriggerServerCallback('esx_vita:pulisciInventario', function()
            local coordinate = {
                x = cfg.spawnPoint.x,
                y = cfg.spawnPoint.y,
                z = cfg.spawnPoint.z,
				heading = cfg.spawnPoint.heading
            }

			ResetPed(ped, coordinate)
            StopScreenEffect('DeathFailOut')
            DoScreenFadeIn(800)
        end)
    end)
end

function ResetPed(ped, coords)
	ESX.SetPlayerData('loadout', {})
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
	SetEntityHealth(ped, 200)
	TriggerServerEvent("esx_vita:saveVita", 200)
	ESX.ShowNotification("Sei uscito dal server mentre eri a terra. Sei stato portato all'ospedale!")
end
