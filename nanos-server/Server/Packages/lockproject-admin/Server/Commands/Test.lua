-- lockproject-admin — Test commands



local Admin = _G.LockProject_Admin

-- /ping — vérifie que le système répond
Admin:RegisterCommand("ping", 0, "Pong !",
    function(player, args)
        Chat.SendMessage(player.nanos_player, "🏓 pong")
    end
)

-- /help — liste les commandes accessibles
Admin:RegisterCommand("help", 0, "Liste les commandes disponibles",
    function(player, args)
        local level = Admin:GetPermissionLevel(player:GetSteamID())
        local cmds = Admin:GetAvailableCommands(level)
        Chat.SendMessage(player.nanos_player, "── Commandes disponibles ──")
        for _, cmd in ipairs(cmds) do
            Chat.SendMessage(player.nanos_player, "/" .. cmd.name .. " — " .. cmd.description)
        end
    end
)