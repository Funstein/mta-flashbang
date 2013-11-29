local sx, sy = guiGetScreenSize()
local renderWhite = false
local isPlayerBanged = false

local dontBang = {
["Admin"] = true,
-- Add more teams here to prevent them from being affected by flashbangs.
}

function startFlashBang(flashbang, creator)
	if isElement(flashbang) then
		local zeType = getProjectileType( flashbang )
		if zeType == 17 and getElementType(creator) == "player" and (not (getPlayerTeam(localPlayer) and dontBang[getTeamName(getPlayerTeam(localPlayer))])) then
			local pX, pY, pZ = getElementPosition(flashbang)
			local cX, cY, cZ = getCameraMatrix()
			destroyElement(flashbang)
			local distance = getDistanceBetweenPoints3D(cX, cY, cZ, pX, pY, pZ)
			--local screen = getScreenFromWorldPosition(pX, pY, pZ)
			local screen = true
			local wanted = tonumber(getElementData(localPlayer, "wanted")) or 0
			if screen and distance < 30 and wanted > 0 and (not isPlayerDead(localPlayer)) and (not isPlayerBanged) then
				sound = playSound("bang.mp3", true)
				addEventHandler("onClientRender", root, drawFlashBang)
				reductionParam = 0
				renderWhite = 255
				mainTimer = setTimer(function() if reductionParam then reductionParam = reductionParam + 2 end end, 1000, 128)
				toggleControl("sprint", false)
				toggleControl("jump", false)
				isPlayerBanged = true
			end
		end
	end
end
addEventHandler("onClientProjectileCreation", root, function(creator) setTimer(startFlashBang, 2000, 1, source, creator) end)

function drawFlashBang()
	if renderWhite and renderWhite > 0 then
		dxDrawRectangle(0, 0, sx, sy, tocolor(255, 255, 255, renderWhite))
		renderWhite = renderWhite - reductionParam
		setSoundVolume(sound, renderWhite/255)
	else
		stopFlashBang()
	end
end

function stopFlashBang()
	alpha = false
	removeEventHandler("onClientRender", root, drawFlashBang)
	if isTimer(mainTimer) then killTimer(mainTimer) mainTimer = nil end
	if sound then stopSound(sound) sound = nil end
	toggleControl("sprint", true)
	toggleControl("jump", true)
	isPlayerBanged = false
end


----- Stop Flashbang Spam
function stopSpam(creator)
	if isElement(source) then
		local weapon = getProjectileType( source )
		if weapon == 17 and creator == localPlayer and not notFlash[getElementData(creator, "class")] then
			if getPedTotalAmmo(localPlayer, 1) > 0 then
				setPedWeaponSlot(localPlayer, 1)
			else
				setPedWeaponSlot(localPlayer, 0)
			end
			toggleControl("next_weapon", false)
			toggleControl("previous_weapon", false)
			outputChatBox("Flashbang spam protection has been activated. You can't switch weapons for 5 seconds.", 255, 255, 0)
			setTimer(function()
				toggleControl("next_weapon", true)
				toggleControl("previous_weapon", true)
				outputChatBox("Flashbang spam protection has been deactivated. You can switch weapons again.", 255, 255, 0)
			end, 5000, 1)
		end
	end
end
addEventHandler("onClientProjectileCreation", root, stopSpam)

function removeSmoke(damager, weapon)
	if weapon == 17 then
		cancelEvent()
	end
end
addEventHandler("onClientPlayerDamage", getLocalPlayer(), removeSmoke)