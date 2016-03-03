--- toggleconsole



-- Script written by Mohamed RACHID.
-- Removing credits is illegal. You like cops, don't you?

local Title = "Université Joseph Poireau"
local Logo = "mohamed_rachid/universite_joseph_poireau/ujp_circle_transparent.png" -- 128x128 or square aspect ratio
local background = Color( 0,0,0,160 )
local menu_text = Color( 255,255,255 )
local menu_text_special = Color( 255,192,255 )
local menu_text_hovered = Color( 128,255,255 )
local menu_text_info = Color( 192,192,192 )
surface.CreateFont( "gameui_mr", {
	font="Roboto",
	size=20,
	antialias=true,
	shadow=true,
} )
surface.CreateFont( "gameui_mr_title", {
	font="Arial",
	size=40,
	antialias=true,
	shadow=true,
} )

local MenuGradient = Material( "../html/img/gradient.png", "nocull smooth" ) -- from garrysmod\lua\menu\background.lua

local DefaultUI = false
local StartDefaultUI = false
local EndCustomUI = false


local function DestroyCustomUI()
	if IsValid( CustomUI ) then
		CustomUI:Remove()
		CustomUI = nil
	end
end

local gmod_language = GetConVar( "gmod_language" ):GetString()
cvars.AddChangeCallback( "gmod_language", function( convar, oldValue, newValue )
	gmod_language = newValue
	DestroyCustomUI()
end, "gameui_mr" )
local function IsLang( lang )
	-- IsLang("fr") and "Créer" or "Create"
	return ( lang == gmod_language )
end

local function HideCustomUI()
	if IsValid( CustomUI ) then
		CustomUI:SetVisible( false )
	end
end

local function DisplayDefaultUI( UICommand )
	DefaultUI = true
	StartDefaultUI = true
	gui.ActivateGameUI()
	if UICommand then
		RunConsoleCommand( "gamemenucommand", UICommand )
	end
end

local function OpenOverlayPage( url, title )
	if !IsValid( CustomUI ) then return end
	if !IsValid( CustomUI.WebFrame ) then
		CustomUI.WebFrame = vgui.Create( "DFrame", CustomUI )
			local WebFrame = CustomUI.WebFrame
			local w,h
			_,h = CustomUI:GetSize()
			w = 661
			WebFrame:SetSize( w,h )
			WebFrame.WebPage = vgui.Create( "HTML", CustomUI.WebFrame )
				local WebPage = CustomUI.WebFrame.WebPage
				WebPage:SetSize( w-4,h-26 )
				WebPage:SetPos( 2,24 )
			local scr_w = CustomUI:GetSize()
			WebFrame:SetPos( scr_w-w,0 )
	end
	CustomUI.WebFrame:SetTitle( title or "" )
	CustomUI.WebFrame.WebPage:OpenURL( url )
end

local function PaintMenuOption( self )
	surface.SetFont( "gameui_mr" )
	surface.SetTextColor( self:IsHovered() and menu_text_hovered or self.TextColor )
	surface.SetTextPos( 0,0 )
	surface.DrawText( self.DisplayText )
end

local function AddMenuOption( CustomUI, DisplayText, TextColor )
	local Option = vgui.Create( "DButton", CustomUI )
	Option.Paint = PaintMenuOption
	surface.SetFont( "gameui_mr" )
	Option.DisplayText = DisplayText
	Option.TextColor = TextColor or menu_text
	local w,h = surface.GetTextSize( DisplayText )
	Option:SetText( "" )
	Option:SetSize( w,h )
	return Option
end

