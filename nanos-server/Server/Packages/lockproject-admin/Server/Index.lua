-- lockproject-admin — Server entrypoint

Console.Log("[Admin] Loading...")

-- Charge le module principal
local Admin = require("Admin.lua")

-- Expose globalement
_G.LockProject_Admin = Admin

-- Charge les fichiers de commandes
require("Commands/Test.lua")
require("Commands/Money.lua")
require("Commands/Teleport.lua")

-- Hook : intercepter les messages de chat
-- API confirmée par diagnostic : Chat.Subscribe("PlayerSubmit", function(text, sender))
Chat.Subscribe("PlayerSubmit", function(text, sender)
    local cmd_name, args = Admin:ParseChatLine(text)
    if not cmd_name then
        return  -- pas une commande, laisse passer le message normal
    end

    local Players = _G.LockProject_Players
    local steam_id = sender:GetSteamID()
    local player = Players:Get(steam_id)
    if not player then
        Console.Warn("[Admin] Player not in registry: " .. tostring(steam_id))
        return
    end

    Admin:Execute(player, cmd_name, args)

    -- Retourne false pour "consommer" le message → il n'apparaît pas dans le chat
    return false
end)

Console.Log("[Admin] Loaded.")