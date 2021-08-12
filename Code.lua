--[[
              ADVANCED INDICATOR FOR COBALT+
              Beta release v1.2
              Script made by Kadecz
              Does not support arrow with or without arrow scroll
              Added character scrolling
              
              RE-EDIT:
              Remastered by FinnTheHuman401 for Schindler, changed by FiftyFivePeople:
              Added support to arrow scroll (seperate)
              Lift on idle: Arrow won't be visible, Lift moving, Arrow will be visible
              to the direction occuring
              
              Please Read:
              This script is open-sourced on GitHub: ; do not claim this asset as your own. All
              credits go to their rightful owners.
--]]

-------------------------- Variables ---------------------------
lngth = 0 -- Variable to calculate length
sp = script.Parent
lift = sp.Parent.Parent.Parent
customlbl = require(lift.CustomLabel)
chars = require(script.CHAR)
charsARW = require(script.CHARARW)
space = 1 -- Spacing between characters
matrixresolution = {18, 14} -- Resolution of matrix, change if needed
customtextbig = chars["FONT_SIZE_BIG"]
customtxt = require(lift.CustomLabel)["CUSTOMFLOORLABEL"]
maxlen = 14 -- Maximum big font length span
align = "M" -- Alignment type, can be L (left), M (middle) or R (right)

--- Offset options --

xof = 0 -- X offset
yof = 1 -- Y offset
syof = 3 -- Small font Y offset
sxof = 0 -- Small font X offset

--- Color options ---

typeswitch = 1 -- Set to 1 to use transparency
enabledtransp = 0 -- Lit transparency
disabledtransp = 1 -- Unlit transparency
enabledclr = Color3.fromRGB(85, 255, 0) -- Lit color
disabledclr = Color3.fromRGB(88, 88, 88) -- Unlit color

--- Arrow ---
TextOffset = Vector3.new(0, 0, 0) -- How far the text moves when the arrow is visible
ScrollTime = 0.05

--- Scroll options --

scrollenable = false -- Enable/disable scrolling
scrollspd = 1 -- Scrolling speed
scrollspc = 2 -- Spacing of scrolling
scrolldir = "D" -- Scroll direction

---------------------

local kep = 0
local t = script.Parent.RUN
function onfloorchange(SF,clear)
	t.Value = true
	for an=1,matrixresolution[2] do
		for bn=1,matrixresolution[1] do
			if clear then if typeswitch == 0 then
					sp.Text["Row"..an]["D"..bn].Color = disabledclr -- clear display
				else
					sp.Text["Row"..an]["D"..bn].Transparency = disabledtransp
				end 
			end
		end
	end
	if string.len(SF) == 0 then return nil
	else
		if customtxt[tonumber(SF)] then SF = customtxt[tonumber(SF)] end
		calculatefont(SF)
		local diff = (customtextbig == chars["FONT_SIZE_SMALL"] and getvalue((getvalue((chars["FONT_SIZE_BIG"]),1)["CD"]),2) - getvalue((getvalue((chars["FONT_SIZE_SMALL"]),1)["CD"]),2) or 0)
		fs = (customtextbig == chars["FONT_SIZE_SMALL"] and 1 or 0)
		local startpos = 0
		for n=1,string.len(SF) do
			if n == 1 then startpos = calculatestartpos(SF) + (fs == 1 and sxof or xof)
			else startpos = calculatestartpos(SF) + calculatelen(string.sub(SF,1,(n-1))) + space + (fs == 1 and sxof or xof) end
			local POINT = 0
			local PMARK = false
			repeat POINT = POINT + 1 pcall(function()
					local ap = calculateystartpos(ypos) + (fs == 1 and syof or yof) - 1 + POINT
					for p=startpos,startpos + (getvalue(customtextbig[string.sub(SF,n,n)]["CD"],1)) do
						local cp = p - startpos
						local dp = ap - (fs == 1 and syof or yof)
						if typeswitch == 0 then
							sp.Text["Row"..ap]["D"..p].Color = string.sub(getvalue(customtextbig[string.sub(SF,n,n)]["DAT"][dp],1),cp,cp) == "1" and enabledclr or disabledclr
						else
							sp.Text["Row"..ap]["D"..p].Transparency = string.sub(getvalue(customtextbig[string.sub(SF,n,n)]["DAT"][dp],1),cp,cp) == "1" and enabledtransp or disabledtransp
						end
					end
				end)
				if POINT == customtextbig[string.sub(SF,n,n)]["CD"][2] then PMARK = true end
			until PMARK
		end
	end
	t.Value = false
