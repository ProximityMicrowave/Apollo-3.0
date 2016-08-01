apollo = {}
apollo.druid = {}
apollo.groupNames = {}
apollo.aoeToggle = false

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
function frame:OnEvent(event, arg1)	
	apollo.skillRotation = {}
	apollo.getPlayerRotation()
	apollo.assignKeybindings()
	
end
frame:SetScript("OnEvent", frame.OnEvent);

function apollo_OnUpdate(self, elapsed)
	local r, g, b, target, ability
	
	ability, target = apollo.skillController()
	target = apollo.targetController(target)
	
	local a, t = ability, target
	
	if t then ColorDot:SetColorTexture(t/255,0,0,1); return; end;
	if a then ColorDot:SetColorTexture(a/255,a/255,a/255,1); return; end;
		
	ColorDot:SetColorTexture(0,0,0,1)
end

function apollo.skillController()
	local skillRotation = apollo.skillRotation
	local priorityTarget = apollo.sortPriority()
	
	for i in ipairs(skillRotation) do
		for j in ipairs(priorityTarget) do
			if skillRotation[i](priorityTarget[j]) then return i, priorityTarget[j]; end;
		end
	end
	
end

function apollo.targetController(target)
	local groupNames = apollo.groupNames
	if target == nil or UnitIsUnit("focus", target) then return false; end;
	
	for i in ipairs(groupNames) do
		if groupNames[i] == target then return i; end
	end
	return false
end

function apollo.getPlayerRotation()
	local playerClass = UnitClass("player")
	local playerSpec = select(2,GetSpecializationInfo(GetSpecialization()))
	
	if playerClass == "Druid" and playerSpec == "Restoration" then apollo.skillRotation = apollo.druid.restorationSkillRotation(); end;
	if playerClass == "Druid" and playerSpec == "Feral" then apollo.skillRotation = apollo.druid.feralSkillRotation(); end;
end

function apollo.assignKeybindings()
	if InCombatLockdown() then return print("Error: Keyrebinding Failed"); end;
	local groupType, offset
	
	if IsInRaid() == true then 
		groupType = "raid"
		offset = 0
	else 
		groupType = "party"
		offset = -1
	end

	for i=1,41 do
		local btn
		local target = groupType..(i + offset)
		if target == "party0" then target = "player"; end;
		if i == 41 then target = "target"; end;
		apollo.groupNames[i] = target
		
		local btnName = "apolloTarget"..i
		if not _G[btnName] then btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate") else btn = _G[btnName]; end;
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..target)
		SetBinding(apollo.targetKeybinding[i])
		SetBindingClick(apollo.targetKeybinding[i], btnName)
	end
	--------------------------------------------------------------------------------------
	local skillRotation = apollo.skillRotation or {}
	for i in ipairs(skillRotation) do
		local btn
		local btnName = "skill"..i
		local skillName = select(2, skillRotation[i]("player"))
		if not _G[btnName] then btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate") else btn = _G[btnName]; end;
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
	
--	table.insert(priority, "target")

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

function apollo.hasThreat(target)
	local threat = UnitThreatSituation(target) or 0
	if threat >= 2 then return true else return false; end;
end

function apollo.isFriend(target)
	return UnitIsFriend("player",target)
end

function apollo.offCooldown(spellName)
	local cooldown = select(2,GetSpellCooldown(spellName))
	if (cooldown < 2) then return true else return false; end;
end

function apollo.getEnergy()
	if UnitBuff("player","Clearcasting") then return 150; end;
	return UnitPower("player",3)
end

function apollo.getComboPoints()
	return UnitPower("player",4)
end

function apollo.canInterupt(target)
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(target)
	if name and (not notInterruptible) then return true else return false; end;
end

function apollo.aoeMode()
	apollo.aoeToggle = not apollo.aoeToggle
	if apollo.aoeToggle then print("AoE Mode: ACTIVE") else print("AoE Mode: INACTIVE"); end;
end

function apollo.lowHealthCount(health, spellName)
	--if the input is between 0 and 1 the function will read it as a percentage, and check how many in the group have less than the input in percentage health.
	--if the input is greater than 1 the function will read it as a raw value and return how many in the group have less than the input value in raw health.
	--if the input is less than zero (a negative number) then it will check how many group members are missing more than that amount of health
	
	local count = 0
	
	if health < 0 then
		health = health * -1
		for i,v in ipairs(apollo.groupNames) do
			if (apollo.missingHealth(v) >= health and UnitExists(v)) and apollo.inRange(spellName, apollo.groupNames[i]) then count = count + 1; end;
		end
	elseif health <= 1 then
		for i,v in ipairs(apollo.groupNames) do
			if (apollo.unitHealthPct(v) <= health and UnitExists(v)) and apollo.inRange(spellName, apollo.groupNames[i]) then count = count + 1; end;
		end
	elseif health > 1 then
		for i,v in ipairs(apollo.groupNames) do
			if (UnitHealth(v) <= health and UnitExists(v)) and apollo.inRange(spellName, apollo.groupNames[i]) then count = count + 1; end;
		end
	end
		
	return count
end

function apollo.healHealthstone(target)
	local spellName = "Healthstone"
	local cooldown = select(2,GetItemCooldown(5512))
	local count = GetItemCount(5512)
	
	local spellCast = (apollo.notDead(target)) and (UnitIsUnit("player",target)) and (cooldown < 2) and (count > 0) and (apollo.unitHealthPct(target) < .7)
	
	return spellCast, spellName
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