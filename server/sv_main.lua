
local CoreName = nil
ESX = nil

if Config['General']["Core"] == "QBCORE" then
    if Config['CoreSettings']["QBCORE"]["Version"] == "new" then
        CoreName = Config['CoreSettings']["QBCORE"]["Export"]
    elseif Config['CoreSettings']["QBCORE"]["Version"] == "old" then
        TriggerEvent(Config['CoreSettings']["QBCORE"]["Trigger"], function(obj) CoreName = obj end)
    end
elseif Config['General']["Core"] == "ESX" then
    TriggerEvent(Config['CoreSettings']["ESX"]["Trigger"], function(obj) ESX = obj end)
end




SQL = function(query, parameters, cb)
    local res = nil
    local IsBusy = true
    if Config['General']["SQLWrapper"] == "mysql-async" then
        if string.find(query, "SELECT") then
            MySQL.Async.fetchAll(query, parameters, function(result)
                if cb then
                    cb(result)
                else
                    res = result
                    IsBusy = false
                end
            end)
        else
            MySQL.Async.execute(query, parameters, function(result)
                if cb then
                    cb(result)
                else
                    res = result
                    IsBusy = false
                end
            end)
        end
    elseif Config['General']["SQLWrapper"] == "oxmysql" then
        exports.oxmysql:execute(query, parameters, function(result)
            if cb then
                cb(result)
            else
                res = result
                IsBusy = false
            end
        end)
    elseif Config['General']["SQLWrapper"] == "ghmattimysql" then
        exports.ghmattimysql:execute(query, parameters, function(result)
            if cb then
                cb(result)
            else
                res = result
                IsBusy = false
            end
        end)
    end
    while IsBusy do
        Citizen.Wait(0)
    end
    return res
end

if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:GetExpireTime', function(source, cb)
        local shit = (os.time() + 6 * 3600)
        cb(shit)
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:GetExpireTime', function(source, cb)

        local shit = (os.time() + 6 * 3600)
        cb(shit)
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:GetExpireTime", function()
        local shit = (os.time() + 6 * 3600)
        return shit
    end)
end


if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:getCurrentBNE', function(source, cb)
        local src = source
        local pData = CoreName.Functions.GetPlayer(src)
        local cid = pData.PlayerData.citizenid
        if pData ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1] == nil then
                SQL('INSERT INTO bropixel_boosting (citizenid) VALUES (?)',{cid})
                cb({BNE = 0, background = tostring(Config['Utils']["Laptop"]["DefaultBackground"]) , vin = nil})
            else
                if sql[1].BNE ~= nil then
                    cb({BNE = sql[1].BNE , background = sql[1].background , vin = sql[1].vin})
                else
                    cb({BNE = 0 , background =  tostring(Config['Utils']["Laptop"]["DefaultBackground"]) , vin = nil})
                end
            end
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:getCurrentBNE', function(source, cb)

        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local cid = xPlayer.identifier
    
        if xPlayer ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1] == nil then
                SQL('INSERT INTO bropixel_boosting (citizenid) VALUES (?)',{cid})
                cb(0)
            else
                if sql[1].BNE ~= nil then
                    cb({BNE = sql[1].BNE , background = sql[1].background , vin = sql[1].vin})
                else
                    cb(0)
                end
            end
        end
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:getCurrentBNE", function()
        local src = source
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        local cid = user:getCurrentCharacter().id
        if user ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1] == nil then
                SQL('INSERT INTO bropixel_boosting (citizenid) VALUES (?)',{cid})
                value = 0
            else
                if sql[1].BNE ~= nil then
                    value = ({BNE = sql[1].BNE , background = sql[1].background})
                else
                    value = 0
                end
            end
        end
        return value
    end)
end

  




RegisterNetEvent("bropixel-boosting:server:setBacgkround")
AddEventHandler("bropixel-boosting:server:setBacgkround" , function(back)
    local src = source
    if Config['General']["Core"] == "QBCORE" then
        local pData = CoreName.Functions.GetPlayer(src)
        local cid = pData.PlayerData.citizenid
        local sql = SQL('UPDATE bropixel_boosting SET background=@b WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@b'] = back})
        
    elseif Config['General']["Core"] == "ESX" then
        local xPlayer = ESX.GetPlayerFromId(src)
        local cid = xPlayer.identifier

        if xPlayer ~= nil then
            local sql = SQL('UPDATE bropixel_boosting SET background=@b WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@b'] = back})
        end
    elseif Config['General']["Core"] == "NPBASE" then
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        local cid = user:getCurrentCharacter().id
        if user ~= nil then
            local sql = SQL('UPDATE bropixel_boosting SET background=@b WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@b'] = back})
        end 
    end
