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

local function condBaseHealResto(target, spellName)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) --and (not lowMana)
end

local function condBaseAttackFeral(target, spellName)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function getShapeshiftForm()
	local shapeshiftForm
	if GetShapeshiftForm() == 0 then shapeshiftForm = "Humanoid" else shapeshiftForm = select(2,GetShapeshiftFormInfo(GetShapeshiftForm())) end;
	return shapeshiftForm
end

local function tankHealRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	local abundanceStacks = select(4,UnitBuff("player","Abundance")) or 0
	
	local spellCast = condBaseHealResto(target, spellName) and (not unitBuff) and (InCombatLockdown() or unitHealthPct(target) < 1) and isTank(target) and (getShapeshiftForm() ~= "Moonkin Form")

	return spellCast, spellName
end

local function tankHealIronbark(target)
	local spellName = "Ironbark"
	
	local spellCast = condBaseHealResto(target, spellName) and (unitHealthPct(target) < .7) and isTank(target) and hasThreat(target) and offCooldown(spellName) and (getShapeshiftForm() ~= "Moonkin Form")

	return spellCast, spellName
end

local function healEssenceOfGhanir(target)
	local spellName = "Essence of G'Hanir"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange("Rejuvenation",target)) and (isUsable(spellName)) and (unitHealthPct(target) < .7) and offCooldown(spellName) and (getShapeshiftForm() ~= "Moonkin Form") and unitBuff

	return spellCast, spellName
end

local function healHealingTouch(target)
	local spellName = "Healing Touch"
	if UnitLevel("player") < 90 then spellName = "Regrowth"; end;
	local heal = (GetSpellBonusHealing() * 4)
	local spellCast = condBaseHealResto(target,spellName) and (unitHealthPct(target) < .9) and (not isMoving("player"))
	
	return spellCast, spellName
end

local function healTankHealingTouch(target)
	local spellName = "Healing Touch"
	if UnitLevel("player") < 90 then spellName = "Regrowth"; end;
	local spellCast = condBaseHealResto(target,spellName) and (unitHealthPct(target) < .7) and (not isMoving("player")) and isTank(target)
	
	return spellCast, spellName
end

local function healRejuvenation(target)
	local spellName = "Rejuvenation"
	local unitBuff
	if select(4,GetTalentInfo(6,3,1)) then unitBuff = UnitBuff(target,"Rejuvenation (Germination)",nil,"PLAYER") and UnitBuff(target,"Rejuvenation",nil,"PLAYER") and true
	else unitBuff = UnitBuff(target,"Rejuvenation",nil,"PLAYER"); end
	local abundanceStacks = select(4,UnitBuff("player","Abundance")) or 0
	
	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not unitBuff) and (unitHealthPct(target) < .9) and (abundanceStacks < 10) and (getShapeshiftForm() ~= "Moonkin Form")

	return spellCast, spellName
end

local function attackSolarWrath(target)
	local spellName = "Solar Wrath"
	local spellCast = condBaseAttackFeral(target, spellName)
	
	return spellCast, spellName
end

local function bearMangle(target)
	local spellName = "Mangle"
	local spellCast = condBaseAttackFeral(target, spellName)
	
	return spellCast, spellName
end

local function attackStarsurge(target)
	local spellName = "Starsurge"
	local spellCast = condBaseAttackFeral(target, spellName)
	
	return spellCast, spellName
end

local function attackLunarStrike(target)
	local spellName = "Lunar Strike"
	local unitBuff = UnitBuff("player","Lunar Empowerment")
	AD.lastLunarStrike = AD.lastLunarStrike or 0
	if UnitCastingInfo("player") == "Lunar Strike" then AD.lastLunarStrike = GetTime(); end;
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and unitBuff and (AD.lastLunarStrike < GetTime() - 1)
	
	return spellCast, spellName
end

local function attackMoonfire(target)
	local spellName = "Moonfire"
	local unitDebuff = UnitDebuff(target,"Moonfire",nil,"PLAYER")
	local spellCast = condBaseAttackFeral(target, spellName) and (not unitDebuff)
	
	return spellCast, spellName
end

local function attackLunarInspiration(target)
	local spellName = "Moonfire"
	local unitDebuff = UnitDebuff(target,"Moonfire")
	local talent = select(4,GetTalentInfo(1,3,1))
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not unitDebuff) and (not IsStealthed()) and talent
	
	return spellCast, spellName
end

local function healNaturesCure(target)
	local spellName = "Nature's Cure"
	if UnitLevel("player") < 18 then return false, spellName; end;
	local debuff, dispellType
	local exclusionList = {"Frostbolt", "Thunderclap", "Chilled", "Unstable Affliction"}

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

	spellCast = debuff and (dispellType == "Curse" or dispellType == "Poison" or dispellType == "Magic") and (isFriend(target)) and (offCooldown(spellName)) and (inRange(spellName,target))
	
	return spellCast, spellName
end

