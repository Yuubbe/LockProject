-- lockproject-football — Server entrypoint

Console.Log("[Football] Loading...")

local Ball = require("Ball.lua")

-- Expose globalement
_G.LockProject_Ball = Ball

-- ── Commandes admin liées au foot ──────────────────────────────

local Admin = _G.LockProject_Admin

-- /spawnball — spawn un ballon devant ton perso
Admin:RegisterCommand("spawnball", 100, "Spawn un ballon devant toi",
    function(player, args)
        local character = player:GetCharacter()
        if not character then
            Chat.SendMessage(player.nanos_player, "❌ Pas de character")
            return
        end

        -- Calcule une position devant le perso (200 unités devant, 100 au-dessus)
        local loc = character:GetLocation()
        local rot = character:GetRotation()
        local forward = rot:GetForwardVector()
        local spawn_loc = Vector(
            loc.X + forward.X * 200,
            loc.Y + forward.Y * 200,
            loc.Z + 100  -- au-dessus du sol pour qu'il tombe
        )

        Ball:Spawn(spawn_loc)
        Chat.SendMessage(player.nanos_player, "⚽ Ballon spawné (total: " .. Ball:Count() .. ")")
    end
)

-- /clearballs — détruit tous les ballons
Admin:RegisterCommand("clearballs", 100, "Détruit tous les ballons",
    function(player, args)
        local count = Ball:ClearAll()
        Chat.SendMessage(player.nanos_player, "🧹 " .. count .. " ballon(s) nettoyé(s)")
    end
)

-- /ballcount — affiche le nombre de ballons
Admin:RegisterCommand("ballcount", 0, "Nombre de ballons actifs",
    function(player, args)
        Chat.SendMessage(player.nanos_player, "⚽ " .. Ball:Count() .. " ballon(s) actif(s)")
    end
)

Console.Log("[Football] Loaded.")