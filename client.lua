local pedindex = {}

ESX                             = nil
strengthValue = nil
staminaValue = nil
shootingValue = nil
drivingValue = nil
fishingValue = nil
drugsValue = nil
timer1 = 0
timer2 = 0
timer3 = 0

---------------------------------
------------- CONFIG ------------
---------------------------------

local openKey = 142 -- replace 142 with what button you want

---------------------------------
---------------------------------

Citizen.CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Citizen.Wait(0)
  end
end)

function round(num, numDecimalPlaces)
	local mult = 10^(2)
	return math.floor(num * mult + 0.5) / mult
end

RegisterNetEvent('cl_stadus_skills:sendPlayerSkills')
AddEventHandler('cl_stadus_skills:sendPlayerSkills', function(stamina, strength, driving, shooting, fishing, drugs)
	strengthValue = strength
	staminaValue = stamina
	shootingValue = shooting
	drivingValue = driving
	fishingValue = fishing
	drugsValue = drugs

	StatSetInt("MP0_STRENGTH", round(strength), true)
	StatSetInt("MP0_STAMINA", round(stamina), true)
	StatSetInt('MP0_LUNG_CAPACITY', round(stamina), true)
	StatSetInt('MP0_SHOOTING_ABILITY', round(shooting), true)
	StatSetInt('MP0_WHEELIE_ABILITY', round(driving), true)
	StatSetInt('MP0_DRIVING_ABILITY', round(driving), true)
end)

--===============================================
--==                 VARIABLES                 ==
--===============================================
function EnableGui(enable)
	if staminaValue == nil or strengthValue == nil or shootingValue == nil or drivingValue == nil or fishingValue == nil or drugsValue == nil then
		ESX.TriggerServerCallback('cl_stadus_skills:getSkills', function(stamina, strength, driving, shooting, fishing, drugs)
			strengthValue = strength
			staminaValue = stamina
			shootingValue = shooting
			drivingValue = driving
			fishingValue = fishing
			drugsValue = drugs

			SendNUIMessage({
				type = "enableui",
				enable = enable,
				stamina = staminaValue,
				strength = strengthValue,
				driving = drivingValue,
				shooting = shootingValue,
				fishing = fishingValue, 
				drugs = drugsValue
			})
		end)
	else
		SetNuiFocus(enable)
		guiEnabled = enable

		SendNUIMessage({
			type = "enableui",
			enable = enable,
			stamina = staminaValue,
			strength = strengthValue,
			driving = drivingValue,
			shooting = shootingValue,
			fishing = fishingValue, 
			drugs = drugsValue
		})
	end
end

--===============================================
--==              Close GUI                    ==
--===============================================
RegisterNUICallback('escape', function(data, cb)
    EnableGui(false)
end)

Faketimer = 0

Citizen.CreateThread(function()

	while true do

        if guiEnabled then

          if IsDisabledControlJustReleased(0, openKey) then
		  
            SendNUIMessage({
              type = "click"
            })
			
            end
		else
			if IsDisabledControlJustReleased(17, 11) then
				EnableGui(true)
			end
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
	while true do
        	if IsPedShooting(GetPlayerPed(-1), true) then
        		if timer1 > 29 then
					TriggerServerEvent('cl_stadus_skills:addShooting', GetPlayerServerId(PlayerId()), (math.random() + 0))
					timer1 = 0
				end
			end
			if IsPedSprinting(GetPlayerPed(-1), true) or IsPedRunning(GetPlayerPed(-1), true) or IsPedSwimming(GetPlayerPed(-1), true) or IsPedSwimmingUnderWater(GetPlayerPed(-1), true) or IsPedClimbing(GetPlayerPed(-1), true) then
				if timer2 > 29 then
					TriggerServerEvent('cl_stadus_skills:addStamina', GetPlayerServerId(PlayerId()), (math.random() + 0))
					timer2 = 0
			  	end
			end
			if IsPedInAnyVehicle(GetPlayerPed(-1), true) then
				if timer3 > 29 then
					TriggerServerEvent('cl_stadus_skills:addDriving', GetPlayerServerId(PlayerId()), (math.random() + 0))
					timer3 = 0
				end
			end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		timer1 = timer1 + 1
		timer2 = timer2 + 1
		timer3 = timer3 + 1
		if timer1 > 10000 then
			timer1 = 100
		end
		if timer2 > 10000 then
			timer2 = 100
		end
		if timer3 > 10000 then
			timer3 = 100
		end
	end
end)

RegisterNetEvent('cl_stadus_skills:sendMessage')
AddEventHandler('cl_stadus_skills:sendMessage', function(title, message, time)
	exports['SNZ_UI']:AddNotification(title, message, time, 'fas fa-inbox')
end)

RegisterNetEvent('cl_stadus_skills:update')
AddEventHandler('cl_stadus_skills:update', function(number, count)
	if number == 0 then
		staminaValue = count
	elseif number == 1 then
		strengthValue = count
	elseif number == 2 then
		drivingValue = count
	elseif number == 3 then
		fishingValue = count
	elseif number == 4 then
		drugsValue = count
	elseif number == 5 then
		shootingValue = count
	end
end)