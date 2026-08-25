local font = sdlext.font("fonts/JustinFont11Bold.ttf", 40)
local set = deco.uifont.title.set

local LocalVersion = 2.0
local mod = modApi:getCurrentMod()
local path = mod.scriptPath
local menu = require(path.."libs/menu")
local escMenuIsClosed = menu.isClosed
local COLOR_BLACK_220 = sdl.rgba(0, 0, 0, 220)

local tooltiptext = "You currently have a Confirmation weapon armed. The weapon will not move onto the next click phase until you either click this box or press Enter."

local srf = sdl.text(font, set, "CONFIRM")
local size = { w = sdlext.totalWidth(srf), h = srf:h() }
srf = nil


local function fadeToBlack(anim, widget, percent)
	widget.decoMenuMask.color = InterpolateColor(
		deco.colors.transparent,
		COLOR_BLACK_220,
		percent
	)
end

local function drawWhileEscMenu(self, screen, widget)
	local anim = widget.animations.fade
	if escMenuIsClosed() then
		anim:stop()
		self.color = deco.colors.transparent
	elseif anim:isStopped() then
		anim:start()
	end

	DecoSolid.draw(self, screen, widget)
end


local function createUi(screen, uiRoot)
	local ui = Ui()
		:widthpx(size.w):heightpx(size.h)

		:addTo(uiRoot)
		:settooltip(tooltiptext)
		:pospx(ScreenSizeX() - 250, ScreenSizeY()/2)

	ui.decoMenuMask = DecoSolid(deco.colors.transparent)
	ui.animations.fade = UiAnim(ui, 100, fadeToBlack)
	ui.decoMenuMask.draw = drawWhileEscMenu

	function ui.animations.fade:isDone()
		return false
	end


	ui:decorate({
			DecoButton(),
			DecoAlign(-3,4),
			DecoText("CONFIRM", font, set),
			ui.decoMenuMask
	})

	ui.clicked = function(uiself, button)
		if button == 1 and not uiself.mdisabled then
			AdvanceConfirmationWeapon()
		end
	end

	function ui:relayout()
		self.visible = false
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
						self.visible = true
					end
				end
			end
		end
	end
		Ui.relayout(self)
	end
end


modApi.events.onUiRootCreated:subscribe(createUi)
