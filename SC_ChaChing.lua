--[[
     Filename:	SC_ChaChing.lua 

       Author:	Shaun Voysey

     Based on:	SC_ChaChing by Karin of the 'Sleeper Cartel' - Perenolde server

      Version:	6.2.0

  Modified On:	1st July, 2015

        Notes:

	6.2.0	toc upgrade for 6.2.

	6.1.0	toc upgrade to 6.1.

	5.4.1	Added a few more sounds to the Auction Sold.
			Using a Dropdown list to select.

	5.4.0	toc upgrade to 5.4.

	5.0.1	Checked to make sure we are not using Blizzards global variable '_'.

	5.0.0	Changed PLAYER_LOGIN to PLAYER_ENTERING_WORLD.

	4.3.0	Added a 1 second buffer for playing the Sounds.
			Should stop that annoying multiple play when mutilple Auctions fail to sell.

			Also removed the coding for inserting the 0 values.  Seems that they have started saving these values.

	4.2.0	Removed Mars Message Parser from the addon.  It's extra baggage that is no longer needed.
			Probably has not been for some time, but I am still trying to get my head around Regex.

			Also tweaked some of the logic.  No need to set 0's if the defaults have just been created.

	4.0.0	Some modifications in the loading sections.  Need to pass the variables now.
			Also using the GetRealmname() function instead of GetCVAR()

			Changed all the wav's to mp3's.  PlaySoundFile() no longer does wav.

	3.1.0	Just commented a few functions

	2.2.0	Changed to use The Interface Option --> Addons

	2.1.0	Added a GUI for setting what events to run the sounds on.
]]--


--
-- GUI Functions
--

-- This function is run on pressing the Ok or Close Buttons.
--   Sets the Status of the Saved Variables to the new settings
--
function SC_ChaChingPanel_Close()
    SC_ChaChing_Config[realm].Sold = SC_ChaChingGUIFrame_CBSold:GetChecked();
    SC_ChaChing_Config[realm].Expired = SC_ChaChingGUIFrame_CBExpired:GetChecked();
    SC_ChaChing_Config[realm].Outbid = SC_ChaChingGUIFrame_CBOutbid:GetChecked();
    SC_ChaChing_Config[realm].Removed = SC_ChaChingGUIFrame_CBRemoved:GetChecked();

    SC_ChaChing_Config[realm].Sound = UIDropDownMenu_GetText(SC_ChaChingSoundDropDown);
end


-- This function is run on pressing the Cancel Button or from the PLAYER_ENTERING_WORLD event function.
--   Sets the status of the Check Boxes to the Values of the Saved Variables.
--
function SC_ChaChingPanel_CancelOrLoad()
    SC_ChaChingGUIFrame_CBSold:SetChecked(SC_ChaChing_Config[realm].Sold);
    SC_ChaChingGUIFrame_CBExpired:SetChecked(SC_ChaChing_Config[realm].Expired);
    SC_ChaChingGUIFrame_CBOutbid:SetChecked(SC_ChaChing_Config[realm].Outbid);
    SC_ChaChingGUIFrame_CBRemoved:SetChecked(SC_ChaChing_Config[realm].Removed);

	UIDropDownMenu_SetText(SC_ChaChingSoundDropDown, SC_ChaChing_Config[realm].Sound);
end


-- The GUI OnLoad function.
--
function SC_ChaChingPanel_OnLoad(panel)
    -- Set the Text for the Check boxes.
    --
    SC_ChaChingGUIFrame_CBSoldText:SetText(string.format(SC_ChaChingLoc.TEXT, SC_ChaChingLoc.TEXT_SOLD));
    SC_ChaChingGUIFrame_CBExpiredText:SetText(string.format(SC_ChaChingLoc.TEXT, SC_ChaChingLoc.TEXT_EXPIRED));
    SC_ChaChingGUIFrame_CBOutbidText:SetText(string.format(SC_ChaChingLoc.TEXT, SC_ChaChingLoc.TEXT_OUTBID));
    SC_ChaChingGUIFrame_CBRemovedText:SetText(string.format(SC_ChaChingLoc.TEXT, SC_ChaChingLoc.TEXT_REMOVED));

    SC_ChaChingGUIFrame_Play:SetText(SC_ChaChingLoc.BTN_PLAY);


    -- Set the name for the Category for the Panel
    --
    panel.name = "SC_ChaChing " .. GetAddOnMetadata("SC_ChaChing", "Version");

    -- When the player clicks okay, set the Saved Variables to the current Check Box setting
    --
    panel.okay = function (self) SC_ChaChingPanel_Close(); end;

    -- When the player clicks cancel, set the Check Box status to the Saved Variables.
    panel.cancel = function (self)  SC_ChaChingPanel_CancelOrLoad();  end;

    -- Add the panel to the Interface Options
    --
    InterfaceOptions_AddCategory(panel);
end


-- Defined Functions
--

