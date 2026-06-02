--******************************************************************************
--     _______ __
--    |_     _|  |--.----.---.-.--.--.--.-----.-----.
--      |   | |     |   _|  _  |  |  |  |     |__ --|
--      |___| |__|__|__| |___._|________|__|__|_____|
--     ______
--    |   __ \.-----.--.--.-----.-----.-----.-----.
--    |      <|  -__|  |  |  -__|     |  _  |  -__|
--    |___|__||_____|\___/|_____|__|__|___  |_____|
--                                    |_____|
--*   @Author:              [TR]Pox
--*   @Date:                2018-03-20T01:27:01+01:00
--*   @Project:             Imperial Civil War
--*   @Filename:            RandomPirates.lua
--*   @Last modified by:    [TR]Pox
--*   @Last modified time:  2018-03-26T09:58:14+02:00
--*   @License:             This source code may only be used with explicit permission from the developers
--*   @Copyright:           © TR: Imperial Civil War Development Team
--******************************************************************************

require("RandomReplaceSpawn")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))

    Define_State("State_Init", State_Init);
end


function State_Init(message)
    if message == OnEnter then	
		PirateHeroes = {
			{"Etti_Lighter"},
			{"Skandrei_Gunship"},
			{"Crusader_Gunship"},
			{"IPV1_Gunboat"},
			{"IPV1"},
			{"Interceptor_I_Frigate"},
			{"Interceptor_II_Frigate"},
			{"Interceptor_III_Frigate"},
			{"Interceptor_IV_Frigate"},
			{"Charger_C70"},
			{"Action_IV_Support"},
			{"Raider_I_Corvette"},
			{"Raider_II_Corvette"},
			{"DP20"},
			{"Corellian_Buccaneer"},
			{"CR92A"},
			{"Lancer_Frigate"},
			{"Lancer_Frigate_PDF"},
			{"Vengeance_Frigate"},
			{"Marauder_Cruiser"},
			{"Marauder_Missile_Cruiser"},
			{"Marauder_Picket_Cruiser"},
			{"Arquitens"},
			{"Arquitens_Refit"},
			{"Galleon"},
			{"Nebulon_B_Frigate"},
			{"Carrack_Cruiser"},
			{"Quasar"},
			{"Namana_Cruiser"},
			{"Star_Galleon"},
			{"CC7700"},
			{"Victory_I_Frigate"},
			{"Strike_Cruiser_Light"},
			{"Strike_Cruiser"},
			{"MC30A"},
			{"MC30C"},
			{"Super_Transport_VI"},
			{"Super_Transport_VI_Missile"},
			{"Super_Transport_VII"},
			{"Super_Transport_VII_Missile"},
			{"Super_Transport_XI"},
			{"Super_Transport_XI_Missile"},
			{"Battle_Horn"},
			{"Neutron_Star"},
			{"PDF_DHC"},
			{"DHC_Carrier"},
			{"Rep_DHC"},
			{"DHC_Gunboat"},
			{"DHC_Gunboat"},
			{"DHC_Gunboat"},
			{"Neutron_Star_Mercenary"},
			{"Neutron_Star_Mercenary"},
			{"Neutron_Star_Mercenary"},
			{"Gladiator_I"},
			{"MC40A"},
			{"Acclamator_Patrol_Refit"},
			{"Vindicator_Cruiser"},
			{"Munificent"},
			{"Liberator_Cruiser"},
			{"Recusant_Light_Destroyer"},
			{"Immobiliser_418"},
			{"Captor"},
			{"Acclamator_I_Carrier"},
			{"Acclamator_I_Assault"},
			{"Victory_I_Star_Destroyer"},
			{"Lucrehulk_Core_Destroyer"},
			{"Space_ARC_Cruiser"},
			{"Space_ARC_Cruiser"},
			{"Space_ARC_Cruiser"},
			{"Super_Transport_XI_Modified"},
			{"Super_Transport_XI_Modified"},
			{"Super_Transport_XI_Modified"},
			{"Bulwark_I"},
			{"Dauntless"},
			{"Dauntless_Transport"},
			{"MC80_Liberty"},
			{"Refit_Venator_Star_Destroyer"},
			{"Refit_Venator_Star_Destroyer"},
			{"Refit_Venator_Star_Destroyer"},
			{"Venator_Star_Destroyer"},
			{"Providence_Carrier_Destroyer"},
			{"Invincible_Cruiser"},
			{"Keldabe"},
			{"Interdictor_Star_Destroyer"},
			{"Imperial_I_Star_Destroyer"},
			{"Imperial_I_Star_Destroyer_Patrol"},
			{"Imperial_II_Star_Destroyer"},
			{"Home_One_Type_Defender"},
			{"Home_One_Type"},
			{"Bulwark_III"},
			{"Lucrehulk_CSA"},
			{"Proficient"},
			{"Warlord_Cruiser"},
			{"Raka_Freighter_Tender"},
			{"Ubrikkian_Frigate"},
			{"Kaloth_Battlecruiser"},
			{"Super_Transport_VII_Interdictor"},
			{"Hutt_Boarding_Shuttle"},
			{"Ubrikkian_Cruiser_GCW"},
		}
		
		Random_Replacement(Object, PirateHeroes, false)
		ScriptExit()
    end
end
