local AP = apollo.paladin
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

local function condBaseHeal(target, spellName)
	return (isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName))
end

local function condBaseAttack(target, spellName)
	return (not isFriend(target)) and (notDead(target)) and (inRange(spellName,target)) and (isUsable(spellName)) and (offCooldown(spellName)) and ((affectingCombat(target)) or not IsInInstance())
end

local function holyCrusaderStrike(target)
	local spellName = "Crusader Strike"
	local spellCast = condBaseAttack(target, spellName)
	
	return spellCast, spellName
end

local function holyJudgment(target)
	local spellName = "Judgment"
	local spellCast = condBaseAttack(target, spellName)
	
	return spellCast, spellName
end

local function holyHolyShockAttack(target)
	local spellName = "Holy Shock"
	local spellCast = condBaseAttack(target, spellName)
	
	return spellCast, spellName
end

local function holyCleanse(target)
	local spellName = "Cleanse"
	if UnitLevel("player") < 22 then return false, spellName; end;
	local debuff, dispellType
	local exclusionList = {"Frostbolt", "Thunderclap", "Chilled", "Unstable Affliction", "Curse of the Witch", "Intangible Presence", "Darkening Soul", "Blacking Soul", "Burning Blast"}

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

	spellCast = debuff and (dispellType == "Disease" or dispellType == "Poison" or dispellType == "Magic") and (isFriend(target)) and (offCooldown(spellName)) and (inRange(spellName,target))

	return spellCast, spellName
end

local function holyBeaconOfLight(target)
	local spellName = "Beacon of Light"
	local unitBuff = false
	for i,v in ipairs(apollo.groupNames) do
		if (UnitExists(v)) then
			unitBuff = UnitBuff(v,"Beacon of Light",nil,"PLAYER")
			if (unitBuff) then break; end;
		end
	end
	
	local spellCast = condBaseHeal(target, spellName) and (not unitBuff) and isTank(target)
	
	return spellCast, spellName
end

local function holyBeaconOfFaith(target)
	local spellName = "Beacon of Faith"
	local unitBuff = false
	for i,v in ipairs(apollo.groupNames) do
		if (UnitExists(v)) then
			unitBuff = UnitBuff(v,"Beacon of Faith",nil,"PLAYER")
			if (unitBuff) then break; end;
		end
	end
	
	local spellCast = condBaseHeal(target, spellName) and (not unitBuff) and UnitIsUnit("player",target)
	
	return spellCast, spellName
end

local function holyAvengingWrath(target)
	local spellName = "Avenging Wrath"
	local triggerCount = math.ceil(GetNumGroupMembers()/2)
	local spellCast = ((notDead(target)) and (isUsable(spellName)) and (offCooldown(spellName)) and (apollo.lowHealthCount(.7,"Flash of Light") >= triggerCount) and (GetNumGroupMembers() >= 3)) and (InCombatLockdown())
	
	return spellCast, spellName
end

local function holyBlessingOfSacrifice(target)
	local spellName = "Blessing of Sacrifice"
	
	local spellCast = condBaseHeal(target, spellName) and (unitHealthPct(target) < .6) and isTank(target) and hasThreat(target) and offCooldown(spellName)

	return spellCast, spellName
end

local function holyHolyShock(target)
	local spellName = "Holy Shock"
	local spellCast = (condBaseHeal(target, spellName) and (offCooldown(spellName)) and unitHealthPct(target) < .9)
	
	return spellCast, spellName
end

local function holyBestowFaith(target)
	local spellName = "Bestow Faith"
	local spellCast = (condBaseHeal(target, spellName) and (offCooldown(spellName)) and unitHealthPct(target) < .9)
	
	return spellCast, spellName
end

local function holyHolyLight(target)
	local spellName = "Holy Light"
	if UnitLevel("player") < 90 then spellName = "Flash of Light"; end;
	local spellCast = condBaseHeal(target,spellName) and (unitHealthPct(target) < .9) and (not isMoving("player"))
	
	return spellCast, spellName
end

local function holyFlashOfLight(target)
	local spellName = "Flash of Light"
	local spellCast = (condBaseHeal(target, spellName) and unitHealthPct(target) < .6) and (not isMoving("player"))
	
	return spellCast, spellName
end

local function holyLightOfTheMartyr(target)
	local spellName = "Light of the Martyr"
	local spellCast = (condBaseHeal(target, spellName) and unitHealthPct(target) < .6) and (unitHealthPct(target) < unitHealthPct("player")) and (unitHealthPct("player") > .6)
	
	return spellCast, spellName
end

function apollo.paladin.retributionSkillRotation()
	local skillRotation = {

	}
	return skillRotation
end

function apollo.paladin.holySkillRotation()
	local skillRotation = {
		holyCleanse,
		holyBeaconOfLight,
		holyBeaconOfFaith,
		holyHolyShock,
		holyBestowFaith,
		holyAvengingWrath,
		holyBlessingOfSacrifice,
		holyLightOfTheMartyr,
		holyFlashOfLight,
		holyHolyLight,
		holyJudgment,
		holyCrusaderStrike,
		holyHolyShockAttack,
	}
	return skillRotation
end