-- lockproject-player — Server entrypoint

Console.Log("[Player] Loading...")

-- Charge les modules (renommés en local pour éviter de shadow Player/Players de nanos)
local PlayerClass = require("Player.lua")
local PlayersRegistry = require("Players.lua")

-- Expose globalement pour les autres packages
_G.LockProject_Player  = PlayerClass
_G.LockProject_Players = PlayersRegistry

-- Hook : à la connexion d'un joueur
Player.Subscribe("Spawn", function(nanos_player)
    local p = PlayerClass.new(nanos_player)
    p:LoadFromDatabase()
    PlayersRegistry:Add(p)

    -- Spawn un Character pour qu'il ait un corps
    p:SpawnCharacter()

    -- Message de bienvenue
    local msg
    if p:IsNew() then
        msg = "Bienvenue " .. p:GetName() .. " ! (premier login)"
    else
        msg = "Re " .. p:GetName() .. " ! (connexion #" .. p.connection_count .. ", " .. p:GetMoney() .. "¥)"
    end
    Chat.BroadcastMessage(msg)
end)

-- Hook : à la déconnexion
Player.Subscribe("Destroy", function(nanos_player)
    local steam_id = nanos_player:GetSteamID()
    local p = PlayersRegistry:Get(steam_id)
    if p then
        p:Save()
        p:DespawnCharacter()  -- nettoie le character
        PlayersRegistry:Remove(steam_id)
        Console.Log("[Player] " .. p:GetName() .. " déconnecté, sauvegardé.")
    end
end)

Console.Log("[Player] Loaded.")