end

function calculatelen(char)
	lngth = 0
	if string.len(char) == 0 then return 0 end
	for a=1,string.len(char) do
		lngth = lngth + customtextbig[string.sub(char,a,a)]["CD"][1]
	end
	lngth = lngth + space * (string.len(char) - 1)
	return lngth
end

function calculatestartpos(chb)
	if align == "M" then local d = ((matrixresolution[1] - calculatelen(chb)) / 2)
		if d % 1 == 0 then return math.ceil(d + 1)
		else return math.ceil(d) end
	elseif align == "L" then return 1
	elseif align == "R" then return (matrixresolution[1] - calculatelen(chb)) end
end

function calculateystartpos(chc)
	return math.ceil((matrixresolution[2] - chc) / 2)
end

function getvalue(a,b)
	local k,v
	if b == 1 then k,v = next(a,nil)
	else k,v = next(a,b-1)
	end
	return v
end

function calculatefont(chd)
	if calculatelen(chd) > maxlen then customtextbig = chars["FONT_SIZE_SMALL"]
	else customtextbig = chars["FONT_SIZE_BIG"]
	end
end

ypos = getvalue((getvalue((customtextbig),1)["CD"]),2)

function scroll(val,scspd,scspc,scdir)
	local dd = kep
	local sav = yof
	local aa = lift.Direction.Value == 1 and 1 or -1
	local space1 = scspc+customtextbig[string.sub(dd,1,1)]["CD"][2]
	for n=1,space1+1 do
		for dn=1,scspd do game:GetService("RunService").Heartbeat:Wait() end
		onfloorchange(dd,true)
		yof = yof + space1 * aa
		onfloorchange(val,false)
		yof = yof - (space1+1) * aa
	end
	kep = val
	yof = sav
end

function floor(val)
	-- Custom indicator code.
	if not scrollenable then
		onfloorchange(tostring(val),true)
	else
		if t.Value then t.Changed:Wait() end
		scroll(tostring(val),scrollspd,scrollspc,scrolldir)
	end
end

lift:WaitForChild("Floor").Changed:Connect(floor)

function SetARWDisplay(CHAR)
	if sp.Arrow and charsARW[CHAR] ~= nil then
		for i,l in pairs(charsARW[CHAR]) do 
			for r=1,8 do
				if typeswitch == 0 then
					sp.Arrow["Row"..i]["D"..r].Color = (l:sub(r,r) == "1" and enabledclr or disabledclr)
				else
					sp.Arrow["Row"..i]["D"..r].Transparency = (l:sub(r,r) == "1" and enabledtransp or disabledtransp)
				end
			end
		end
	end
end

sp:WaitForChild("SHOWARW").Changed:Connect(function(VAL)
	if VAL == true then	
		local maxlen = 20
	end
end)

-- -- -- -- -- -- --
--DIRECTION SCROLL--
-- -- -- -- -- -- --

sp:WaitForChild("SHOWARW").Changed:Connect(function(VAL)
	if VAL == true then		
		for i,v in pairs(sp.Text:GetDescendants()) do
			if v:IsA("SpecialMesh") then
				v.Offset = TextOffset
			end
		end
	else
		for i,v in pairs(sp.Text:GetDescendants()) do
			if v:IsA("SpecialMesh") then
				v.Offset = Vector3.new(0, 0, 0)
			end
		end
	end
end)

while wait() do
	if sp.Parent:WaitForChild("Lantern").Value == "U" then
		sp.SHOWARW.Value = true
		SetARWDisplay("U1")
	elseif sp.Parent:WaitForChild("Lantern").Value == "D" then
		sp.SHOWARW.Value = true
		SetARWDisplay("D1")
	elseif sp.Parent:WaitForChild("Lantern").Value == "N" then
		sp.SHOWARW.Value = false
		SetARWDisplay("NIL")
	end
end
