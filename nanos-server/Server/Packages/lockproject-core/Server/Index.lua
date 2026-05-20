-- lockproject-core — Server entrypoint

Console.Log("[Core] LockProject démarre...")

-- Récupère le module Database (chargé par lockproject-database avant nous)
local Database = _G.LockProject_Database

if not Database then
    Console.Error("[Core] LockProject_Database not loaded! Check packages_requirements.")
    return
end

Player.Subscribe("Spawn", function(player)
    local steam_id = player:GetSteamID()
    local player_name = player:GetName()

    -- Cherche le joueur en BDD
    local data = Database:Get("players", steam_id)

    if not data then
        -- Nouveau joueur
        data = {
            steam_id = steam_id,
            name = player_name,
            first_seen = os.time(),
            connection_count = 1,
        }
        Console.Log("[Core] Nouveau joueur : " .. player_name)
    else
        -- Joueur connu
        data.connection_count = data.connection_count + 1
        data.last_seen = os.time()
        Console.Log("[Core] Retour de " .. player_name .. " (connexion #" .. data.connection_count .. ")")
    end

    Database:Set("players", steam_id, data)

    Chat.BroadcastMessage("Bienvenue " .. player_name .. " ! (connexion #" .. data.connection_count .. ")")
end)

Console.Log("[Core] Loaded.")