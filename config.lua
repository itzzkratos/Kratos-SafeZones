Config = {}

Config.SafeZones = {
    {
        name = "sandy pd",
        points = {
            vec3(1822.1489, 3637.7878, 35.4591),
            vec3(1795.5270, 3682.4443, 35.4591),
            vec3(1857.7830, 3719.3379, 35.4591),
            vec3(1879.7612, 3683.4700, 35.4591),
        },
        thickness = 10,
        maxSpeed = 30.0,
        debug = false
    }
}

Config.Notify = function(msg, type)
    lib.notify({
        title = "Kratos SafeZones",
        description = msg,
        type = type,
        position = "center-right",
        duration = 5000
    })
end 

Config.AcePermBypass = "Kratos-SafeZones:Bypass"