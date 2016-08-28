apollo = {}
apollo.druid = {}
apollo.monk = {}
apollo.warrior = {}
apollo.paladin = {}
apollo.mage = {}
apollo.demonHunter = {}
apollo.groupNames = {}
apollo.aoeToggle = false
apollo.pauseToggle = false

local frame = CreateFrame("FRAME");
frame:RegisterEvent("PLAYER_ENTERING_WORLD");
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED");
--frame:RegisterEvent("GROUP_ROSTER_UPDATE");
--frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
function frame:OnEvent(event, arg1)
	apollo.rebindkeys = true
	if event == "PLAYER_ENTERING_WORLD" then
		for i=1,47 do
			local btn
			if i <= 5 then target = "party"..(i-1)
			elseif i <= 45 then target = "raid"..(i-5)
			elseif i == 46 then target = "target"
			elseif i == 47 then target = "targettarget"; end;
			if target == "party0" then target = "player"; end;
			apollo.groupNames[i] = target
			
			local btnName = "apolloTarget"..i
			if not _G[btnName] then btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate") else btn = _G[btnName]; end;
			btn:SetAttribute("type", "macro");
			btn:SetAttribute("macrotext", "/focus "..target)
			SetBinding(apollo.targetKeybinding[i])
			SetBindingClick(apollo.targetKeybinding[i], btnName)
		end
	end
	

end
frame:SetScript("OnEvent", frame.OnEvent);


function apollo_OnUpdate(self, elapsed)
	apollo.lastRun = apollo.lastRun or 0
--	if apollo.lastRun > GetTime() - .250 then return; end;
--	print("test")
	
	local target, ability
	if apollo.rebindkeys then
		apollo.getPlayerRotation()
		apollo.assignKeybindings()
		apollo.rebindkeys = false
	end
	
	if not apollo.pauseAddon() then 
		ability, target = apollo.skillController()
		target = apollo.targetController(target)
	end
	
	local a, t = ability, target
	
	if t then ColorDot:SetColorTexture(t/255,0,0,1); return; end;
	if a then ColorDot:SetColorTexture(a/255,a/255,a/255,1); return; end;
	
	apollo.lastRun = GetTime()
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
	if InCombatLockdown() then return; end;
	local playerClass = UnitClass("player")
	local playerSpec = select(2,GetSpecializationInfo(GetSpecialization()))
--	print(playerClass,playerSpec)
	
	apollo.skillRotation = {}
	if playerClass == "Druid" and playerSpec == "Restoration" then apollo.skillRotation = apollo.druid.restorationSkillRotation(); end;
	if playerClass == "Druid" and playerSpec == "Feral" then apollo.skillRotation = apollo.druid.feralSkillRotation(); end;
	if playerClass == "Monk" and playerSpec == "Windwalker" then apollo.skillRotation = apollo.monk.windwalkerSkillRotation(); end;
	if playerClass == "Demon Hunter" and playerSpec == "Havoc" then apollo.skillRotation = apollo.demonHunter.havocSkillRotation(); end;
	if playerClass == "Warrior" and playerSpec == "Arms" then apollo.skillRotation = apollo.warrior.armsSkillRotation(); end;
	if playerClass == "Warrior" and playerSpec == "Protection" then apollo.skillRotation = apollo.warrior.protectionSkillRotation(); end;
	if playerClass == "Paladin" and playerSpec == "Retribution" then apollo.skillRotation = apollo.paladin.retributionSkillRotation(); end;
	if playerClass == "Paladin" and playerSpec == "Holy" then apollo.skillRotation = apollo.paladin.holySkillRotation(); end;
	if playerClass == "Mage" and playerSpec == "Fire" then apollo.skillRotation = apollo.mage.fireSkillRotation(); end;
	
end

function apollo.assignKeybindings()
	if InCombatLockdown() then return end;
	local groupType, offset
	
--	if IsInRaid() == true then 
--		groupType = "raid"
--		offset = 0
--	else 
--		groupType = "party"
--		offset = -1
--	end

