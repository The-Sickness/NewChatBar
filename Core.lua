-- newChatBar
-- Made by: where_is_my_money_b1tch
-- Maintained by: Sharpedge_Gaming
-- v0.08	 - 10.0.2

local myName, AddOn = ...
local version = GetAddOnMetadata(myName, "Version")

local frame = CreateFrame("Frame",nil,UIParent, BackdropTemplateMixin and "BackdropTemplate")
local L=L4S[GetLocale()];
if type(L)~="table" then L=L4S["enUS"]; end
local LCH={};
local WHOLIST={};
local sFrame; local sFrame_add;
local backdropQ = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
	edgeSize = 14,
	insets = {left = 3, right = 3, top = 3, bottom = 3}
}

function strPlainText(txt)
    return txt:gsub("(%W)","%%%1")
end
function split(txt, sep)
		local t={}
        if sep == nil then sep = "%s"; end
        for str in string.gmatch(txt, "([^"..sep.."]+)") do table.insert(t, str); end
        return t
end

function sArr(name, arr)
	local R={};
	for key, val in pairs(arr) do
		local t=split(val,":");
	   if t[1]==name then R=t; end
	end
	return R;
end

function searchWho(name, val, numWhos)
	local R={}; local Rc=1;
	if tonumber(numWhos)>1 then
		for i = 1, tonumber(numWhos) do
			local p = C_FriendList.GetWhoInfo(i)
			if name=="NAME" and string.find(p.fullName,val)~=nil then
				R[Rc]=p.fullName; Rc=Rc+1;
			end
		   --print (p.fullName.." - "..p.level.." - "..p.raceStr.." - "..p.classStr.." - "..p.area)
		end
	end
	return R;
end
function compareArr(arr1, arr2)
	if arr1[1]==nil then return arr2; end
	local Rc=0; local isset=0;
	for key, val in pairs(arr2) do
		Rc=0;
		for key1, val1 in pairs(arr1) do
			if val==val1 then isset=1; end
			Rc=Rc+1;
		end 
		if isset==0 then arr1[(Rc+1)]=val; end
	end
	local cvm="";
	for key, val in pairs(arr1) do cvm=cvm.." "..val;  end
	print(Rc.." : "..cvm);
	return arr1;
end

function cParse(txt,param)
	local t=split(txt:match ('%{%[([^%]]+)%]%}'),"|");
	local R={}; 
    if t[1]=="WHOLIST" then 
		local numWhos, totalNumWhos = C_FriendList.GetNumWhoResults();
		if tonumber(numWhos)>1 then
			R=sArr("NAME", t); if R[1]~=nil and R[2]~=nil then WHOLIST=compareArr(WHOLIST, searchWho("NAME", R[2], numWhos)); end
		end
	end
	
	return txt,param;
end



--=============================================================
function newFrame(w,h,x,y,name,parent)
	addcomentframe = CreateFrame("FRAME",name,parent); 
	addcomentframe:SetMovable(true) 
	addcomentframe:EnableMouse(true) 
	addcomentframe:SetClampedToScreen(true) 
	addcomentframe:SetScript("OnMouseDown", addcomentframe.StartMoving) 
	addcomentframe:SetScript("OnMouseUp", addcomentframe.StopMovingOrSizing) 
	addcomentframe:SetWidth(w);   
	addcomentframe:SetHeight(h); 
	addcomentframe:SetPoint("BOTTOMLEFT", x, y ); 
	addcomentframe:SetBackdrop(backdropQ); 
	addcomentframe:SetBackdropColor(0.2,0.2,0.2,1); 
	addcomentframe:SetBackdropBorderColor(0.2,0.1,0.1,1); 
	addcomentframe:Hide();
	return addcomentframe;
end

function Open_chat(channel)
	local editBox = ChatEdit_ChooseBoxForSend();
	local txt = editBox:GetText();
	local chatFrame = editBox.chatFrame;
	ChatFrame_OpenChat(channel..txt, chatFrame); 
	ChatEdit_UpdateHeader(editBox);
