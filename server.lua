ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function giveCredits(identifier, credits)
    MySQL.Async.execute(
        "UPDATE `users` SET `credits`= `credits` + @credits WHERE `identifier` = @identifier",
        {["@credits"] = credits, ["@identifier"] = identifier},
        function()
        end
    )
end

ESX.RegisterUsableItem(
    "armor",
    function(source)
		local xPlayer  = ESX.GetPlayerFromId(source)
		local ped = GetPlayerPed(source)
		if GetPedArmour(ped) ~= 100 then
			local dict, anim = "clothingtie", "try_tie_negative_a"
			ESX.Streaming.RequestAnimDict(
				dict,
				function()
					TaskPlayAnim(ped, dict, anim, 3.0, 3.0, 1200, 51, 0, false, false, false)
				end
			)
			Citizen.Wait(1100)
			xPlayer.removeInventoryItem("armor", 1)

			local vest = GetPedDrawableVariation(PlayerPedId(), 9)

			if vest == -1 or vest == 0 and Config.SetVestIfNone then
				SetPedComponentVariation(ped, 9, Config.VestId, 2, 0)
			end
			SetPedArmour(ped, 100)
		else
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'ClassicLife', 'Du trägst bereits eine Schutzweste', 10000)
		end
    end
)

AddEventHandler('esx:playerLoaded', function(source) 
  local _source = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if ( skillInfo and skillInfo[1] ) then
			TriggerClientEvent('cl_stadus_skills:sendPlayerSkills', _source, skillInfo[1].stamina, skillInfo[1].strength, skillInfo[1].driving, skillInfo[1].shooting, skillInfo[1].fishing, skillInfo[1].drugs)
			else
				MySQL.Async.execute('INSERT INTO `zap801027-1`.`stadus_skills` (`identifier`, `strength`, `stamina`, `driving`, `shooting`, `fishing`, `drugs`) VALUES (@identifier, @strength, @stamina, @driving, @shooting, @fishing, @drugs);',
				{
				['@identifier'] = xPlayer.identifier,
				['@strength'] = 0,
				['@stamina'] = 0,
				['@driving'] = 0,
				['@shooting'] = 0,
				['@fishing'] = 0,
				['@drugs'] = 0
				}, function ()
				end)
		end
	end)
end)

function updatePlayerInfo(source)
  local _source = source
  local xPlayer  = ESX.GetPlayerFromId(_source)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if ( skillInfo and skillInfo[1] ) then
			TriggerClientEvent('cl_stadus_skills:sendPlayerSkills', _source, skillInfo[1].stamina, skillInfo[1].strength, skillInfo[1].driving, skillInfo[1].shooting, skillInfo[1].fishing, skillInfo[1].drugs)
		end
	end)
end

RegisterServerEvent("cl_stadus_skills:addStamina")
AddEventHandler("cl_stadus_skills:addStamina", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer um ' .. round(amount, 2) .. '% verbessert', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].stamina + amount >= 100.0 then
			amount = amount - 100.0
			giveCredits(xPlayer.identifier, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 0, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `stamina` = @stamina WHERE `identifier` = @identifier',
			{
			['@stamina'] = (skillInfo[1].stamina + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

RegisterServerEvent("cl_stadus_skills:addStrength")
AddEventHandler("cl_stadus_skills:addStrength", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du bist um ' .. round(amount, 2) .. '% stärker geworden', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].strength + amount >= 100.0 then
			amount = amount - 100.0
			giveCredits(xPlayer.identifier, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 1, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `strength` = @strength WHERE `identifier` = @identifier',
			{
			['@strength'] = (skillInfo[1].strength + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

RegisterServerEvent("cl_stadus_skills:addDriving")
AddEventHandler("cl_stadus_skills:addDriving", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du bist um ' .. round(amount, 2) .. '% besser geworden im fahren', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].driving + amount >= 100.0 then
			amount = amount - 100.0
			TriggerEvent('core_credits:givecredits', GetGameTimer(), source, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 2, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `driving` = @driving WHERE `identifier` = @identifier',
			{
			['@driving'] = (skillInfo[1].driving + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

RegisterServerEvent("cl_stadus_skills:addFishing")
AddEventHandler("cl_stadus_skills:addFishing", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du bist um ' .. round(amount, 2) .. '% besser geworden im fischen', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].fishing + amount >= 100.0 then
			amount = amount - 100.0
			TriggerEvent('core_credits:givecredits', GetGameTimer(), source, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 3, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `fishing` = @fishing WHERE `identifier` = @identifier',
			{
			['@fishing'] = (skillInfo[1].fishing + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

RegisterServerEvent("cl_stadus_skills:addDrugs")
AddEventHandler("cl_stadus_skills:addDrugs", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du bist um ' .. round(amount, 2) .. '% besser geworden im farmen', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].drugs + amount >= 100.0 then
			amount = amount - 100.0
			TriggerEvent('core_credits:givecredits', GetGameTimer(), source, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 4, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `drugs` = @drugs WHERE `identifier` = @identifier',
			{
			['@drugs'] = (skillInfo[1].drugs + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

RegisterServerEvent("cl_stadus_skills:addShooting")
AddEventHandler("cl_stadus_skills:addShooting", function(source, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du bist um ' .. round(amount, 2) .. '% besser geworden im schießen', 5000)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		if skillInfo[1].shooting + amount >= 100.0 then
			amount = amount - 100.0
			TriggerEvent('core_credits:givecredits', GetGameTimer(), source, 10)
			TriggerClientEvent('cl_stadus_skills:update', source, 5, amount)
			TriggerClientEvent('cl_stadus_skills:sendMessage', source, 'Skill System', 'Du hast deine Ausdauer auf 100% geskillt und bekommst dafür 10 Classic-Credit (/credits)', 10000)
		end
		MySQL.Async.execute('UPDATE `stadus_skills` SET `shooting` = @shooting WHERE `identifier` = @identifier',
			{
			['@shooting'] = (skillInfo[1].shooting + amount),
			['@identifier'] = xPlayer.identifier
			}, function ()
			updatePlayerInfo(source)
		end)
	end)
end)

ESX.RegisterServerCallback('cl_stadus_skills:getSkills', function(source, cb)
  local xPlayer    = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM `stadus_skills` WHERE `identifier` = @identifier', {['@identifier'] = xPlayer.identifier}, function(skillInfo)
		cb(skillInfo[1].stamina, skillInfo[1].strength, skillInfo[1].driving, skillInfo[1].shooting, skillInfo[1].fishing, skillInfo[1].drugs)
	end)
end)