local function CreateCustomUI()
	CustomUI = vgui.Create( "DPanel" )
		CustomUI:SetSize( ScrW(),ScrH() )
		CustomUI:SetBackgroundColor( background )
		do
			local old_Paint = CustomUI.Paint
			local TextGamemode = ( IsLang("fr") and "Mode de jeu : " or "Gamemode: " )..GAMEMODE.Name
			local TextMap = ( IsLang("fr") and "Carte : " or "Map: " )..game.GetMap()
			local TextTickRate = ( IsLang("fr") and "Rafraîchissement : " or "Refreshing: " )..math.Round( 1/engine.TickInterval(), 1 ).." ticks/s"
			CustomUI.Paint = function( self, w, h, ... )
				old_Paint( self, w, h, ... )
				-- From garrysmod\lua\menu\background.lua:
				surface.SetMaterial( MenuGradient )
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.DrawTexturedRect( 0, 0, 1024, h )
				-- Display some info:
				local now = os.time()
				local TextDate = os.date( "%A %d %b %Y", now )
				local TextClock = os.date( "%H:%M:%S", now )
				local Battery = system.BatteryPower()
				local TextBattery
				if Battery > 100 then
					TextBattery = IsLang("fr") and "Sur secteur" or "Mains powered"
				else
					TextBattery = IsLang("fr") and "Sur batterie ("..Battery.."%)" or "Battery powered ("..Battery.."%)"
				end
				local TextPlayers = ( IsLang("fr") and "Joueurs : " or "Players: " )..( player.GetAny and #player.GetAny() or #player.GetAll() ).." / "..game.MaxPlayers()
				local TextPing = ( IsLang("fr") and "Ping : " or "Ping: " )..LocalPlayer():Ping().." ms"
				local widths = {}
				local width
				surface.SetFont( "HudHintTextLarge" )
				surface.SetTextColor( menu_text_info )
				local texts = {TextDate, TextClock, TextBattery, "", TextGamemode, TextMap, TextPlayers, TextPing, TextTickRate}
				for _,text in ipairs( texts ) do
					if string.len( text )!=0 then
						width = surface.GetTextSize( text )
						table.insert( widths, width )
					end
				end
				width = math.max( unpack( widths ) )
				widths = nil
				local x,y = w-width-8,8
				for _,text in ipairs( texts ) do
					if string.len( text )!=0 then
						surface.SetTextPos( x,y )
						surface.DrawText( text )
					end
					y = y+16
				end
			end
		end
		
		-- Intervalle +25 ou +45 avec séparation.
		local x,y = 70,70
		
		if ScrH() >= 600 then -- only display header with logo if sufficient resolution
			local PictureGame = vgui.Create( "DImage", CustomUI )
				PictureGame:SetImage( Logo )
				PictureGame:SetPos( x,y )
				PictureGame:SetSize( 128,128 )
			local NameGame = vgui.Create( "DLabel", CustomUI )
				NameGame:SetFont( "gameui_mr_title" )
				NameGame:SetText( Title )
				NameGame:SetTextColor( menu_text )
				NameGame:SetPos( x+128+35,y+64-20 )
				NameGame:SizeToContents()
				
			y = y+35+128
		end
		
		local ActionResume = AddMenuOption( CustomUI, IsLang("fr") and "Reprendre la partie" or "Resume Game" )
			ActionResume:SetPos( x,y )
			ActionResume.DoClick = function()
				HideCustomUI()
			end
		
		local ActionRules = AddMenuOption( CustomUI, IsLang("fr") and "Règles du serveur" or "Server's rules", menu_text_special )
			y = y+45
			ActionRules:SetPos( x,y )
			ActionRules.DoClick = function()
				OpenOverlayPage( "http://steamcommunity.com/groups/ujp_universityrp/discussions/6/458606877330197649/#forum_op_458606877330197649", ActionRules.DisplayText )
			end
		local ActionHelp = AddMenuOption( CustomUI, IsLang("fr") and "Aide du serveur" or "Server's help", menu_text_special )
			y = y+25
			ActionHelp:SetPos( x,y )
			ActionHelp.DoClick = function()
				OpenOverlayPage( "http://steamcommunity.com/groups/ujp_universityrp/discussions/6/458606877330329328/#forum_op_458606877330329328", ActionHelp.DisplayText )
			end
		local ActionAdminHelp = AddMenuOption( CustomUI, IsLang("fr") and "Pour les administrateurs" or "For administrators", menu_text_special )
			y = y+25
			ActionAdminHelp:SetPos( x,y )
			ActionAdminHelp.DoClick = function()
				OpenOverlayPage( "http://steamcommunity.com/groups/ujp_universityrp/discussions/6/412446890551812010/#forum_op_412446890551812010", ActionAdminHelp.DisplayText )
			end
		local ActionGroup = AddMenuOption( CustomUI, IsLang("fr") and "Notre groupe Steam" or "Our Steam group", menu_text_special )
			y = y+25
			ActionGroup:SetPos( x,y )
			ActionGroup.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/groups/ujp_universityrp/" )
			end
		local ActionOfferLesson = AddMenuOption( CustomUI, IsLang("fr") and "Proposer un nouveau cours" or "Offer a new lesson", menu_text_special )
			y = y+25
			ActionOfferLesson:SetPos( x,y )
			ActionOfferLesson.DoClick = function()
				gui.OpenURL( "http://steamcommunity.com/groups/ujp_universityrp/discussions/2/" )
			end
		
		local ActionSelectServer = AddMenuOption( CustomUI, IsLang("fr") and "Trouver un autre serveur" or "Find another server" )
			y = y+45
			ActionSelectServer:SetPos( x,y )
			ActionSelectServer.DoClick = function()
				DisplayDefaultUI( "openserverbrowser" )
			end
		
		local ActionDefaultUI = AddMenuOption( CustomUI, IsLang("fr") and "Afficher l'interface par défaut" or "Display default UI" )
			y = y+45
			ActionDefaultUI:SetPos( x,y )
			ActionDefaultUI.DoClick = function()
				DisplayDefaultUI()
			end
		local ActionParameters = AddMenuOption( CustomUI, IsLang("fr") and "Paramètres" or "Options" )
			y = y+25
			ActionParameters:SetPos( x,y )
			ActionParameters.DoClick = function()
				DisplayDefaultUI( "openoptionsdialog" )
			end
		
		local ActionDisconnect = AddMenuOption( CustomUI, IsLang("fr") and "Se déconnecter" or "Disconnect" )
			y = y+45
			ActionDisconnect:SetPos( x,y )
			ActionDisconnect.DoClick = function()
				DisplayDefaultUI( "disconnect" )
			end
		local ActionQuit = AddMenuOption( CustomUI, IsLang("fr") and "Quitter" or "Quit" )
			y = y+25
			ActionQuit:SetPos( x,y )
			ActionQuit.DoClick = function()
				DisplayDefaultUI( "quit" )
			end
end

local function DisplayCustomUI()
	if !IsValid( CustomUI ) then
		CreateCustomUI()
	end
	CustomUI:SetVisible( true )
	CustomUI:MakePopup()
end

local ConsoleKeys = {}
for k=1,159 do
	if input.LookupKeyBinding( k ) == "toggleconsole" then
		table.insert( ConsoleKeys, k )
	end
end

hook.Add( "PreRender", "gameui_mr", function()
	if EndCustomUI then
		EndCustomUI = false
		HideCustomUI()
	end
	if gui.IsGameUIVisible() then
		if !LocalPlayer():IsTyping() and !IsValid( vgui.GetKeyboardFocus() ) then
			for _,ConsoleKey in ipairs( ConsoleKeys ) do
				if input.IsButtonDown( ConsoleKey ) then
					DefaultUI = true -- display the console
					break
				end
			end
		end
		-- This step toggles the custom UI when Escape is pressed.
		if !DefaultUI then
			if !IsValid( CustomUI ) or !CustomUI:IsVisible() then
				DisplayCustomUI()
			else
				DefaultUI = false
				HideCustomUI()
			end
			gui.HideGameUI()
		end
	elseif StartDefaultUI then
		-- The default game UI is opening.
		StartDefaultUI = false
		EndCustomUI = true -- delayed for smooth transition
	else
		-- The default game UI is closed.
		DefaultUI = false
	end
end )

-- Live-refresh:
DestroyCustomUI()
