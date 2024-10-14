LoopAsync(100, function()

    if not FindFirstOf("World"):IsValid() then
        return false
    end

    local tryWorld = FindFirstOf("World"):GetFullName()
    if tryWorld == "World /Temp/Untitled_0.Untitled" then
        return false
    end

    local Json = require("libs/Json")
    local Fguid = require("constructors/Fguid")
    local data = Json.decode(io.open("Mods\\SphereZones\\Scripts\\Data\\zones.json", "r"):read("*all"))

    local PalMapObjectManager = FindFirstOf("PalMapObjectManager") ---@type UPalMapObjectManager
    local palUtility = StaticFindObject("/Script/Pal.Default__PalUtility") ---@type UPalUtility

    ---@param array V[]
    ---@param valueToCheck any
    ---@return boolean
    local function ArrayContainValue(array, valueToCheck)
        for _, value in ipairs(array) do
            if value == valueToCheck then
                return true
            end
        end
        return false
    end

    local function insidePolygon(polygon, point)
        local oddNodes = false
        local j = #polygon
        for i = 1, #polygon do
            if (polygon[i].y < point.y and polygon[j].y >= point.y or polygon[j].y < point.y and polygon[i].y >= point.y) then
                if (polygon[i].x + ( point.y - polygon[i].y ) / (polygon[j].y - polygon[i].y) * (polygon[j].x - polygon[i].x) < point.x) then
                    oddNodes = not oddNodes;
                end
            end
            j = i;
        end
        return oddNodes 
    end

    ---@param location FVector
    ---@return table
    local function GetCurrentZone(location)
        for _, zone in ipairs(data["zones"]) do

            if insidePolygon(zone["points"], { x = location.Y,  y =location.X }) then
                return zone
            end

        end
        return data["global"]
    end

    ---@param instance APalCharacter
    ---@return string
    local function GetInstanceType(instance)

        if instance == nil then
            return "Undefined"
        elseif palUtility:IsOtomo(instance) then
            return "Otomo"
        elseif type(instance.PlayerCameraYaw) == "number" then
            return "Player"
        elseif palUtility:IsBaseCampPal(instance) then
            return "BaseCampPal"
        elseif palUtility:IsPalMonster(instance) then 
            return "PalMonster"
        elseif palUtility:IsWildNPC(instance) then
            return "WildNPC"
        else
            return "Undefined"
        end
    end

    ---@param attacker string
    ---@param target string
    ---@param zone table
    ---@return boolean
    local function IsDamageValid(attacker, target, zone)
        return ArrayContainValue(zone["permissions"][attacker]["damage"], target) 
    end

    RegisterHook("/Script/Pal.PalPlayerState:SendDamage_ToServer", function(argument1, argument2, argument3)
        local palCharacter = argument2:get() ---@type APalCharacter
        local info = argument3:get() ---@type FPalDamageInfo

        if palCharacter:IsValid() and info:IsValid() then
            --I don't know why sometimes the attacker comes with nil, if a bug happens, maybe that's what's causing it
            if info.attacker:IsValid() then
                local attacker =  GetInstanceType(info.attacker)
                local target = GetInstanceType(palCharacter) 
                local zone = GetCurrentZone(info.HitLocation)

                if not IsDamageValid(attacker, target, zone) then
                    argument2:set(nil)
                end
            end
        end
    end)

    RegisterHook("/Script/Pal.PalNetworkMapObjectComponent:RequestDamageMapObject_ToServer", function(argument1, argument2, argument3)
        local instanceId = argument2:get() ---@type FGuid
        local info  = argument3:get() ---@type FPalDamageInfo

        if instanceId:IsValid() and info:IsValid() then

            if info.attacker:IsValid() then
                local instance = PalMapObjectManager:FindModel(Fguid.translate(instanceId))
                if instance.BuildObjectId ~= FName("None") then
                    local attacker =  GetInstanceType(info.attacker)
                    local target = "Structure"
                    local zone = GetCurrentZone(info.HitLocation)
                    
                    if not IsDamageValid(attacker, target, zone) then
                        instanceId.A = nil
                        instanceId.B = nil
                        instanceId.C = nil
                        instanceId.D = nil
                    end
                end
            end
        end
    end)

    RegisterHook("/Script/Pal.PalBuilderComponent:RequestBuild_ToServer", function(argument1, argument2, argument3)
        local self = argument1:get() ---@type UPalBuilderComponent

        if self:IsValid() then
            if not self:GetOuter():GetPalPlayerController().bAdmin then
                local location = argument3:get() ---@type FVector
                local zone = GetCurrentZone(location)

                if not ArrayContainValue(zone["permissions"]["Player"]["world"], "Build") then
                    argument2:set(FName("")) ---@type FName
                end
            end
        end
    end)

    RegisterHook("/Script/Pal.PalNetworkMapObjectComponent:RequestDismantleObject_ToServer", function(argument1, argument2)
        local self = argument1:get() ---@type UPalNetworkMapObjectComponent
        if not self:GetOwner().Owner.bAdmin then
            local instanceId = argument2:get() ---@type FGuid
            local instance = PalMapObjectManager:FindModel(Fguid.translate(instanceId))
            local zone = GetCurrentZone(instance.InitialTransformCache.Translation)

            if not ArrayContainValue(zone["permissions"]["Player"]["world"], "Dismantle") then
                instanceId.A = nil
                instanceId.B = nil
                instanceId.C = nil
                instanceId.D = nil
            end
        end
    end)

    return true
end)