--[[
     Filename:	Localisation.lua
 
       Author:	Shaun Voysey

     Based on:	SC_ChaChing by Karin of the 'Sleeper Cartel' - Perenolde serve

      Version:	8.2.0

  Modified On:	26th June, 2019
]]--

-- Too many of the same addons with just a different Sound
-- Well, here it is...  The Sound list.
--   For those interested, PlaySoundFile() contains the Directory location,
--   so no need to store it in the Sound table.  Why bother Duplicating.
--
	SC_ChaChingSound = {
		"CashRegister.mp3",
		"Bazinga.mp3",
		"YouHaveMail.mp3"
		}

-- Localisation String variable 
--
	SC_ChaChingLoc = {}

-- Everything From here on would need to be translated and put
-- into the if statements for each specific language.
--
-- Please e-mail me with the conversions.  'sv.public <at> hotmail.com'

--
-- English (DEFAULT)
--

	SC_ChaChingLoc.BTN_PLAY = "Play";

	SC_ChaChingLoc.TEXT = "  Play this sound on %s";

	SC_ChaChingLoc.TEXT_SOLD = "Sold";
	SC_ChaChingLoc.TEXT_EXPIRED = "Expired";
	SC_ChaChingLoc.TEXT_REMOVED = "Removed";
	SC_ChaChingLoc.TEXT_OUTBID = "Outbid";

if GetLocale() == "deDE" then
--
-- German
--

elseif GetLocale() == "frFR" then
--
-- French
--

elseif GetLocale() == "esES" then
--
-- Spanish
--  And so on...

end
