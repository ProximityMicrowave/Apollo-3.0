local AD = apollo.druid
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown

function AD.restorationSkillRotation()
	local skillRotation = {
		AD.healNaturesCure,
		AD.healRenewal,
		apollo.healHealthstone,
		AD.healSwiftmend,
		AD.healTranquility,
		AD.healWildGrowth,
		AD.healLifeBloom,
		AD.healRegrowth,
		AD.healRejuvenation,
		AD.healHealingTouch,
		AD.attackSolarWrath,
	}
	return skillRotation
end

function AD.healHealingTouch(target)
	local spellName = "Healing Touch"
	local heal = (GetSpellBonusHealing() * 4)
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (missingHealth(target) > heal)
	
	return spellCast, spellName
end

function AD.healRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)") and UnitBuff(target,"Rejuvenation") and true
	else unitBuff = UnitBuff(spellTarget,"Rejuvenation"); end
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not unitBuff) and ((unitHealthPct(target) < .9) or (hasThreat(target)))

	return spellCast, spellName
end

function AD.attackSolarWrath(target)
	local spellName = "Solar Wrath"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName))
	
	return spellCast, spellName
end

function AD.healNaturesCure(target)
	local spellName = "Nature's Cure"
	
	local debuff = false
	local debuffList = {"Aqua Bomb", "Shadow Word: Pain", "Corruption", "Drain Life", "Curse of Exhaustion", "Immolate", "Conflagrate", "Dancing Flames", "Withering Flames", "Salve of Toxic Fumes", "Felfire Shock", "Time Lapse", "Subjugate", "Flame Buffet", "Veil of Shadow", "Venom Spit", "Eyes in the Dark", "Curse of Tongues", "Shiver", "Beast's Mark", "Poisoned Spear", "Pustulant Flesh", "Poison Nova", "Unstable Afliction"}
	
	for i,v in ipairs(debuffList) do
		if UnitDebuff(target,v) then debuff = true; break; end;
	end
	if UnitDebuff(target,"Unstable Affliction") then debuff = false; end;
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and debuff and (offCooldown(spellName))
	
	return spellCast, spellName
end

function AD.healRegrowth(target)
	local spellName = "Regrowth"
	local clearcasting = UnitBuff("player","Clearcasting")
	local currentSpeed = GetUnitSpeed("player")
	
	AD.lastRegrowth = AD.lastRegrowth or 0
	if UnitCastingInfo("player") == "Regrowth" then AD.lastRegrowth = GetTime(); end;
	
	local conditionSet1 = ((notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and isFriend(target))
	local conditionSet2 = ((unitHealthPct(target) < 1) and (currentSpeed == 0) and (AD.lastRegrowth < GetTime() - 1) and (clearcasting))
	local conditionSet3 = ((hasThreat(target)) and (unitHealthPct(target) < .7))
	local spellCast = conditionSet1 and (conditionSet2 or conditionSet3)
	
	return spellCast, spellName
end

function AD.healLifeBloom(target)
	local spellName = "Lifebloom"
	local unitBuff = false
	for i,v in ipairs(apollo.groupNames) do
		if (UnitExists(v)) then
			unitBuff = (UnitBuff(v,"Lifebloom"))
			if unitBuff then break; end;
		end
	end
	
	local conditionSet1 = ((notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and isFriend(target))
	local conditionSet2 = (hasThreat(target)) and (not unitBuff)
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

function AD.healRenewal(target)
	local spellName = "Renewal"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .7)
	
	return spellCast, spellName
end

function AD.Healthstone(spellTarget, rebind)
	if spellTarget == nil or spellTarget == false then spellTarget = "player"; end;
	local __func__ = "Apollo.Druid.Healthstone"
	
	local spellCast = false
	local spellName = "Healthstone"
	local keybinding = 10
	if rebind == true then Apollo.CreateSkillButtons(__func__, spellName, "focus", keybinding);return; end;
	if (not UnitExists(spellTarget)) or spellTarget ~= "player" then return false, 0, keybinding; end;
	
	local isDead = UnitIsDeadOrGhost(spellTarget)
	local inRange = IsSpellInRange(spellName,spellTarget)
	local isUsable,noMana = IsUsableSpell(spellName)
	local unitHealthPct = Apollo.UnitHealthPct(spellTarget)
	local cooldown = select(2,GetItemCooldown(5512))
	local count = GetItemCount(5512)
	
--	print(cooldown)
	if (not isDead) 
	and (unitHealthPct < .7)
	and (cooldown < 2)
	and (count > 0)
	then spellCast = true; end;

	return spellCast, spellHeal, keybinding
end

function AD.healSwiftmend(target)
	local spellName = "Swiftmend"
	local spellCast = ((notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and isFriend(target) and (offCooldown(spellName)) and (unitHealthPct(target) < .3))
	
	return spellCast, spellName
end

function AD.healTranquility(target)
	local spellName = "Tranquility"
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= 3))
	
	return spellCast, spellName
end

function AD.healWildGrowth(target)
	local spellName = "Wild Growth"
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= 3))
	
	return spellCast, spellName
end
