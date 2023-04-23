local isShaking = false
local gasPressStartTime = 0

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        local ped = PlayerPedId(-1)
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped)
            local throttle = GetControlValue(2, 71) / 128 -- Get the throttle value (W key) from input group 2
            local speed = GetEntitySpeed(vehicle) * 3.6

            if DoesEntityExist(vehicle) then
                if throttle > 0 and speed >= Config.SpeedThreshold and speed < Config.MaxSpeed then
                    if not isShaking and gasPressStartTime == 0 then
                        gasPressStartTime = GetGameTimer()
                    elseif isShaking and GetGameTimer() - gasPressStartTime >= Config.GasPressDuration then
                        StopGameplayCamShaking(0)
                        isShaking = false
                        gasPressStartTime = 0
                    elseif not isShaking and GetGameTimer() - gasPressStartTime >= Config.GasPressDuration then
                        isShaking = true
                        ShakeGameplayCam('SKY_DIVING_SHAKE', Config.ShakeAmplitude)
                        Citizen.Wait(Config.ShakeDuration)
                        StopGameplayCamShaking(0)
                        isShaking = false
                        gasPressStartTime = 0
                    end
                elseif speed >= Config.MaxSpeed and isShaking then
                    StopGameplayCamShaking(0)
                    isShaking = false
                    gasPressStartTime = 0
                elseif throttle == 0 and speed < Config.SpeedThreshold and isShaking then
                    StopGameplayCamShaking(0)
                    isShaking = false
                    gasPressStartTime = 0
                end
            end
        else
            StopGameplayCamShaking(0)
            isShaking = false
            gasPressStartTime = 0
        end
    end
end)