end)




if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:removeBNE', function(source, cb , amount)
        local src = source
        local pData = CoreName.Functions.GetPlayer(src)
        local cid = pData.PlayerData.citizenid
        if pData ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1].BNE ~= nil then
                local pBNE = sql[1].BNE
                RemoveBNE(cid, pBNE, amount)
            else
                cb(0)
            end
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:removeBNE', function(source, cb , amount)

        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local cid = xPlayer.identifier
    
        if xPlayer ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1].BNE ~= nil then
                local pBNE = sql[1].BNE
                RemoveBNE(cid, pBNE, amount)
            else
                cb(0)
            end
            
        end
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:removeBNE", function(amount)
        local src = source
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        local cid = user:getCurrentCharacter().id
        if user ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1].BNE ~= nil then
                local pBNE = sql[1].BNE
                RemoveBNE(cid, pBNE, amount)
            else
                value = 0
            end
        
        end
        return value
    end)   
end


if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:addBne', function(source, cb , amount)
        local src = source
        local pData = CoreName.Functions.GetPlayer(src)
        local cid = pData.PlayerData.citizenid
        if pData ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1].BNE ~= nil then
                local pBNE = sql[1].BNE
                AddBNE(cid, pBNE, amount)
            else
                cb(0)
            end
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:addBne', function(source, cb , amount)
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local cid = xPlayer.identifier
        local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
        if sql[1].BNE ~= nil then
            local pBNE = sql[1].BNE
            AddBNE(cid, pBNE, amount)
        else
            cb(0)
        end
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:addBne", function(amount)
        local src = source
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        local cid = user:getCurrentCharacter().id
        if user ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if sql[1].BNE ~= nil then
                local pBNE = sql[1].BNE
                AddBNE(cid, pBNE, amount)
            else
                value = 0
            end
        end
        return value
    end)
end


if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:server:checkVin', function(source, cb , data)
        local src = source
        local pData = CoreName.Functions.GetPlayer(src)
        local cid = pData.PlayerData.citizenid
    
        if pData ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if(sql[1] ~= nil) then
                if(sql[1].vin == 0) then
                    value = true
                    SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                else
                    local d1 = os.date("*t",   os.time())
                    local d2 = os.date("*t", sql[1].vin)
                    local zone_diff = os.difftime(os.time(d1), os.time(d2))
                    if(math.floor(zone_diff  / 86400) >= Config['Utils']["VIN"] ["VinDays"]) then
                        cb(true)
                        SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                    end
                end
            end
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:server:checkVin', function(source, cb , data)

        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        local cid = xPlayer.identifier
    
        if xPlayer ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if(sql[1] ~= nil) then
                if(sql[1].vin == 0) then
                    value = true
                    SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                else
                    local d1 = os.date("*t",   os.time())
                    local d2 = os.date("*t", sql[1].vin)
                    local zone_diff = os.difftime(os.time(d1), os.time(d2))
                    if(math.floor(zone_diff  / 86400) >= Config['Utils']["VIN"] ["VinDays"]) then
                        cb(true)
                        SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                    end
                end
            end
        end
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:server:checkVin", function()
        local src = source
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        local cid = user:getCurrentCharacter().id
        if user ~= nil then
            local sql = SQL('SELECT * FROM bropixel_boosting WHERE citizenid=@citizenid', {['@citizenid'] = cid})
            if(sql[1] ~= nil) then
                if(sql[1].vin == 0) then
                    value = true
                    SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                else
                    local d1 = os.date("*t",   os.time())
                    local d2 = os.date("*t", sql[1].vin)
                    local zone_diff = os.difftime(os.time(d1), os.time(d2))
                    if(math.floor(zone_diff  / 86400) >= Config['Utils']["VIN"] ["VinDays"]) then
                        value = true
                        SQL('UPDATE bropixel_boosting SET vin=@vin WHERE citizenid=@citizenid', {['@citizenid'] = cid , ['@vin'] = os.time()})
                    end
                end
            end
        end
        return value
    end)