local function healTankRegrowth(target)
	local spellName = "Regrowth"
	local clearcasting = UnitBuff("player","Clearcasting")
	local currentSpeed = GetUnitSpeed("player")
	local regrowthBuff = UnitBuff(target, "Regrowth",nil,"PLAYER")
	
	AD.lastRegrowth = AD.lastRegrowth or 0
	if UnitCastingInfo("player") == "Regrowth" then AD.lastRegrowth = GetTime(); end;
	
	local conditionSet1 = condBaseHealResto(target, spellName) and (currentSpeed == 0) and (AD.lastRegrowth < GetTime() - 1)
	local conditionSet2 = (hasThreat(target)) and (isTank(target)) and (unitHealthPct(target) < .9) and ((not regrowthBuff) or (clearcasting))
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

local function healGroupRegrowth(target)
	local spellName = "Regrowth"
	local clearcasting = UnitBuff("player","Clearcasting")
	local currentSpeed = GetUnitSpeed("player")
	
	AD.lastRegrowth = AD.lastRegrowth or 0
	if UnitCastingInfo("player") == "Regrowth" then AD.lastRegrowth = GetTime(); end;
	
	local conditionSet1 = condBaseHealResto(target, spellName) and (currentSpeed == 0) and (AD.lastRegrowth < GetTime() - 1)
	local conditionSet2 = ((unitHealthPct(target) < .9) and (clearcasting))
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

local function healLifeBloom(target)
	local spellName = "Lifebloom"
	local unitBuff = false
	for i,v in ipairs(apollo.groupNames) do
		if (UnitExists(v)) then
			unitBuff = UnitBuff(v,"Lifebloom",nil,"PLAYER")
			if (unitBuff) then break; end;
		end
	end
	
	local conditionSet1 = condBaseHealResto(target, spellName)
	local conditionSet2 = InCombatLockdown() and (not unitBuff) and isTank(target)
	local spellCast = conditionSet1 and conditionSet2
	
	return spellCast, spellName
end

local function healRenewal(target)
	local spellName = "Renewal"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .7) and (InCombatLockdown())
	
	return spellCast, spellName
end

local function healSurvivalInstincts(target)
	local spellName = "Survival Instincts"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .7) and InCombatLockdown()
	
	return spellCast, spellName
end

local function healSwiftmend(target)
	local spellName = "Swiftmend"
	local spellCast = (condBaseHealResto(target, spellName) and (offCooldown(spellName)) and (UnitHealth(target) / UnitHealthMax(target) < .4))
	
	return spellCast, spellName
end

local function healTranquility(target)
	local spellName = "Tranquility"
	local triggerCount = math.ceil(GetNumGroupMembers()/2)
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= triggerCount) and (GetNumGroupMembers() >= 3))
	
	return spellCast, spellName
end

local function healWildGrowth(target)
	local spellName = "Wild Growth"
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Regrowth") >= 3))
	
	return spellCast, spellName
end

local function attackShred(target)
	local spellName = "Shred"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getEnergy() >= 50)
	
	return spellCast, spellName
end

local function attackAshamanesFrenzy(target)
	local spellName = "Ashamane's Frenzy"
	local spellCast = condBaseAttackFeral(target, spellName) and getComboPoints() <= 2
	
	return spellCast, spellName
end

local function attackRake(target)
	local spellName = "Rake"
	local unitDebuff = UnitDebuff("target","Rake")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (not unitDebuff) and (getEnergy() >= 50)
	
	return spellCast, spellName
end

local function aoeThrash(target)
	local spellName = "Thrash"
	local unitDebuff = UnitDebuff("target","Thrash")
	local rangeSpell
	if getShapeshiftForm() == "Cat Form" then rangeSpell = "Shred" elseif getShapeshiftForm() == "Bear Form" then rangeSpell = "Mangle"; end;
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(rangeSpell,target)) and (isUsable(spellName)) and (getEnergy() >= 50) and (not unitDebuff) and (apollo.aoeToggle or getShapeshiftForm() == "Bear Form")
	
	return spellCast, spellName
end

local function aoeSwipe(target)
	local spellName = "Swipe"
	local unitDebuff = UnitDebuff("target","Thrash")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Shred",target)) and (isUsable(spellName)) and (getEnergy() >= 50) and (unitDebuff) and (apollo.aoeToggle)
	
	return spellCast, spellName
end

local function bearThrash(target)
	local spellName = "Thrash"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Mangle",target)) and (isUsable(spellName)) and (getShapeshiftForm() == "Bear Form") and (offCooldown(spellName))
	
	return spellCast, spellName
end

local function bearSwipe(target)
	local spellName = "Swipe"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("Mangle",target)) and (isUsable(spellName)) and (getShapeshiftForm() == "Bear Form")
	
	return spellCast, spellName
end

local function attackFerociousBite(target)
	local spellName = "Ferocious Bite"
	local base, posBuff, negBuff = UnitAttackPower("player")
	local effectiveAP = base + posBuff + negBuff;
	local spellCast = condBaseAttackFeral(target, spellName) and ((getComboPoints() == 5) or UnitHealth("focus") < effectiveAP * 5.8 * getComboPoints() / 5) and (not IsStealthed()) and (getEnergy() >= 30)
	
	return spellCast, spellName
end