end
function Add_Frame(w,h)
	local GSW=GetScreenWidth(); local GSH=GetScreenHeight(); 
	local CF = CreateFrame("FRAME","addcomentframe_frame",UIParent);
	CF:SetMovable(true)
	CF:EnableMouse(true)
	CF:SetClampedToScreen(true)
	CF:SetScript("OnMouseDown", CF.StartMoving) 
	CF:SetScript("OnMouseUp",function(self, event, ...)
			self:StopMovingOrSizing();
			local GSW=GetScreenWidth(); local GSH=GetScreenHeight(); 
			--local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint(1);
			LCH_Point={x=(self:GetLeft()*100/GSW),y=(self:GetTop()*100/GSH)};
	end)
	
	if LCH_Point.x>100 or LCH_Point.x<0  then LCH_Point={x=50,y=50}; end
	if LCH_Point.y>100 or LCH_Point.y<0  then LCH_Point={x=50,y=50}; end
	
	CF:SetWidth(w); CF:SetHeight(h);
	CF:SetPoint("BOTTOMLEFT",(GSW*LCH_Point.x/100),(GSH*LCH_Point.y/100)-10 );

	CF.Backdrop = CreateFrame("Frame", "CFCFBackdrop", CF, "BackdropTemplate")
	CF.Backdrop:SetAllPoints()		
	CF.Backdrop.backdropInfo = backdropQ
	CF.Backdrop:ApplyBackdrop()
	--CF:SetBackdrop(backdropQ);
	--CF:SetBackdropColor(0.2,0.2,0.2,1);
	--CF:SetBackdropBorderColor(0.2,0.1,0.1,1);
	CF:Hide()
	return CF;
end
function Add_Button(text,command,x,y,parent,color) 
	local Button = CreateFrame("Button", nil, parent) 
	--Button:SetBackdropColor(1,0,0,0.5);
	--Button:SetBackdropBorderColor(0.2,0.1,0.1,1);
	Button:SetWidth(20)
	Button:SetHeight(20)
	Button:SetPoint("CENTER",parent, "LEFT", x, y);
	Button:SetNormalFontObject("GameFontHighlight");
	--local f = Button:GetNormalFontObject(); f:SetTextColor(font[0],font[1],font[2],font[3]);
	--Button:SetNormalFontObject(f);
	Button:SetText(text)
	Button:RegisterForClicks("AnyUp") 
	local textureFrame4 = Button:CreateTexture("ARTWORK")
	textureFrame4:SetColorTexture(color[1],color[2],color[3],color[4])
	textureFrame4:SetAllPoints(Button)
	Button:SetScript("OnClick", function() 
		Open_chat(command);
	end )
	return Button;
end
function Add_Button_NOc(text,x,y,parent,color) 
	local Button = CreateFrame("Button", nil, parent)
	Button:SetWidth(20)
	Button:SetHeight(20)
	Button:SetPoint("CENTER",parent, "LEFT", x, y);
	Button:SetNormalFontObject("GameFontHighlight");
	--local f = Button:GetNormalFontObject(); f:SetTextColor(font[0],font[1],font[2],font[3]);
	--Button:SetNormalFontObject(f);
	Button:SetText(text)
	Button:RegisterForClicks("AnyUp") 
	local textureFrame4 = Button:CreateTexture("ARTWORK")
	textureFrame4:SetColorTexture(color[1],color[2],color[3],color[4])
	textureFrame4:SetAllPoints(Button)
	return Button;
end
function Add_Button_DEF(text,w,h,x,y,parent) 
	local Button = CreateFrame("Button", nil, parent,"OptionsButtonTemplate")
	Button:Enable(true) 
	Button:SetWidth(w)
	Button:SetHeight(h)
	Button:SetPoint("TOPLEFT",parent, "TOPLEFT", x, y);
	Button:SetNormalFontObject("GameFontHighlight");
	Button:SetText(text)
	Button:RegisterForClicks("AnyUp")
	return Button;
end

function text_box(w,h,l,t,maxL,oNumb,multi,parent)
		local f = CreateFrame("Frame", "MyScrollMessageTextFrame", parent)
			f:SetSize(w, h)
			f:SetPoint("TOPLEFT",l,t)
			f:SetBackdrop(backdropQ);
			
			if multi then 
				f.SF = CreateFrame("ScrollFrame", "$parent_DF", f, "UIPanelScrollFrameTemplate")
				f.SF:SetPoint("TOPLEFT", f, 12,-10)
				f.SF:SetPoint("BOTTOMRIGHT", f, -30, 10)
			end

			f.Text = CreateFrame("EditBox", nil, f)
			
			if multi then 
				f.Text:SetMultiLine(true)
				f.Text:SetSize(f:GetWidth()-40, f:GetHeight())
				f.Text:SetPoint("TOPLEFT", f.SF)
				f.Text:SetPoint("BOTTOMRIGHT", f.SF)
			else
				f.Text:SetSize(f:GetWidth(), f:GetHeight())
				f.Text:SetPoint("TOPLEFT", f, 12,-10)
				f.Text:SetPoint("BOTTOMRIGHT", f, -10, 10)
			end
			f.Text:SetMaxLetters(maxL);
			f.Text:SetNumeric(oNumb);
			f.Text:SetFontObject(GameFontNormal)
			f.Text:SetAutoFocus(false)
			f.Text:SetScript("OnEscapePressed", function(self) self:ClearFocus(); end) 
			if multi then f.SF:SetScrollChild(f.Text); end
			
			f:SetScript("OnMouseDown", function(self) self.Text:SetFocus(); end) 
			return f;
