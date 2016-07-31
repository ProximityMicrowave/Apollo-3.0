apollo = {}
apollo.druid = {}
apollo.groupNames = {}

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
function frame:OnEvent(event, arg1)	
	apollo.getPlayerRotation()
	apollo.assignKeybindings()
	
end
frame:SetScript("OnEvent", frame.OnEvent);

function apollo_OnUpdate(self, elapsed)
	local r, g, b, idealTarget
	r, g, b = 0, 0, 0
	
	ColorDot:SetColorTexture(r,g,b,1)
end

function apollo.getPlayerRotation()
	local playerClass = UnitClass("player")
	local playerSpec = select(2,GetSpecializationInfo(GetSpecialization()))
		
	if playerClass == "Druid" and playerSpec == "Restoration" then apollo.skillRotation = {apollo.druid.healHealingTouch, apollo.druid.regrowth}; end;
end

function apollo.assignKeybindings()
	if InCombatLockdown() then return; end;
	local groupType, offset
	
	if IsInRaid() == true then 
		groupType = "raid"
		offset = 0
	else 
		groupType = "party"
		offset = -1
	end

	for i=1,40 do
		local target = groupType..(i + offset)
		if target == "party0" then target = "player"; end;
		apollo.groupNames[i] = target
		
		local btnName = "apolloTarget"..i
		local btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..target)
		SetBinding(apollo.targetKeybinding[i])
		SetBindingClick(apollo.targetKeybinding[i], btnName)
	end
	--------------------------------------------------------------------------------------
	local skillRotation = apollo.skillRotation or {}
	for i in ipairs(skillRotation) do
		local btnName = "skill"..i
		local skillName = select(2, skillRotation[i]())
		local btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate")
		btn:SetAttribute("type", "macro")
		btn:SetAttribute("macrotext", "/use [nochanneling,@focus]"..skillName)
		SetBinding(apollo.abilityKeybinding[i])
		SetBindingClick(apollo.abilityKeybinding[i], btnName)
	end
	
end

function apollo.sortPriority()
	local priority = {}
	local z = {}
	
	for i, v in ipairs(apollo.groupNames) do
		if UnitExists(apollo.groupNames[i]) then z[apollo.groupNames[i]] = apollo.unitHealthPct(apollo.groupNames[i]); end;
	end;
	
	
	i = 1; for k,v in spairs(z, function(t,a,b) return t[b] > t[a] end) do
		priority[i] = k
		i = i + 1;
	end;
	
	table.insert(priority, "target")

	return priority

end

function apollo.unitHealthPct(target)

	local health = UnitHealth(target)
	local healthMax = UnitHealthMax(target)
	local incomingHealth = UnitGetIncomingHeals(target) or 0
	
	local healthPct = (health + incomingHealth) / healthMax
--	if UnitDebuff(target,"Gift of the Doomsayer") then healthPct = 1; end;
	
	return healthPct
end

function apollo.notDead(target)
	return (not UnitIsDeadOrGhost(target)) or false
end

function apollo.inRange(spellName, target)
	local inRange = IsSpellInRange(spellName, target)
	if inRange == 1 then return true else return false; end;
end

function apollo.isUsable(spellName)
	local isUsable,noMana = IsUsableSpell(spellName)
	return isUsable and not noMana;
end

function apollo.missingHealth(target)
	local health, healthMax, incomingHealth = UnitHealth(target), UnitHealthMax(target), UnitGetIncomingHeals(target) or 0
	return (healthMax - (health + incomingHealth))
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end