end


if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:GetTimeLeft', function(source, cb , data)
        local shit = 2
        cb(shit)
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:GetTimeLeft', function(source, cb , data)
        local shit = 2
        cb(shit)
    end)
elseif Config['General']["Core"] == "NPBASE" then
    RPC.register("bropixel-boosting:GetTimeLeft", function()
        local shit = 2
        cb(shit)
    end)
end


  

---------------- Cop Blip Thingy ------------------



RegisterServerEvent('bropixel-boosting:alertcops')
AddEventHandler('bropixel-boosting:alertcops', function(cx,cy,cz)
    if Config['General']["Core"] == "QBCORE" then
        for k, v in pairs(CoreName.Functions.GetPlayers()) do
            local Player = CoreName.Functions.GetPlayer(v)
            if Player ~= nil then
                if Player.PlayerData.job.name == Config['General']["PoliceJobName"] then
                    TriggerClientEvent('bropixel-boosting:setcopblip', Player.PlayerData.source, cx,cy,cz)
                end
            end
        end
    elseif Config['General']["Core"] == "ESX" then
        local src = source
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
            if xPlayer.job.name == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:setcopblip', xPlayers[i], cx,cy,cz)
            end
        end
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        for _, player in pairs(GetPlayers()) do
            local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(tonumber(player))
            local job = user:getVar("job")
    
            if job == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:setcopblip', src, cx,cy,cz)
            end
        end
    end
end)





RegisterServerEvent('bropixel-boosting:AddVehicle')
AddEventHandler('bropixel-boosting:AddVehicle', function(model, plate, vehicleProps)
    if Config['General']["Core"] == "QBCORE" then
        local src = source
        local pData = CoreName.Functions.GetPlayer(src)
        VehicleData = {
            steam = pData.PlayerData.steam,
            license = pData.PlayerData.license,
            citizenid = pData.PlayerData.citizenid,
            vehicle = model,
            hash = GetHashKey(vehicle),
            vehicleMods = vehicleMods,
            vehicleplate = plate,
            vehiclestate = 1,
        }
        AddVehicle(VehicleData)
    elseif Config['General']["Core"] == "ESX" then
        local src = source
        local xPlayer = ESX.GetPlayerFromId(src)
        VehicleData = {
            steam = xPlayer.identifier,
            vehicle = json.encode(vehicleProps),
            vehicleplate = plate,
        }
        AddVehicle(VehicleData)
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        VehicleData = {
            cid = user:getCurrentCharacter().id,
            steam = user:getVar("hexid"),
            vehicle = model,
            vehicleplate = plate,
            vehiclestate = 1,
        }
        AddVehicle(VehicleData)
    end
end)



RegisterServerEvent('bropixel-boosting:removeblip')
AddEventHandler('bropixel-boosting:removeblip', function()
    if Config['General']["Core"] == "QBCORE" then
        for k, v in pairs(CoreName.Functions.GetPlayers()) do
            local Player = CoreName.Functions.GetPlayer(v)
            if Player ~= nil then
                if Player.PlayerData.job.name == Config['General']["PoliceJobName"] then
                    TriggerClientEvent('bropixel-boosting:removecopblip', Player.PlayerData.source)
                end
            end
        end
    elseif Config['General']["Core"] == "ESX" then
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
            if xPlayer.job.name == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:removecopblip', xPlayers[i])
            end
        end    
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        for _, player in ipairs(GetPlayers()) do
            local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(tonumber(player))
            local job = user:getVar("job")

            if job == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:removecopblip', src)
            end
        end
    end
end)

RegisterServerEvent('bropixel-boosting:SetBlipTime')
AddEventHandler('bropixel-boosting:SetBlipTime', function()
    if Config['General']["Core"] == "QBCORE" then
        for k, v in pairs(CoreName.Functions.GetPlayers()) do
            local Player = CoreName.Functions.GetPlayer(v)
            if Player ~= nil then
                if Player.PlayerData.job.name == Config['General']["PoliceJobName"] then
                    TriggerClientEvent('bropixel-boosting:setBlipTime', Player.PlayerData.source)
                end
            end
        end
    elseif Config['General']["Core"] == "ESX" then
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
            if xPlayer.job.name == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:setBlipTime', xPlayers[i])
            end
        end
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        for _, player in ipairs(GetPlayers()) do
            local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(tonumber(player))
            local job = user:getVar("job")
    
            if job == Config['General']["PoliceJobName"] then
                TriggerClientEvent('bropixel-boosting:setBlipTime', src)
            end
        end  
    end
end)

  


