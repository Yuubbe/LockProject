-- lockproject-core — Server entrypoint

Console.Log("[Core] LockProject démarre...")

Player.Subscribe("Spawn", function(player)
    local id = player:GetID()
    Console.Log("[Core] Joueur connecté: " .. tostring(id))
    Chat.BroadcastMessage("Bienvenue sur LockProject !")
end)

Console.Log("[Core] Loaded.")