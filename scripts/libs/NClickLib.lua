local mod = modApi:getCurrentMod()

--[[ List of changes:
	
	*PhaseChange, SkillEffect, and TargetArea functions all now take the inputs p1, p2, self, Clicks, and PhaseClicks, in that order.
	You can edit the lists in your functions, and it won't effect the global version of said list.

	*You must now define and return ret in the applicable functions.

	*Confirmation Functions, instead of directly changing the phase, now return a value. nil, false, or the function not existing all do nothing. Returning true fires the weapon. Returning a number sets the weapon to that phase. While I think this will still work due to Phase needing to be global, I reccomend changing confirmation functions to reflect this change nonetheless.

	TipImages can now be included in the NClickSkill.
	They are defined with the standard TipImage board layout, minus the Target point.
	Then, define a second field called TipImageData, which is a keyed list of p2, Phase, Clicks, and PhaseClicks. This just directly calls the SkillEffect for a specific phase. You don't need to define values that you aren't using.
	TipImageData can take a list of those keyed arrays, and it will cycle through the given data. See X_MissileSpam in Target Acquirers for an example if I'm not explaining this well.

	New functions: CopyTable and FilteredPointList, CopyTable perfectly copies a table [Including nested ones] and FilteredPointList takes a list of points and returns them in the same order but with duplicates removed.
	
]]--


--Some helper functions, to make manipulating pointlists a bit easier
function CopyTable(Table)
    local CopyTo = {}
    for i = 1, #Table do
        if type(Table[i]) == 'table' then
            CopyTo[i] = CopyTable(Table[i])
        else
            CopyTo[i]=Table[i]
        end
    end
    return CopyTo
end

function FilteredPointList(List)
    local temp = {}
    local temp2 = {}
    for i = 1, #List do
	local hash = List[i].x*10+List[i].y
        if not temp[hash] then
            temp[hash] = true
            temp2[#temp2+1] = List[i]
        end
    end
    return temp2
end


--Some version control so different versions can exist and won't override eachother
local LocalVersion = 2.0
if not NClickVersions then
	NClickVersions = {}
end 

if not NClickVersions[LocalVersion] then

NClickVersions[LocalVersion] = true
local path = mod.scriptPath
local weaponArmed = require(path .."libs/weaponArmed")

local Clicks = {}
local PhaseClicks = {{}}
Phase = 1
local PreventDouble = true



NClickSkill = Skill:new{
	TwoClick = true,
	TipImageCounter = 1,
	NClickVersion = LocalVersion,
	NClick = true
}

function NClickSkill:GetTargetArea(p1)
	local ret = PointList()

	if not Board:IsTipImage() then
		if self.TargetAreas[Phase] then
			ret = self.TargetAreas[Phase](p1, nil, self, CopyTable(Clicks), CopyTable(PhaseClicks))
		else
			LOG("Attempted to use TargetArea ", Phase)
		end

		ret:push_back(Point(10,10))
	else
		for i = 0, 7 do
			for j = 0, 7 do
				ret:push_back(Point(i,j))
			end
		end
	end

	return ret
end

function NClickSkill:IsTwoClickException(p1,p2)
	if not Board:IsTipImage() then
		if p2==Point(10,10) then

			Clicks = {}
			PhaseClicks = {{}}
			Phase = 1
			return true

		else

			local NextPhase = (self.PhaseChanges[Phase] or function(a,b,c,d,e) return Phase+1 end)(p1, p2, self, CopyTable(Clicks), CopyTable(PhaseClicks))


			if (NextPhase) > (self.Phases) then
				Clicks = {}
				PhaseClicks = {{}}
				Phase = 1
				return true
			end

			return false

		end

	else
		return true

	end

end

function NClickSkill:GetSkillEffect(p1, p2)
	if not Board:IsTipImage() then

		return self.SkillEffects[Phase](p1, p2, self, CopyTable(Clicks), CopyTable(PhaseClicks))

	else
		local ClickData = self.TipImageData
		if not (ClickData.Phase) then
			self.TipImageCounter = 1+(self.TipImageCounter % #self.TipImageData)
			ClickData = self.TipImageData[self.TipImageCounter]
		end
		return self.SkillEffects[ClickData.Phase](p1, ClickData.p2 or nil, self, CopyTable(ClickData.Clicks or {}), CopyTable(ClickData.PhaseClicks or {}))

	end

end

function NClickSkill:GetSecondTargetArea(p1, p2)
	if not Board:IsTipImage() then
	local ret = PointList()
	if (Board:GetPawn(p1):GetFirstClick() == Point(1000,1000)) then

		local NextPhase = (self.PhaseChanges[Phase] or function(a,b,c,d,e) return Phase+1 end)(p1, p2, self, CopyTable(Clicks), CopyTable(PhaseClicks))

		if self.TargetAreas[NextPhase] then

			ret = self.TargetAreas[NextPhase](p1, p2, self, CopyTable(Clicks), CopyTable(PhaseClicks))

		end

	else
		if PreventDouble then

			if not PhaseClicks[Phase] then
				PhaseClicks[Phase] = {}
			end

			(PhaseClicks[Phase])[#(PhaseClicks[Phase])+1]=p2

			Phase = (self.PhaseChanges[Phase] or function(a,b,c,d,e) return Phase+1 end)(p1, p2, self, CopyTable(Clicks), CopyTable(PhaseClicks))

			Clicks[#Clicks+1] = p2

			PreventDouble = false
		else

			PreventDouble = true

		end
	end
	return ret
	else
	local ret = PointList()
	return ret
	end
end

function NClickSkill:GetFinalEffect(p1, p2, p3)

	local ret = SkillEffect()
	LOG("Error Occurred. Shouldn't have been able to get here.")
	return ret
end

local function EVENT_onModsLoaded()

	modapiext:addPawnSelectedHook(function(_, pawn)
			Clicks = {}
			PhaseClicks = {{}}
			Phase = 1
	end)

end

weaponArmed.events.onWeaponArmed:subscribe(function(skill, pawnId)
	Clicks = {}
	PhaseClicks = {{}}
	Phase = 1
end)


modApi.events.onModsLoaded:subscribe(EVENT_onModsLoaded)

local ConfirmWeapon = function(scancode)

	if (scancode == 13) then
		AdvanceConfirmationWeapon()
	end
end


function AdvanceConfirmationWeapon()
	if Board then
		local Pawn = nil
		local Weapon = false
		local AllPawns = extract_table(Board:GetPawns(TEAM_ANY))
			for i = 1, #AllPawns do
				local curr = AllPawns[i]
				if Board:GetPawn(curr) then
					if Board:GetPawn(curr):GetArmedWeapon() then
						Pawn = Board:GetPawn(curr)
						Weapon = Pawn:GetArmedWeapon()
						break
					end
				end
			end

		if Weapon then
			if _G[Weapon].NClickVersion == LocalVersion then
				if _G[Weapon].Confirmation then
					if (_G[Weapon].ConfirmationFuncs)[Phase] then
						local result = _G[Weapon].ConfirmationFuncs[Phase](Pawn:GetSpace(), _G[Weapon], CopyTable(Clicks), CopyTable(PhaseClicks))
						if result then
							if result == true then
								Pawn:FireWeapon(Point(10,10),Pawn:GetArmedWeaponId())
							else
								Phase = result
								Pawn:FireWeapon(Point(11,11),Pawn:GetArmedWeaponId())
							end
						end
					end
				end
			end
		end
	end
end

require(path .."libs/NClickUi")

modApi.events.onKeyPressed:subscribe(ConfirmWeapon)
end