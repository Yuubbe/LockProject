-- lockproject-player — Players registry
--
-- Registre des joueurs actuellement connectés.
-- Indexé par steam_id pour lookup O(1).
--
-- Usage depuis un autre package :
--   local Players = _G.LockProject_Players
--   local p = Players:Get(steam_id)
--   p:AddMoney(100)

local Players = {
    _connected = {},  -- steam_id → instance Player
}

-- Ajoute un joueur au registre.
function Players:Add(player_instance)
    self._connected[player_instance:GetSteamID()] = player_instance
end

-- Retire un joueur du registre.
function Players:Remove(steam_id)
    self._connected[steam_id] = nil
end

-- Récupère un joueur connecté par son steam_id.
function Players:Get(steam_id)
    return self._connected[steam_id]
end

-- Retourne tous les joueurs connectés (array).
function Players:GetAll()
    local result = {}
    for _, p in pairs(self._connected) do
        table.insert(result, p)
    end
    return result
end

-- Compte les joueurs connectés.
function Players:Count()
    local count = 0
    for _ in pairs(self._connected) do count = count + 1 end
    return count
end

return Players