-- Initialise all Variables.  These are saved Realm wide.
--
function SC_ChaChing_Initialise()

    -- Get Realm name and Check for validity
    --
    realm = GetRealmName();

    if (SC_ChaChing_init or (not realm)) then
        return;
    end


    -- initialise Realm data structures
    --
    if (SC_ChaChing_Config == nil) then
        SC_ChaChing_Config = { };
    end

    -- Set the default list if the Realm Variable does not exist
    --
    if (SC_ChaChing_Config[realm] == nil) then
        SC_ChaChing_Config[realm] = { };

        SC_ChaChing_Config[realm].Sound = "CashRegister.mp3";

        SC_ChaChing_Config[realm].Sold = true;
        SC_ChaChing_Config[realm].Expired = false;
        SC_ChaChing_Config[realm].Outbid = false;
        SC_ChaChing_Config[realm].Removed = false;
    end;

    -- Set the default Sound if the Variable does not exist
    --   For use of those who have used this addon before
	--
    if (SC_ChaChing_Config[realm].Sound == nil) then
        SC_ChaChing_Config[realm].Sound = "CashRegister.mp3";
    end;


    -- Creates and initialises the DropDown frame
    --
	CreateFrame("Frame", "SC_ChaChingSoundDropDown", SC_ChaChingGUIFrame, "UIDropDownMenuTemplate");

	UIDropDownMenu_Initialize(SC_ChaChingSoundDropDown, SC_ChaChingSoundDropDown_Init);

	UIDropDownMenu_JustifyText(SC_ChaChingSoundDropDown, "LEFT");
	UIDropDownMenu_SetWidth(SC_ChaChingSoundDropDown, 150);
	UIDropDownMenu_SetText(SC_ChaChingSoundDropDown, SC_ChaChing_Config[realm].Sound);

	SC_ChaChingSoundDropDown:Show();


    -- Set variable to say we have been through this.
    --
    SC_ChaChing_init = true;
end


-- Initialising the DropDown box
--
function SC_ChaChingSoundDropDown_Init(self)

	-- Gets the current text in the DropDown frame
	--
	local ddtext = UIDropDownMenu_GetText(SC_ChaChingSoundDropDown);

	local info = UIDropDownMenu_CreateInfo();

	for index, filename in ipairs(SC_ChaChingSound) do
		info.text = filename;

		-- Give it a tick instead of a radio button, and only tick when selected
		--
		info.isNotRadio = true;
		info.checked = (filename == ddtext);

		-- Function to be called when the menu option is selected
		--
		info.func = function (self)
			-- Sets the text of the DropDown frame
			--
			UIDropDownMenu_SetText(SC_ChaChingSoundDropDown, self:GetText());
		end

		UIDropDownMenu_AddButton(info);
	end
end


-- I'm being Loaded.  I want to register these events..
--
function SC_ChaChing_OnLoad(frame)
    -- respond to the Player logging in.
    --
    frame:RegisterEvent("PLAYER_ENTERING_WORLD");

    --respond to the System Messages in Chat.
    --
    frame:RegisterEvent("CHAT_MSG_SYSTEM");
end


-- I want to run certain things when these EVENTS fire..
--
function SC_ChaChing_OnEvent(frame, event, arg1, ...)
    
    if (event == "PLAYER_ENTERING_WORLD") then

        -- Initialise and set the Check Box and sound status from the Saved Variables.
        --
        SC_ChaChing_Initialise();
        SC_ChaChingPanel_CancelOrLoad();

        SC_ChaChing_Time = GetTime();

    elseif(event == "CHAT_MSG_SYSTEM") then

        -- We have a system Chat message,  let's see what needs to be done
        --
        if string.match(arg1, string.gsub(ERR_AUCTION_SOLD_S, "(%%s)", ".+")) ~= nil then
            SC_ChaChing_Sound(SC_ChaChing_Config[realm].Sound, SC_ChaChing_Config[realm].Sold);

        elseif string.match(arg1, string.gsub(ERR_AUCTION_EXPIRED_S, "(%%s)", ".+")) ~= nil then
            SC_ChaChing_Sound("Sound1.mp3", SC_ChaChing_Config[realm].Expired);

        elseif string.match(arg1, string.gsub(ERR_AUCTION_OUTBID_S, "(%%s)", ".+")) ~= nil then
            SC_ChaChing_Sound("Sound2.mp3", SC_ChaChing_Config[realm].Outbid);

        elseif string.match(arg1, string.gsub(ERR_AUCTION_REMOVED_S, "(%%s)", ".+")) ~= nil then
            SC_ChaChing_Sound("Sound3.mp3", SC_ChaChing_Config[realm].Removed);

        end;
    end;
end


-- Play <SoundFile> if <PlaySound> is true.
--
function SC_ChaChing_Sound(SoundFile, PlaySound)
    local TempTime = GetTime();

    -- Only play if the last sound played over 1 second a go.  Really annoying.
    --
    if (PlaySound and (TempTime - SC_ChaChing_Time) > 1) then
        SC_ChaChing_Time = TempTime;

        PlaySoundFile("Interface\\AddOns\\SC_ChaChing\\Sounds\\" .. SoundFile);
    end
end

--  CHAT_MSG_SYSTEM 
--    ERR_AUCTION_SOLD_S 
--      A buyer has been found for your auction of %s.
--      A buyer has been found for your auction of Runn Tum Tuber Surprise.

--    ERR_AUCTION_EXPIRED_S 
--      Your auction of %s has expired.
--      Your auction of Runn Tum Tuber Surprise has expired.

--    ERR_AUCTION_OUTBID_S 
--      You have been outbid on %s.
--      You have been outbid on Runn Tum Tuber Surprise.

--    ERR_AUCTION_REMOVED_S 
--      Your auction of %s has been cancelled by the seller.
--      Your auction of Runn Tum Tuber Surprise has been cancelled by the seller.


--  End of Main Routines
--
