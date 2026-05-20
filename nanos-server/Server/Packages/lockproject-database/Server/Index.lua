-- lockproject-database — Server entrypoint

Console.Log("[Database] Loading...")

-- Charge le module
local Database = require("Database.lua")

-- Le rend disponible globalement pour les autres packages
_G.LockProject_Database = Database

-- Initialise au boot
Database:Initialize()

Console.Log("[Database] Loaded.")