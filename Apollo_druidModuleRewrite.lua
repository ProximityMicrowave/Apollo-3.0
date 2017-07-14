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
local lowMana = apollo.lowMana
local isMoving = apollo.isMoving
local affectingCombat = apollo.affectingCombat
local isTank = apollo.isTank

local function attackBasicCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function healBasicCondition(spellName, target)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName))
end

local function attackBuffCondition(spellName, target)
	return (not isFriend(target)) and (notDead(target)) and (inRange("shred",target)) and (isUsable(spellName))
end

local function getShapeshiftForm()
	local shapeshiftForm
	if GetShapeshiftForm() == 0 then shapeshiftForm = "Humanoid" else shapeshiftForm = select(2,GetShapeshiftFormInfo(GetShapeshiftForm())) end;
	return shapeshiftForm
end

local function allHealRenewal(target)
	local spellName = "Renewal"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .4) and (InCombatLockdown())
	
	return spellCast, spellName
end

local function catHealSurvivalInstincts(target)
	local spellName = "Survival Instincts"
	local spellCast = InCombatLockdown() and (getShapeshiftForm() == "Cat Form") and (UnitIsUnit("player",target)) and (unitHealthPct(target) < .7) and healBasicCondition(spellName, target)
	
	return spellCast, spellName
end

local function catHealPredatorySwiftness(target)
	local spellName = "Regrowth"
	local swiftnessBuff = UnitBuff("player","Predatory Swiftness")
	local bloodtalonsBuff = UnitBuff("player","Bloodtalons")

	local spellCast =  swiftnessBuff and not bloodtalonsBuff and ((unitHealthPct(target) < .9) or (getComboPoints() >= 5)) and healBasicCondition(spellName, target)
	
	return spellCast, spellName
end

local function catAttackSkullBash(target)
	local spellName = "Skull Bash"
	local spellCast = (canInterupt(target)) and (getShapeshiftForm() == "Cat Form") and (attackBasicCondition(spellName, target))
	
	return spellCast, spellName
end

local function catAttackRip(target)
	local spellName = "Rip"
	local unitDebuff = UnitDebuff("target","Rip",nil,"PLAYER")
	local spellCast = (not unitDebuff) and (getComboPoints() >= 5) and (not IsStealthed()) and (attackBasicCondition(spellName, target)) and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackFerociousBite(target)
	local spellName = "Ferocious Bite"
	local base, posBuff, negBuff = UnitAttackPower("player")
	local effectiveAP = base + posBuff + negBuff;
	local spellCast = (getComboPoints() == 5) and (not IsStealthed()) and (getEnergy() >= 30) and attackBasicCondition(spellName, target) and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackRake(target)
	local spellName = "Rake"
	local unitDebuff = UnitDebuff("target","Rake",nil,"PLAYER")
	local spellCast = (not unitDebuff) and (attackBasicCondition(spellName, target)) and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackLunarInspiration(target)
	local spellName = "Moonfire"
	local unitDebuff = UnitDebuff(target,"Moonfire",nil,"PLAYER")
	local talent = select(4,GetTalentInfo(1,3,1))
	local spec = select(2,GetSpecializationInfo(GetSpecialization()))
	local spellCast = (talent and spec == "Feral") and (not unitDebuff) and (not isFriend(target)) and (notDead(target)) and (inRange("Entangling Roots",target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance()) and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackShred(target)
	local spellName = "Shred"
	local spellCast = (attackBasicCondition(spellName, target)) and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackTigersFury(target)
	local spellName = "Tiger's Fury"
	local unitBuff = UnitBuff("player","Clearcasting")
	local spellCast = attackBuffCondition(spellName, target) and (offCooldown("Shred")) and getComboPoints() >= 3 and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function catAttackAshamanesFrenzy(target)
	local spellName = "Ashamane's Frenzy"
	local spellCast = attackBasicCondition(spellName, target) and getComboPoints() <= 2 and (getShapeshiftForm() == "Cat Form")
	
	return spellCast, spellName
end

local function humanoidHealRebirth(target)
	local spellName = "Rebirth"
	local spellCast = (isFriend(target)) and (not notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and isTank(target) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidHealNaturesCure(target)
	local spellName = "Nature's Cure"
	if UnitLevel("player") < 18 then return false, spellName; end;
	local debuff, dispellType
	local exclusionList = {"Frostbolt", "Thunderclap", "Chilled", "Unstable Affliction", "Curse of the Witch", "Intangible Presence", "Darkening Soul", "Blackening Soul", "Burning Blast", "Chaotic Shadows"}

--	if apollo.runDebuffScan == true then
		for i = 1,40 do
			local a,_,_,_,b = UnitDebuff(target,i,true)
			if not a then break; end;
			for j,x in ipairs(exclusionList) do
				if a == x then
					debuff = false; break;
				else 
					debuff, dispellType = a,b
				end
			end
		end
--	end;

	spellCast = debuff and (dispellType == "Curse" or dispellType == "Poison" or dispellType == "Magic") and (isFriend(target)) and (offCooldown(spellName)) and (inRange(spellName,target)) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidHealBarkSkin(target)
	local spellName = "Barkskin"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .4) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidHealSwiftmend(target)
	local spellName = "Swiftmend"
	local spellCast = healBasicCondition(spellName, target) and (unitHealthPct(target) < .4)
	
	return spellCast, spellName
end

local function humanoidHealEssenceOfGhanir(target)
	local spellName = "Essence of G'Hanir"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange("Rejuvenation",target)) and (isUsable(spellName)) and (unitHealthPct(target) < .7) and offCooldown(spellName) and (getShapeshiftForm() ~= "Moonkin Form") and unitBuff

	return spellCast, spellName
end

