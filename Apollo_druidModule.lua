local AD = apollo.druid
local notDead = apollo.notDead
local inRange = apollo.inRange
local isUsable = apollo.isUsable
local missingHealth = apollo.missingHealth
local unitHealthPct = apollo.unitHealthPct
local hasThreat = apollo.hasThreat
local isFriend = apollo.isFriend
local offCooldown = apollo.offCooldown
local getEnergy = apollo.getEnergy
local getComboPoints = apollo.getComboPoints
local canInterupt = apollo.canInterupt
local lowMan = apollo.lowMana

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

function AD.feralSkillRotation()
	local skillRotation = {
		AD.healRenewal,
		AD.healPredatorySwiftness,
		apollo.healHealthstone,
		AD.attackSkullBash,
		AD.aoeThrash,
		AD.aoeSwipe,
		AD.attackRip,
		AD.attackFerociousBite,
		AD.attackRake,
		AD.attackShred,
		AD.attackTigersFury,
	}

	return skillRotation
end

function AD.condBaseHealResto(target, spellName)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not lowMana)
end

function AD.healHealingTouch(target)
	local spellName = "Healing Touch"
	local heal = (GetSpellBonusHealing() * 4)
	local spellCast = AD.condBaseHealResto(target,spellName) and (missingHealth(target) > heal)
	
	return spellCast, spellName
end

function AD.healRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)") and UnitBuff(target,"Rejuvenation") and true
	else unitBuff = UnitBuff(spellTarget,"Rejuvenation"); end
	local abundanceStacks = select(4,UnitBuff("player","Abundance")) or 0
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not unitBuff) and (unitHealthPct(target) < .9) and (abundanceStacks < 10)

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
	local debuffList = {"Aqua Bomb", "Shadow Word: Pain", "Corruption", "Drain Life", "Curse of Exhaustion", "Immolate", "Conflagrate", "Dancing Flames", "Withering Flames", "Salve of Toxic Fumes", "Felfire Shock", "Time Lapse", "Subjugate", "Flame Buffet", "Veil of Shadow", "Venom Spit", "Eyes in the Dark", "Curse of Tongues", "Shiver", "Beast's Mark", "Poisoned Spear", "Pustulant Flesh", "Unstable Afliction"}
	
	for i,v in ipairs(debuffList) do
		if UnitDebuff(target,v) then debuff = true; break; end;
	end
	if UnitDebuff(target,"Unstable Affliction") then debuff = false; end;
	
	local spellCast = AD.condBaseHealResto(target, spellName) and debuff and (offCooldown(spellName))
	
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
	local conditionSet3 = ((hasThreat(target)) and (unitHealthPct(target) < .7) and (not IsInRaid()))
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
	
	local conditionSet1 = AD.condBaseHealResto(target, spellName)
	local conditionSet2 = (hasThreat(target)) and (not unitBuff)
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

function AD.healRenewal(target)
	local spellName = "Renewal"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .7)
	
	return spellCast, spellName
end

function AD.healSwiftmend(target)
	local spellName = "Swiftmend"
	local spellCast = (AD.condBaseHealResto(target, spellName) and (offCooldown(spellName)) and (unitHealthPct(target) < .3))
	
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

function AD.attackShred(target)
	local spellName = "Shred"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getEnergy() > 65)
	
	return spellCast, spellName
end

function AD.attackRake(target)
	local spellName = "Rake"
	local unitDebuff = UnitDebuff("target","Rake")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getEnergy() > 65) and (not unitDebuff)
	
	return spellCast, spellName
end

function AD.aoeThrash(target)
	local spellName = "Thrash"
	local unitDebuff = UnitDebuff("target","Thrash")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Shred",target)) and (isUsable(spellName)) and (getEnergy() > 65) and (not unitDebuff) and (apollo.aoeToggle)
	
	return spellCast, spellName
end

function AD.aoeSwipe(target)
	local spellName = "Swipe"
	local unitDebuff = UnitDebuff("target","Thrash")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Shred",target)) and (isUsable(spellName)) and (unitDebuff) and (apollo.aoeToggle)
	
	return spellCast, spellName
end

function AD.attackFerociousBite(target)
	local spellName = "Ferocious Bite"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getComboPoints() == 5)
	
	return spellCast, spellName
end

function AD.attackRip(target)
	local spellName = "Rip"
	local unitDebuff = UnitDebuff("target","Rip")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getComboPoints() == 5) and (not unitDebuff)
	
	return spellCast, spellName
end

function AD.healPredatorySwiftness(target)
	local spellName = "Healing Touch"
	local unitBuff = UnitBuff("player","Predatory Swiftness")
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and unitBuff
	
	return spellCast, spellName
end

function AD.attackSkullBash(target)
	local spellName = "Skull Bash"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (canInterupt(target))
	
	return spellCast, spellName
end

function AD.attackTigersFury(target)
	local spellName = "Tiger's Fury"
	local unitBuff = UnitBuff("player","Clearcasting")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("shred",target)) and (isUsable(spellName)) and ((getEnergy() < 30) or (not unitBuff))
	
	return spellCast, spellName
end