RegisterNetEvent('bropixel-boosting:finished')
AddEventHandler('bropixel-boosting:finished' , function()
    if Config['General']["Core"] == "QBCORE" then
        local src = source
        local ply = CoreName.Functions.GetPlayer(src)                   
        local worthamount = math.random(13000, 17000)
        local info = {
            worth = worthamount
        }
        if Config['Utils']["Rewards"]["Type"] == 'item' then
            ply.Functions.AddItem(Config['Utils']["Rewards"]["RewardItemName"], 1, false, info)
            TriggerClientEvent("inventory:client:ItemBox", src, CoreName.Shared.Items[Config['Utils']["Rewards"]["RewardItemName"]], "add")
        elseif Config['Utils']["Rewards"]["Type"] == 'money' then
            ply.Functions.AddMoney("bank",Config['Utils']["Rewards"]["RewardMoneyAmount"],"boosting-payment")
        end
    elseif Config['General']["Core"] == "ESX" then
        local src = source
        local ply = ESX.GetPlayerFromId(src)
        local worthamount = math.random(13000, 17000)
        local info = {
          worth = worthamount
        }
        if Config['Utils']["Rewards"]["Type"] == 'item' then
            ply.addInventoryItem(Config['Utils']["Rewards"]["RewardItemName"], 1)
        elseif Config['Utils']["Rewards"]["Type"] == 'money' then
            ply.addMoney(Config['Utils']["Rewards"]["RewardMoneyAmount"])
        end
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        local worthamount = math.random(13000, 17000)
        local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(src)
        if Config['Utils']["Rewards"]["Type"] == 'item' then
            TriggerClientEvent('player:receiveItem', src, Config['Utils']["Rewards"]["RewardItemName"], 1)
        elseif Config['Utils']["Rewards"]["Type"] == 'money' then
            if Config['Utils']["Rewards"]["RewardAccount"] == 'cash' then
                user:addMoney(Config['Utils']["Rewards"]["RewardMoneyAmount"])
            elseif Config['Utils']["Rewards"]["RewardAccount"] == 'bank' then
                user:addBank(Config['Utils']["Rewards"]["RewardMoneyAmount"])
            end
            TriggerClientEvent("DoLongHudText", src, "You recieved "..Config['Utils']["Rewards"]["RewardMoneyAmount"].."$ in "..Config['Utils']["Rewards"]["RewardAccount"].." - boosting")
        end 
    end
end)