local function humanoidHealTranquility(target)
	local spellName = "Tranquility"
	local triggerCount = math.ceil(GetNumGroupMembers()/2)
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= triggerCount) and (GetNumGroupMembers() >= 3)) and (InCombatLockdown())
	
	return spellCast, spellName
end

local function humanoidHealWildGrowth(target)
	local spellName = "Wild Growth"
	local currentSpeed = GetUnitSpeed("player")
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= 3)) and (inRange(spellName,target)) and (currentSpeed == 0)
	
	return spellCast, spellName
end

local function humanoidHealLifebloom(target)
	local spellName = "Lifebloom"
	local unitBuff = false
	for i,v in ipairs(apollo.groupNames) do
		if (UnitExists(v)) then
			unitBuff = UnitBuff(v,"Lifebloom",nil,"PLAYER")
			if (unitBuff) then break; end;
		end
	end
	
	local conditionSet1 = healBasicCondition(spellName, target) and (getShapeshiftForm() == "Humanoid")
	local conditionSet2 = InCombatLockdown() and (not unitBuff) and (isTank(target) or unitHealthPct(target) < .9)
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

local function humanoidHealTankIronbark(target)
	local spellName = "Ironbark"
	
	local spellCast = healBasicCondition(spellName, target) and (unitHealthPct(target) < .7) and isTank(target) and hasThreat(target) and offCooldown(spellName) and (getShapeshiftForm() == "Humanoid")

	return spellCast, spellName
end

local function humanoidHealRegrowth(target)
	local spellName = "Regrowth"
	local clearcasting = UnitBuff("player","Clearcasting")
	local currentSpeed = GetUnitSpeed("player")
	
	AD.lastRegrowth = AD.lastRegrowth or 0
	if UnitCastingInfo("player") == "Regrowth" then AD.lastRegrowth = GetTime(); end;
	
	local conditionSet1 = healBasicCondition(spellName, target) and (currentSpeed == 0) and (AD.lastRegrowth < GetTime() - 1)
	local conditionSet2 = ((unitHealthPct(target) < .9) and (clearcasting))
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

local function humanoidHealLowRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	local abundanceStacks = select(4,UnitBuff("player","Abundance")) or 0
	
	local spellCast = healBasicCondition(spellName, target) and (not unitBuff) and (unitHealthPct(target) < .4) and (abundanceStacks < 10) and (getShapeshiftForm() == "Humanoid")

	return spellCast, spellName
end

local function humanoidHealLowHealingTouch(target)
	local spellName = "Healing Touch"
	if UnitLevel("player") < 90 then spellName = "Regrowth"; end;
	local spellCast = healBasicCondition(spellName, target) and (unitHealthPct(target) < .4) and (not isMoving("player")) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidHealHighRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	local abundanceStacks = select(4,UnitBuff("player","Abundance")) or 0
	
	local spellCast = healBasicCondition(spellName, target) and (not unitBuff) and (abundanceStacks < 10) and (getShapeshiftForm() == "Humanoid") and ((unitHealthPct(target) < .9) or (isTank(target) and InCombatLockdown())) and (getShapeshiftForm() == "Humanoid")

	return spellCast, spellName
end

local function humanoidHealHighHealingTouch(target)
	local spellName = "Healing Touch"
	if UnitLevel("player") < 90 then spellName = "Regrowth"; end;
	local spellCast = healBasicCondition(spellName, target) and (unitHealthPct(target) < .9) and (not isMoving("player")) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidHealTankRegrowth(target)
	local spellName = "Regrowth"
	local clearcasting = UnitBuff("player","Clearcasting")
	local currentSpeed = GetUnitSpeed("player")
	local regrowthBuff = UnitBuff(target, "Regrowth",nil,"PLAYER")
	
	AD.lastRegrowth = AD.lastRegrowth or 0
	if UnitCastingInfo("player") == "Regrowth" then AD.lastRegrowth = GetTime(); end;
	
	local conditionSet1 = healBasicCondition(spellName, target) and (currentSpeed == 0) and (AD.lastRegrowth < GetTime() - 1)
	local conditionSet2 = (hasThreat(target)) and isTank(target) and (unitHealthPct(target) < .9) and ((not regrowthBuff) or (clearcasting))
	local spellCast = conditionSet1 and conditionSet2 and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

local function humanoidAttackSolarWrath(target)
	local spellName = "Solar Wrath"
	local spellCast = attackBasicCondition(spellName, target) and (getShapeshiftForm() == "Humanoid")
	
	return spellCast, spellName
end

function apollo.druid.rewriteSkillRotation()
	local skillRotation = {
		--ALL FORMS--
		allHealRenewal,
		apollo.healHealthstone,
		--BEAR FORM--
		--CAT FORM--
		catHealSurvivalInstincts,
		catHealPredatorySwiftness,
		catAttackSkullBash,
		catAttackAshamanesFrenzy,
		catAttackRip,
		catAttackFerociousBite,
		catAttackRake,
		catAttackLunarInspiration,
		catAttackShred,
		catAttackTigersFury,
		--MOONKIN FORM--
		--HUMANOID FORM--
		humanoidHealRebirth,
		humanoidHealNaturesCure,
		humanoidHealBarkSkin,
		humanoidHealSwiftmend,
		humanoidHealEssenceOfGhanir,
		humanoidHealTranquility,
		humanoidHealWildGrowth,
		humanoidHealLifebloom,
		humanoidHealTankIronbark,
		humanoidHealRegrowth,
		humanoidHealLowRejuvenation,
		humanoidHealLowHealingTouch,
		humanoidHealHighRejuvenation,
		humanoidHealHighHealingTouch,
		humanoidHealTankRegrowth,
		humanoidAttackSolarWrath,
	}
	
	return skillRotation
end