end

function Label(text,parent)
	local l = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal") 
	l:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 10)   
	l:SetWidth(parent:GetRight() - parent:GetLeft())   
	l:SetText(text)
end

function sPanel_play()
	if type(sFrame_add)=="table" and sFrame_add.sfBa_start.isPlay ==true then
		if tonumber(sFrame_add.tb2.timer)>0 then
			if tonumber(sFrame_add.tb2.Text:GetText())>0 then
				sFrame_add.tb2.Text:SetText(tonumber(sFrame_add.tb2.Text:GetText())-1);
				return;
			else
				sFrame_add.tb2.Text:SetText(tonumber(sFrame_add.tb2.timer));
			end
		end
		
		local t = sFrame_add.tb1.Text:GetText();
		local param={};
		
		for S in string.gmatch (t,'(%{%[[^%]]+%]%})') do
			local S1,param=cParse(S,param);
			t=t:gsub(strPlainText(S),S1);
		end;
		
		print(t);
		
		
	end
end

function sPanel_item() 
	local numWhos, totalNumWhos = C_FriendList.GetNumWhoResults();
	
	if type(sFrame_add)~="table" then
		sFrame_add=newFrame(500,300,GetScreenWidth()/2-250,GetScreenHeight()/2-150,"NCB_spFrame_add",UIParent);
			sFrame_add.sfBa_exit=Add_Button_DEF("x",30,30,465,-5,sFrame_add);
			sFrame_add.sfBa_exit:SetScript("OnClick", function() sFrame_add:Hide(); end );
			
			sFrame_add.tb1 = text_box(480,200,10,-35,0,false,true,sFrame_add);
			sFrame_add.tb1.Text:SetText("\\s {[WHOLIST]}");
			Label("|cffFFFFFFТекст|r",sFrame_add.tb1);
			
			sFrame_add.tb2 = text_box(100,25,10,-250,5,true,false,sFrame_add);
			sFrame_add.tb2.timer="0";
			Label("|cffFFFFFFТаймер|r",sFrame_add.tb2);
			
			sFrame_add.tb3 = text_box(100,25,120,-250,0,false,false,sFrame_add);
			Label("|cffFFFFFFБинд|r",sFrame_add.tb3);
			
			sFrame_add.sfBa_start=Add_Button_DEF("Пуск",60,30,430,-245,sFrame_add) ;
			sFrame_add.sfBa_start:SetScript("OnClick", function(self)
				WHOLIST={};
				if self.isPlay ~=true then
					self.isPlay=true; self:SetText("Стоп");
					if sFrame_add.tb2.Text:GetText()~="" then sFrame_add.tb2.timer=sFrame_add.tb2.Text:GetText(); end
				else
					self.isPlay=false; self:SetText("Пуск");
				end
			end );
			
			sFrame_add:Show();
	else
		if sFrame_add:IsShown() then sFrame_add:Hide(); else sFrame_add:Show(); end 
	end
end

