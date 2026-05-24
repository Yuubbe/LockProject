-- lockproject-admin — Teleport commands

local Admin = _G.LockProject_Admin

-- /tp <x> <y> <z> — admin only
Admin:RegisterCommand("tp", 100, "Téléporte à <x> <y> <z>",
    function(player, args)
        if #args < 3 then
            Chat.SendMessage(player.nanos_player, "Usage : /tp <x> <y> <z>")
            return
        end
        local x = tonumber(args[1])
        local y = tonumber(args[2])
        local z = tonumber(args[3])
        if not (x and y and z) then
            Chat.SendMessage(player.nanos_player, "Coordonnées invalides")
            return
        end
        local ok = player:TeleportTo(x, y, z)
        if ok then
            Chat.SendMessage(player.nanos_player, "✈️ Téléporté à (" .. x .. ", " .. y .. ", " .. z .. ")")
        else
            Chat.SendMessage(player.nanos_player, "❌ Pas de character à téléporter")
        end
    end
)

-- /tphigh — admin, raccourci pour se téléporter en l'air
Admin:RegisterCommand("tphigh", 100, "Téléporte en l'air (Z=1000)",
    function(player, args)
        if not player.character then
            Chat.SendMessage(player.nanos_player, "❌ Pas de character")
            return
        end
        local loc = player.character:GetLocation()
        player:TeleportTo(loc.X, loc.Y, loc.Z + 1000)
        Chat.SendMessage(player.nanos_player, "✈️ +1000 en Z")
    end
)