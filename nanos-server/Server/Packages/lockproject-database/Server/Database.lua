-- lockproject-database — Database abstraction layer
--
-- Module Lua standard. Utilisé via :
--   local Database = require("lockproject-database/Server/Database")
--
-- API publique :
--   Database:Initialize()          → charge depuis PersistentData
--   Database:Get(table, id)        → 1 record par id, ou nil
--   Database:Set(table, id, data)  → upsert (création ou maj)
--   Database:Delete(table, id)     → supprime 1 record
--   Database:All(table)            → tous les records de la table
--   Database:Find(table, fn)       → filtre, équivalent WHERE
--   Database:NextId(table)         → génère un nouvel id auto-increment
--   Database:Flush()               → force la persistance disque

local Database = {
    _data = {},
    _initialized = false,
}

-- Initialise depuis PersistentData. À appeler UNE fois au boot.
function Database:Initialize()
    if self._initialized then
        Console.Warn("[Database] Already initialized, skipping.")
        return
    end

    local raw = Package.GetPersistentData()
    self._data = raw or {}

    -- Initialise les tables principales si absentes
    self._data.players   = self._data.players   or {}
    self._data.clubs     = self._data.clubs     or {}
    self._data.contracts = self._data.contracts or {}
    self._data._meta     = self._data._meta     or { last_ids = {} }

    self._initialized = true
    Console.Log("[Database] Initialized. Tables: players=" .. self:_count("players")
        .. ", clubs=" .. self:_count("clubs"))
end

-- Récupère 1 enregistrement par id. Retourne nil si absent.
function Database:Get(table_name, id)
    assert(self._initialized, "[Database] Not initialized. Call Initialize() first.")
    local t = self._data[table_name]
    if not t then return nil end
    return t[tostring(id)]
end

-- Upsert : crée ou met à jour. Écrit immédiatement sur disque (Phase 1, simple).
function Database:Set(table_name, id, data)
    assert(self._initialized, "[Database] Not initialized.")
    assert(type(data) == "table", "[Database] Data must be a table.")

    self._data[table_name] = self._data[table_name] or {}
    self._data[table_name][tostring(id)] = data

    self:Flush()
end

-- Supprime 1 enregistrement.
function Database:Delete(table_name, id)
    assert(self._initialized, "[Database] Not initialized.")
    if not self._data[table_name] then return end
    self._data[table_name][tostring(id)] = nil
    self:Flush()
end

-- Retourne tous les enregistrements d'une table sous forme de table { [id]=record }.
function Database:All(table_name)
    assert(self._initialized, "[Database] Not initialized.")
    return self._data[table_name] or {}
end

-- Filtre via une fonction prédicat. Retourne un array { record1, record2, ... }.
function Database:Find(table_name, predicate)
    assert(self._initialized, "[Database] Not initialized.")
    assert(type(predicate) == "function", "[Database] Predicate must be a function.")

    local results = {}
    local t = self._data[table_name] or {}
    for _, record in pairs(t) do
        if predicate(record) then
            table.insert(results, record)
        end
    end
    return results
end

-- Génère un nouvel id auto-increment pour une table.
function Database:NextId(table_name)
    assert(self._initialized, "[Database] Not initialized.")
    self._data._meta.last_ids[table_name] = (self._data._meta.last_ids[table_name] or 0) + 1
    return self._data._meta.last_ids[table_name]
end

-- Force l'écriture disque. Appelé à chaque Set/Delete pour l'instant.
-- À optimiser plus tard (batch toutes les X min).
-- IMPORTANT : on n'écrit PAS les tables/structures vides — nanos écrit "]" au lieu de "[]"
-- pour les tables vides, ce qui casse la relecture au boot suivant.
function Database:Flush()
    for key, value in pairs(self._data) do
        if type(value) == "table" and self:_hasDeepContent(value) then
            Package.SetPersistentData(key, value)
        end
    end
end

-- Helper privé : vérifie qu'une table contient au moins UNE valeur non-table-vide
-- (récursif, pour éviter d'écrire des structures imbriquées toutes vides comme _meta).
function Database:_hasDeepContent(t)
    if type(t) ~= "table" then return true end
    for _, v in pairs(t) do
        if type(v) ~= "table" then
            return true  -- une valeur primitive = du vrai contenu
        end
        if self:_hasDeepContent(v) then
            return true  -- une sous-table avec du contenu = OK
        end
    end
    return false
end

function Database:_count(table_name)
    local count = 0
    for _ in pairs(self._data[table_name] or {}) do count = count + 1 end
    return count
end
-- Pattern Lua standard : on retourne le module au lieu d'utiliser Package.Export
return Database