lib.callback.register('Kratos-Safezones:Bypass', function(source)
    if IsPlayerAceAllowed(source, Config.AcePermBypass) then
        return true
    end
    return false
end)
