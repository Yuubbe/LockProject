-- lockproject-core — Server entrypoint
--
-- Game-mode principal de LockProject.
-- Délègue la gestion des joueurs à lockproject-player.

Console.Log("[Core] LockProject démarre...")

-- Vérifie que les modules dépendants sont chargés
assert(_G.LockProject_Database, "[Core] Database not loaded")
assert(_G.LockProject_Players,  "[Core] Players not loaded")

Console.Log("[Core] Loaded.")