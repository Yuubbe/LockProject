-- lockproject-admin — Commands registry + permissions
--
-- Niveaux de permission :
--   0   = joueur (tout le monde)
--   1   = mod
--   10  = admin
--   100 = owner

local Admin = {
    _commands = {},  -- name → { handler, level, description }
    _admins = {
        -- Hardcoded pour le dev Phase 1. À migrer vers BDD plus tard.
        -- Format : steam_id (string) → permission_level (number)
        ["76561198411031476"] = 100,  -- Yuu (owner)
    },
}

-- Préfixe des commandes (configurable plus tard)
Admin.PREFIX = "/"

-- Enregistre une commande.
-- @param name : nom de la commande (sans le préfixe, ex: "givemoney")
-- @param level : permission minimum requise
-- @param description : pour /help
-- @param handler : function(player, args) → l'instance Player + args array
function Admin:RegisterCommand(name, level, description, handler)
    assert(type(name) == "string", "[Admin] Command name must be a string")
    assert(type(level) == "number", "[Admin] Level must be a number")
    assert(type(handler) == "function", "[Admin] Handler must be a function")

    self._commands[name] = {
        handler = handler,
        level = level,
        description = description or "",
    }
    Console.Log("[Admin] Command registered: /" .. name .. " (level " .. level .. ")")
end

-- Récupère une commande par son nom.
function Admin:GetCommand(name)
    return self._commands[name]
end

-- Récupère toutes les commandes accessibles à un niveau donné.
function Admin:GetAvailableCommands(level)
    local result = {}
    for name, cmd in pairs(self._commands) do
        if level >= cmd.level then
            table.insert(result, { name = name, level = cmd.level, description = cmd.description })
        end
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

-- Retourne le niveau de permission d'un joueur (par steam_id).
function Admin:GetPermissionLevel(steam_id)
    return self._admins[tostring(steam_id)] or 0
end

-- Vérifie qu'un joueur a accès à une commande.
function Admin:CanExecute(steam_id, command_name)
    local cmd = self:GetCommand(command_name)
    if not cmd then return false, "Unknown command" end
    local level = self:GetPermissionLevel(steam_id)
    if level < cmd.level then
        return false, "Permission denied (need level " .. cmd.level .. ", you have " .. level .. ")"
    end
    return true
end

-- Parse une ligne de chat. Retourne (cmd_name, args_array) ou nil si pas une commande.
function Admin:ParseChatLine(line)
    if line:sub(1, #Admin.PREFIX) ~= Admin.PREFIX then
        return nil
    end
    local without_prefix = line:sub(#Admin.PREFIX + 1)
    local parts = {}
    for word in without_prefix:gmatch("%S+") do
        table.insert(parts, word)
    end
    if #parts == 0 then return nil end
    local cmd_name = parts[1]:lower()
    table.remove(parts, 1)
    return cmd_name, parts
end

-- Exécute une commande pour un joueur.
function Admin:Execute(player_instance, command_name, args)
    local cmd = self:GetCommand(command_name)
    if not cmd then
        Chat.SendMessage(player_instance.nanos_player, "Commande inconnue : /" .. command_name)
        return
    end

    local can, err = self:CanExecute(player_instance:GetSteamID(), command_name)
    if not can then
        Chat.SendMessage(player_instance.nanos_player, "❌ " .. err)
        return
    end

    -- Wrap dans pcall pour pas crasher tout le chat sur un bug de commande
    local ok, result = pcall(cmd.handler, player_instance, args)
    if not ok then
        Console.Warn("[Admin] Error executing /" .. command_name .. ": " .. tostring(result))
        Chat.SendMessage(player_instance.nanos_player, "⚠ Erreur lors de l'exécution.")
    end
end

return Admin