local function attackRip(target)
	local spellName = "Rip"
	local unitDebuff = UnitDebuff("target","Rip")
	local base, posBuff, negBuff = UnitAttackPower("player")
	local effectiveAP = base + posBuff + negBuff;
	local ripDamage = effectiveAP * 1.68 * 5
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (getComboPoints() == 5) and (not unitDebuff) and (not IsStealthed()) and (UnitHealth(target) > ripDamage)
	
	return spellCast, spellName
end

local function healPredatorySwiftness(target)
	local spellName = "Healing Touch"
	local swiftnessBuff = UnitBuff("player","Predatory Swiftness")
	local bloodtalonsBuff = UnitBuff("player","Bloodtalons")

	local spellCast = (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and swiftnessBuff and not bloodtalonsBuff and ((unitHealthPct(target) < .9) or getComboPoints() >= 5)
	
	return spellCast, spellName
end

local function attackSkullBash(target)
	local spellName = "Skull Bash"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (canInterupt(target))
	
	return spellCast, spellName
end

local function attackTigersFury(target)
	local spellName = "Tiger's Fury"
	local unitBuff = UnitBuff("player","Clearcasting")
	local spellCast = (not isFriend(target)) and (notDead(target)) and (inRange("shred",target)) and (isUsable(spellName)) and (getEnergy() < 40) and (not unitBuff) and (offCooldown("Shred"))
	
	return spellCast, spellName
end

--[[
local function travelIndoors(target)
	local spellName = "Cat Form"
	if moveTime == nil then local moveTime; end;
	local shapeshiftForm = select(2,GetShapeshiftFormInfo(GetShapeshiftForm()))
	
	if not isMoving() or shapeshiftForm == 2 or shapeshiftForm == 3 then moveTime = GetTime(); end;
	local spellCast = (moveTime + 2 <= GetTime()) and (shapeshiftForm ~= 2 and shapeshiftForm ~= 3) and (not IsMounted()) and (not IsResting())
	
	return spellCast, spellName
end
]]

local function attackCatForm(target)
	local spellName = "Cat Form"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (isUsable(spellName)) and (getShapeshiftForm() ~= "Cat Form") and (inRange("shred",target))
	
	return spellCast, spellName
end

local function attackMoonkinForm(target)
	local spellName = "Moonkin Form"
	local spellCast = (not isFriend(target)) and (notDead(target)) and (isUsable(spellName)) and (getShapeshiftForm() ~= "Moonkin Form") and (inRange("Moonfire",target)) and (not IsInGroup())
	
	return spellCast, spellName
end

local function healRebirth(target)
	local spellName = "Rebirth"
	local spellCast = (isFriend(target)) and (not notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and isTank(target)
	
	return spellCast, spellName
end

local function healBarkSkin(target)
	local spellName = "Barkskin"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .3)
	
	return spellCast, spellName
end

local function healIronfur(target)
	local spellName = "Ironfur"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .9)
	
	return spellCast, spellName
end

local function healFrenziedRegeneration(target)
	local spellName = "Frenzied Regeneration"
	local spellCast = (notDead(target)) and (isUsable(spellName)) and (UnitIsUnit("player",target)) and (offCooldown(spellName)) and (unitHealthPct(target) < .7)
	
	return spellCast, spellName
end

function AD.restorationSkillRotation()
	local skillRotation = {
		--EMERGENCY SKILLS--
		healRebirth,
		healNaturesCure,
		healRenewal,
--		apollo.healEternalAmuletOfTheRedeemed,
		apollo.healHealthstone,
		healBarkSkin,
		healSwiftmend,
		healEssenceOfGhanir,
		--AOE HEALING--
		healTranquility,
		healWildGrowth,
		--TANK HEALING--
		healLifeBloom,
		tankHealRejuvenation,
		healTankRegrowth,
		tankHealIronbark,
		healTankHealingTouch,
		--GROUP HEALING--
		healGroupRegrowth,
		healRejuvenation,
		healHealingTouch,
		--OTHER ACTIONS--
		apollo.buffWhispersOfInsanity,
		attackMoonfire,
		attackMoonkinForm,
		attackStarsurge,
		attackLunarStrike,
		attackSolarWrath,
--		travelIndoors,
	}
	return skillRotation
end

function AD.feralSkillRotation()
	local skillRotation = {
		healRenewal,
		healSurvivalInstincts,
	--	apollo.healEternalAmuletOfTheRedeemed,
		attackCatForm,
		healPredatorySwiftness,
		healSwiftmend,
		apollo.healHealthstone,
		attackSkullBash,
		attackLunarInspiration,
		attackRip,
		attackFerociousBite,
		aoeThrash,
		aoeSwipe,
		attackRake,
		attackShred,
		attackTigersFury,
		attackAshamanesFrenzy,
		apollo.buffWhispersOfInsanity,
--		travelIndoors,
	}

	return skillRotation
end

function AD.guardianSkillRotation()
	local skillRotation = {
		healIronfur,
		healFrenziedRegeneration,
		healBarkSkin,
		bearThrash,
		bearMangle,
		bearSwipe,
	}

	return skillRotation
end
