ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local function syncPlayerLocations()
    SetTimeout(5000, function()
        local xPlayers = ESX.GetPlayers()

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(i)

            MySQL.Async.execute(
                'UPDATE users SET `position` = @position WHERE `identifier` = @identifier;',
                {
                    ['@position'] = json.encode(xPlayer.get('coords') or xPlayer.lastPosition),
                    ['@identifier'] = xPlayer.identifier
                }
            )
        end

        syncPlayerLocations()
    end)
end

AddEventHandler('esx:playerLoaded', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    MySQL.Async.execute(
        'UPDATE users SET online = 1 WHERE identifier = @identifier;',
        {
            ['@identifier'] = xPlayer.identifier
        }
    )
end)

AddEventHandler('esx:playerDropped', function(playerId)
    local xPlayer = ESX.GetPlayerFromId(playerId)

    MySQL.Async.execute(
        'UPDATE users SET online = 0 WHERE identifier = @identifier;',
        {
            ['@identifier'] = xPlayer.identifier
        }
    )
end)

AddEventHandler('onMySQLReady', function()
    MySQL.Async.execute('UPDATE users SET online = 0;')

    syncPlayerLocations()
end)
