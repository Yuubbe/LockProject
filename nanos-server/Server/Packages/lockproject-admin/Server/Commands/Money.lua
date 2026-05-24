-- lockproject-admin — Money commands
-- Enregistre /balance, /givemoney, /removemoney
-- lockproject-admin — Money commands
-- Enregistre /balance, /givemoney, /removemoney

local Admin = _G.LockProject_Admin


-- /balance — affiche ton argent
Admin:RegisterCommand("balance", 0, "Affiche ton solde",
    function(player, args)
        Chat.SendMessage(player.nanos_player, "💰 Solde : " .. player:GetMoney() .. "¥")
    end
)

-- /givemoney <amount> — admin only
Admin:RegisterCommand("givemoney", 100, "Donne <amount>¥ au joueur (admin)",
    function(player, args)
        local amount = tonumber(args[1])
        if not amount or amount <= 0 then
            Chat.SendMessage(player.nanos_player, "Usage : /givemoney <amount>")
            return
        end
        local new_balance = player:AddMoney(amount)
        Chat.SendMessage(player.nanos_player, "✅ +" .. amount .. "¥. Nouveau solde : " .. new_balance .. "¥")
    end
)

-- /removemoney <amount> — admin only
Admin:RegisterCommand("removemoney", 100, "Retire <amount>¥ au joueur (admin)",
    function(player, args)
        local amount = tonumber(args[1])
        if not amount or amount <= 0 then
            Chat.SendMessage(player.nanos_player, "Usage : /removemoney <amount>")
            return
        end
        local ok = player:RemoveMoney(amount)
        if ok then
            Chat.SendMessage(player.nanos_player, "✅ -" .. amount .. "¥. Nouveau solde : " .. player:GetMoney() .. "¥")
        else
            Chat.SendMessage(player.nanos_player, "❌ Solde insuffisant (" .. player:GetMoney() .. "¥)")
        end
    end
)