--[[
	for i=1,47 do
		local btn
		if i <= 5 then target = "party"..(i-1)
		elseif i <= 45 then target = "raid"..(i-5)
		elseif i == 46 then target = "target"
		elseif i == 47 then target = "targettarget"; end;
		if target == "party0" then target = "player"; end;
		apollo.groupNames[i] = target
		
		local btnName = "apolloTarget"..i
		if not _G[btnName] then btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate") else btn = _G[btnName]; end;
		btn:SetAttribute("type", "macro");
		btn:SetAttribute("macrotext", "/focus "..target)
		SetBinding(apollo.targetKeybinding[i])
		SetBindingClick(apollo.targetKeybinding[i], btnName)
	end
]]
	--------------------------------------------------------------------------------------
	local skillRotation = apollo.skillRotation or {}
	for i in ipairs(skillRotation) do
		local btn
		local btnName = "skill"..i
		local skillName = select(2, skillRotation[i]("player"))
		if not _G[btnName] then btn = CreateFrame("Button", btnName, UIParent, "SecureActionButtonTemplate") else btn = _G[btnName]; end;
		btn:SetAttribute("type", "macro")
		if skillName == "Healing Touch" then 
			btn:SetAttribute("macrotext", "/console autounshift 0\n/use [nochanneling,nocursor,@focus]"..skillName.."\n/console autounshift 1")
		elseif skillName == "Swiftmend" then
			btn:SetAttribute("macrotext", "/stopcasting\n/use [nochanneling,nocursor,@focus]"..skillName)
		else
			btn:SetAttribute("macrotext", "/use [nochanneling,nocursor,@focus]"..skillName)
		end
		SetBinding(apollo.abilityKeybinding[i])
		SetBindingClick(apollo.abilityKeybinding[i], btnName)
	end
	
end

function apollo.pauseAddon()
	local pauseSpells = {145205,2120}
	local eating = {"Refreshment", "Drink", "Food"}
	
	for i,v in ipairs(pauseSpells) do
		if IsCurrentSpell(v) then return true; end;
	end
	
	for i,v in ipairs(eating) do
		if UnitBuff("player",v) then return true; end;
	end
	
	if ChatFrame1EditBox:IsVisible() then return true; end;
	if LootFrame:IsVisible() then return true; end;
	if apollo.pauseToggle then return true; end;
	
	return false
end

function apollo.pauseButton()
	apollo.pauseToggle = not apollo.pauseToggle
	if not apollo.pauseToggle then print("Apollo is ENABLED") else print("Apollo is DISABLED"); end;
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

function apollo.lowMana()
	if (UnitPower("player",0) / UnitPowerMax("player",0)) < .1 then return true else return false; end;
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

function apollo.getFury()
	return UnitPower("player",17)
end

function apollo.canInterupt(target)
	local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(target)
	if name and (not notInterruptible) then return true else return false; end;
end

function apollo.aoeMode()
	apollo.aoeToggle = not apollo.aoeToggle
	if apollo.aoeToggle then print("AoE Mode: ACTIVE") else print("AoE Mode: INACTIVE"); end;
end

function apollo.affectingCombat(target)
	return UnitAffectingCombat(target) or false
end

function apollo.isMoving(target)
	if GetUnitSpeed(target) == 0 then return false else return true; end;
end

function apollo.isTank(target)
	if ((UnitGroupRolesAssigned(target) == "TANK" or GetUnitName(target) == "Oto the Protector")) then return true else return false; end;
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
	
	local spellCast = (apollo.notDead(target)) and (UnitIsUnit("player",target)) and (cooldown < 2) and (count > 0) and (apollo.unitHealthPct("player") < .6)
	
	return spellCast, spellName
end

function apollo.healEternalAmuletOfTheRedeemed(target)
	local spellName = "Eternal Amulet of the Redeemed"
	local cooldown = select(2,GetItemCooldown(122663))
	local count = GetItemCount(122663)
	
	local spellCast = (apollo.notDead(target)) and (UnitIsUnit("player",target)) and (cooldown < 2) and (count > 0) and (apollo.unitHealthPct("player") < .6) and IsEquippedItem(122663)
	
	return spellCast, spellName
end

function apollo.buffWhispersOfInsanity(target)
	local spellName = "Oralius' Whispering Crystal"
	local cooldown = select(2,GetItemCooldown(118922))
	local count = GetItemCount(118922)
	local elixirBuff
	local elixirBuffList = {"Whispers of Insanity", "Draenic Intellect Flask"}
	for i,v in ipairs(elixirBuffList) do
		elixirBuff = UnitBuff("player",v)
		if elixirBuff then break; end;
	end
	
	local spellCast = (apollo.notDead(target)) and (UnitIsUnit("player",target)) and (cooldown < 2) and (count > 0) and (not elixirBuff)
	
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