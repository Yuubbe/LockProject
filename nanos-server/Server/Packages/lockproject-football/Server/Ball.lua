-- lockproject-football — Ball management
--
-- Pour la Phase 2 prototype : tester la physique nanos sur un ballon.

local Ball = {
    _balls = {},  -- liste des ballons actifs
}

-- Diamètre standard d'un ballon de foot ≈ 22 cm
-- L'asset SM_Sphere de base fait 100 unités (1 mètre) de diamètre.
-- Donc échelle 0.22 pour avoir un ballon de taille réelle.
Ball.SCALE = 0.30  -- ballon plus généreux pour le test, ajustable

-- Spawn un ballon à une position donnée.
-- Spawn un ballon à une position donnée.
function Ball:Spawn(location)
    local rotation = Rotator(0, 0, 0)

    -- Prop(location, rotation, asset, collision_type, gravity_enabled, grab_mode, ccd_mode)
    -- - CollisionType.Normal : collision physique standard (essentiel pour interactions)
    -- - gravity_enabled = true
    -- - CCD (Continuous Collision Detection) = true → évite que le ballon traverse à grande vitesse
    local ball = Prop(
        location,
        rotation,
        "nanos-world::SM_Sphere",
        CollisionType.Normal,  -- ← LA CLÉ : collision activée
        true,                   -- gravity
        nil,                    -- grab_mode (défaut)
        CollisionType.Normal    -- ccd_mode (anti-tunneling)
    )

    -- Taille ballon de foot. On augmente un peu (0.30 = ~30cm)
    -- pour que la collision Character soit bien détectée
    ball:SetScale(Vector(Ball.SCALE, Ball.SCALE, Ball.SCALE))

    -- Stocke pour pouvoir cleanup
    table.insert(self._balls, ball)

    Console.Log("[Football] Ball spawned at ("
        .. math.floor(location.X) .. ", "
        .. math.floor(location.Y) .. ", "
        .. math.floor(location.Z) .. ") — total balls: " .. #self._balls)

    return ball
end

-- Détruit tous les ballons.
function Ball:ClearAll()
    local count = #self._balls
    for _, ball in ipairs(self._balls) do
        if ball:IsValid() then
            ball:Destroy()
        end
    end
    self._balls = {}
    Console.Log("[Football] Cleared " .. count .. " ball(s)")
    return count
end

-- Compte les ballons actifs.
function Ball:Count()
    return #self._balls
end

return Ball