if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateUseableItem("pixellaptop", function(source, item)
        local Player = CoreName.Functions.GetPlayer(source)
    
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent("bropixel-boosting:DisplayUI", source)
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterUsableItem('pixellaptop', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent("bropixel-boosting:DisplayUI", source)
    end)
end


RegisterNetEvent('bropixel-boosting:usedlaptop')
AddEventHandler('bropixel-boosting:usedlaptop' , function()
    TriggerClientEvent("bropixel-boosting:DisplayUI", source)
end)

RegisterNetEvent('bropixel-boosting:useddisabler')
AddEventHandler('bropixel-boosting:useddisabler' , function()
    TriggerClientEvent("bropixel-boosting:DisablerUsed", source)
end)


if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateUseableItem("disabler", function(source, item)
        local Player = CoreName.Functions.GetPlayer(source)
        if Player.Functions.GetItemByName(item.name) then
            TriggerClientEvent("bropixel-boosting:DisablerUsed", source)
        end
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterUsableItem('disabler', function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        TriggerClientEvent("bropixel-boosting:DisablerUsed", source)
    end)
end




if Config['General']["Core"] == "QBCORE" then
    CoreName.Functions.CreateCallback('bropixel-boosting:server:GetActivity', function(source, cb)
        local PoliceCount = 0
        for k, v in pairs(CoreName.Functions.GetPlayers()) do
            local Player = CoreName.Functions.GetPlayer(v)
            if Player ~= nil then 
                if (Player.PlayerData.job.name == Config['General']["PoliceJobName"] and Player.PlayerData.job.onduty) then
                    PoliceCount = PoliceCount + 1
                end
            end
        end
        cb(PoliceCount)
    end)
elseif Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:server:GetActivity', function(source, cb)
        local PoliceCount = 0
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
            if xPlayer.job.name == Config['General']["PoliceJobName"] then
                PoliceCount = PoliceCount + 1
            end
        end
        cb(PoliceCount)
    end)
end


if Config['General']["Core"] == "ESX" then
    ESX.RegisterServerCallback('bropixel-boosting:canPickUp', function(source, cb, item)
        local xPlayer = ESX.GetPlayerFromId(source)
        local xItem = xPlayer.getInventoryItem(item)
    
        if xItem.count >= 1 then
            cb(true)
        else
            cb(false)
        end
    end)
end

local color_msg = 195000

RegisterNetEvent('bropixel-boosting:logs')
AddEventHandler('bropixel-boosting:logs' , function(class, vehiclename)
	sendToDiscordBoostingLogs(class, discord_msg, color_msg,identifier)
end)

function sendToDiscordBoostingLogs(class,message,color,identifier)
    local src = source
    local name = GetPlayerName(src)
    if not color then
        color = color_msg
    end
    local sendD = {
        {
            ["color"] = color,
            ["title"] = message,
            ["description"] = "`Player Recieved a new contract with the class of`: **"..name.."**\nSteam: **"..identifier.steam.."** \nIP: **"..identifier.ip.."**\nDiscord: **"..identifier.discord.."**\nFivem: **"..identifier.license.."**",
            ["footer"] = {
                ["text"] = "Â© </BroPixel > - "..os.date("%x %X %p")
            },
        }
    }

    PerformHttpRequest(logs, function(err, text, headers) end, 'POST', json.encode({username = "</BroPixel > - boosting", embeds = sendD}), { ['Content-Type'] = 'application/json' })
end

local authorized = true

RegisterNetEvent('bropixel-boosting:loadNUI')
AddEventHandler('bropixel-boosting:loadNUI' , function()
    local source = source
    TriggerClientEvent('bropixel-boosting:StartUI', source)
end)


RegisterServerEvent("bropixel-boosting:CallCopsNotify" , function(plate , model , color , streetLabel)
    if Config['General']["Core"] == "QBCORE" then
        for k, v in pairs(CoreName.Functions.GetPlayers()) do
            local src = source
            local Ped = GetPlayerPed(src)
            local PlayerCoords = GetEntityCoords(Ped)
            local Player = CoreName.Functions.GetPlayer(src)
            if Player ~= nil then
                if Player.PlayerData.job.name == Config['General']["PoliceJobName"] then
                    TriggerEvent(
                    "core_dispatch:addCall",
                    "10-34", -- Change to your liking
                    "Possible Vehicle Boosting", -- Change to your liking
                    {
                        {icon = "car", info = model},
                        {icon = "fa-map-pin", info = streetLabel},
			{icon = "fa-map-pin", info = plate},
			{icon = "fa-map-pin", info = color}

                    },
                    {PlayerCoords[1], PlayerCoords[2], PlayerCoords[3]},
                    "police", -- Job receiving alert
                    5000, -- Time alert stays on screen
                    458, -- Blip Icon
                    3 -- Blip Color
                )
                end
            end
        end
    elseif Config['General']["Core"] == "ESX" then
        local src = source
        local xPlayers = ESX.GetPlayers()
        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
        
            if xPlayer.job.name == Config['General']["PoliceJobName"] then
                TriggerClientEvent("bropixel-boosting:SendNotify" ,xPlayers[i] , {plate = plate , model = model , color = color , place = place})
            end
        end
    elseif Config['General']["Core"] == "NPBASE" then
        local src = source
        for _, player in pairs(GetPlayers()) do
            local user = exports[Config['CoreSettings']["NPBASE"]["Name"]]:getModule("Player"):GetUser(tonumber(player))
            local job = user:getVar("job")
    
            if job == Config['General']["PoliceJobName"] then
                TriggerClientEvent("bropixel-boosting:SendNotify" ,src , {plate = plate , model = model , color = color , place = place})
            end
        end
    end
end)