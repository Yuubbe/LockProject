-- lockproject-player — Player class
--
-- Classe Player. Représente un joueur en RAM, synchronisé avec la BDD.
-- OOP Lua standard (table + metatables), pas de NanosOOP.
--
-- Usage :
--   local p = Player.new(nanos_player_entity)
--   p:LoadFromDatabase()
--   p:AddMoney(100)
--   p:Save()

local Database = _G.LockProject_Database
assert(Database, "[Player] Database not loaded. Check packages_requirements.")

-- Définition de la classe
local Player = {}
Player.__index = Player

-- Constantes
Player.STARTING_MONEY = 0  -- pour l'instant, l'économie viendra plus tard

-- Constructor
-- @param nanos_player : l'entité Player de nanos (passée par Player.Subscribe)
function Player.new(nanos_player)
    local self = setmetatable({}, Player)

    self.nanos_player    = nanos_player
    self.steam_id        = nanos_player:GetSteamID()
    self.name            = nanos_player:GetName()

    -- Champs persistés (chargés depuis BDD)
    self.money            = Player.STARTING_MONEY
    self.connection_count = 0
    self.first_seen       = nil
    self.last_seen        = nil
    self.is_new           = false

    return self
end

-- Charge les données depuis la BDD. Crée le record si nouveau joueur.
function Player:LoadFromDatabase()
    local data = Database:Get("players", self.steam_id)

    if not data then
        -- Nouveau joueur
        self.is_new           = true
        self.money            = Player.STARTING_MONEY
        self.connection_count = 1
        self.first_seen       = os.time()
        self.last_seen        = os.time()

        Console.Log("[Player] Nouveau joueur : " .. self.name)
    else
        -- Joueur connu
        self.is_new           = false
        self.money            = data.money or Player.STARTING_MONEY
        self.connection_count = (data.connection_count or 0) + 1
        self.first_seen       = data.first_seen or os.time()
        self.last_seen        = os.time()

        Console.Log("[Player] Retour de " .. self.name
            .. " (connexion #" .. self.connection_count
            .. ", argent: " .. self.money .. ")")
    end

    -- Sauvegarde immédiate (incrémente connection_count + last_seen)
    self:Save()
end

-- Sauvegarde sur disque.
function Player:Save()
    Database:Set("players", self.steam_id, {
        steam_id         = self.steam_id,
        name             = self.name,
        money            = self.money,
        connection_count = self.connection_count,
        first_seen       = self.first_seen,
        last_seen        = self.last_seen,
    })
end

-- Getters
function Player:GetMoney()
    return self.money
end

function Player:GetName()
    return self.name
end

function Player:GetSteamID()
    return self.steam_id
end

function Player:IsNew()
    return self.is_new
end

-- Mutators
function Player:AddMoney(amount)
    assert(type(amount) == "number", "[Player] AddMoney: amount must be a number")
    self.money = self.money + amount
    self:Save()
    return self.money
end

function Player:RemoveMoney(amount)
    assert(type(amount) == "number" and amount >= 0, "[Player] RemoveMoney: amount must be a positive number")
    if self.money < amount then
        return false  -- pas assez d'argent
    end
    self.money = self.money - amount
    self:Save()
    return true
end

-- Placeholder pour la suite (Phase 3 : CDF)
function Player:IsCDF()
    return false  -- TODO : implémenter quand on aura lockproject-cdf
end

return Player