function update_frame_btn()
	if type(LCH)=="table" and LCH.F~=nil then LCH.F:Hide(); LCH={}; end
	inInstance, instanceType = IsInInstance();
	LCH.F = Add_Frame(10,10); local W=25;
	if type(LCH_Settings)=="table" then
		if LCH_Settings.bt~=1 then for key, val in pairs(L) do L[key]=""; end end
	end

	--LCH.b_0=Add_Button_NOc("…",W,0,LCH.F,{0.1,0.5,0.6,1});W=W+25;
	--	LCH.b_0:SetScript("OnClick", function() sPanel_item(); end )
	
	LCH.b0=Add_Button_NOc("¶",W,0,LCH.F,{0,0,0,1});W=W+25;
		LCH.b0:SetScript("OnClick", function()
			if ChannelFrame:IsShown() then
				ChannelFrame:Hide();
			else
				ChannelFrame:Show();
			end 
		end )
	
	LCH.b=Add_Button(L["S"],"/s ",W,0,LCH.F,{0.5,0.5,0.5,1});W=W+25;
	LCH.b1=Add_Button(L["Y"],"/y ",W,0,LCH.F,{1, 0, 0, 1}); W=W+25;
	if IsInGroup() or (inInstance ~= nil and instanceType == "party") or (inInstance ~= nil and instanceType == "raid") or (inInstance ~= nil and instanceType == "arena") then LCH.b3=Add_Button(L["G"],"/p ",W,0,LCH.F,{0.3, 0.3, 1, 1});W=W+25; end
	if (inInstance ~= nil and instanceType == "party") then LCH.b4=Add_Button(L["P"],"/п ",W,0,LCH.F,{0.7, 0.3, 0, 1});W=W+25; end
	if inInstance ~= nil and instanceType == "pvp" then LCH.b5=Add_Button(L["BG"],"/bg ",W,0,LCH.F,{0.7, 0.3, 0, 1});W=W+25; end
	if IsInRaid() or (inInstance ~= nil and instanceType == "raid") then LCH.b6=Add_Button(L["RA"],"/ra ",W,0,LCH.F,{1, 0.5, 0, 1});W=W+25; end
	if IsInRaid() or (inInstance ~= nil and (instanceType == "raid" or instanceType == "pvp")) then LCH.b6=Add_Button(L["RW"],"/rw ",W,0,LCH.F,{1, 0.3, 0, 1});W=W+25; end
	if IsInGuild() then LCH.b7=Add_Button(L["Gi"],"/g ",W,0,LCH.F,{0, 1, 0, 1});W=W+25; end
	if IsInGuild() then LCH.b8=Add_Button(L["Of"],"/o ",W,0,LCH.F,{0, 0.5, 0, 1});W=W+25; end
	
	local btxt1="";
	for i = 0, 10, 1 do
      local id, name = GetChannelName(i);
	  if name~=nil then
		if LCH.F~=nil and LCH["b"..(10+i)]==nil then
			btxt1=i;
			if type(LCH_Settings)=="table" then if LCH_Settings.bt~=1 then btxt1=""; end end
			LCH["b"..(10+i)]=Add_Button(btxt1,"/"..i.." ",W,0,LCH.F,{1, 0.7, 0.7-(i/10), 1});W=W+25;
		end
	  end
	end; 
	LCH.F:SetWidth(W);
	LCH.F:Show();
	 
end

local function sCMD(msg, editBox)
    if msg == 'reset' then LCH_Point={x=50,y=50}; update_frame_btn(); end
end

--#####################################################################################
function frame:ADDON_LOADED(arg1)  
	if (arg1 == "LCH_Settings" and type(LCH_Settings)~="table") or not LCH_Settings then LCH_Settings={bt=1}; end

	if (arg1 == "LCH_Point" and type(LCH_Point)~="table") or not LCH_Point then LCH_Point={x=50,y=50}; end
	if type(LCH_Point)=="table" and LCH.F==nil then update_frame_btn(); end 
end

function frame:GROUP_ROSTER_UPDATE(arg1)	
	if type(LCH_Point)=="table" and LCH.F~=nil then update_frame_btn(); end
end
function frame:CONSOLE_MESSAGE(arg1)
	if type(LCH_Point)=="table" and LCH.F~=nil then update_frame_btn(); end 
end
function frame:PLAYER_STOPPED_MOVING(arg1)
	if type(LCH_Point)=="table" and LCH.F~=nil then update_frame_btn(); end
end
function frame:PLAYER_STARTED_MOVING(arg1)
	if type(LCH_Point)=="table" and LCH.F~=nil then update_frame_btn(); end
end
function frame:CRITERIA_UPDATE(arg1)
	if type(LCH_Point)=="table" and LCH.F~=nil then update_frame_btn(); end
end
--#####################################################################################

local ticker = C_Timer.NewTicker(1, function()
	if type(sFrame_add)=="table" and sFrame_add.sfBa_start.isPlay ==true and tonumber(sFrame_add.tb2.timer)>0 then
		sPanel_play();
	end
end);


SLASH_SLASHCMDNCB1='/ncb'; SlashCmdList["SLASHCMDNCB"] = sCMD;

frame:RegisterEvent("CONSOLE_MESSAGE");
frame:RegisterEvent("ADDON_LOADED");
frame:RegisterEvent("GROUP_ROSTER_UPDATE");
frame:RegisterEvent("PLAYER_STOPPED_MOVING");
frame:RegisterEvent("PLAYER_STARTED_MOVING");
frame:RegisterEvent("CRITERIA_UPDATE");
frame:SetScript("OnEvent",function(self, event, ...) self[event](self, ...) end)


