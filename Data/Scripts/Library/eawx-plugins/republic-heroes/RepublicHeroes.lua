--**************************************************************************************************
--*    _______ __                                                                                  *
--*   |_     _|  |--.----.---.-.--.--.--.-----.-----.                                              *
--*     |   | |     |   _|  _  |  |  |  |     |__ --|                                              *
--*     |___| |__|__|__| |___._|________|__|__|_____|                                              *
--*    ______                                                                                      *
--*   |   __ \.-----.--.--.-----.-----.-----.-----.                                                *
--*   |      <|  -__|  |  |  -__|     |  _  |  -__|                                                *
--*   |___|__||_____|\___/|_____|__|__|___  |_____|                                                *
--*                                   |_____|                                                      *
--*                                                                                                *
--*                                                                                                *
--*       File:              RepublicHeroes.lua                                                    *
--*       File Created:      Monday, 24th February 2020 02:19                                      *
--*       Author:            [TR] Jorritkarwehr                                                    *
--*       Last Modified:     Monday, 24th February 2020 02:34                                      *
--*       Modified By:       [TR] Jorritkarwehr                                                    *
--*       Copyright:         Thrawns Revenge Development Team                                      *
--*       License:           This code may not be used without the author's explicit permission    *
--**************************************************************************************************

require("PGStoryMode")
require("deepcore/std/class")
require("eawx-util/StoryUtil")
require("eawx-util/UnitUtil")
require("HeroSystem")
require("SetFighterResearch")

RepublicHeroes = class()

function RepublicHeroes:new(gc, herokilled_finished_event, human_player)
	self.human_player = human_player
	gc.Events.GalacticProductionFinished:attach_listener(self.on_production_finished, self)
	herokilled_finished_event:attach_listener(self.on_galactic_hero_killed, self)
	self.CommandStaff_Initialized = false

	crossplot:subscribe("COMMAND_STAFF_INITIALIZE", self.CommandStaff_Initialize, self)
	crossplot:subscribe("COMMAND_STAFF_SLOT_ADJUST", self.CommandStaff_Slot_Adjust, self)
	crossplot:subscribe("COMMAND_STAFF_LOCKIN", self.CommandStaff_Lockin, self)
	crossplot:subscribe("COMMAND_STAFF_EXIT", self.CommandStaff_Exit, self)
	crossplot:subscribe("COMMAND_STAFF_RETURN", self.CommandStaff_Return, self)
	crossplot:subscribe("COMMAND_STAFF_CENSUS", self.CommandStaff_Census, self)

	crossplot:subscribe("NR_FILTER_ADD", self.Add_Filter_Options, self)
	crossplot:subscribe("NR_FILTER_REMOVE", self.Remove_Filter_Options, self)

	crossplot:subscribe("ERA_TRANSITION", self.Era_Transitions, self)

	crossplot:subscribe("NR_ELECTION", self.Chief_Of_State_Transition, self)
	crossplot:subscribe("NJO_CREATED", self.New_Jedi_Order_Init, self)
	crossplot:subscribe("NCMP2_HEROES", self.NCMP2_handler, self)
	crossplot:subscribe("MEDIATOR_HEROES", self.Mediator_Heroes, self)
	crossplot:subscribe("NR_CANON_ADMIRALS", self.Canon_Heroes, self)

	self.library = {
		["SUPCOM"] = {
			total_slots = 1,        --Max slot number. Set at the start of the GC and never change
			free_hero_slots = 1,    --Slots open to buy
			vacant_hero_slots = 0,  --Slots that need another action to move to free
			vacant_limit = 2,       --Number of times a lost slot can be reopened
			initialized = false,
			retire_object = "RETIRE_SUPCOMS",
			full_list = { --All options for reference operations
				["Ackbar"] = {"ACKBAR_ASSIGN",{"ACKBAR_HOME_ONE","ACKBAR_GALACTIC_VOYAGER","ACKBAR_GUARDIAN"},"Gial Ackbar"},
				["Drayson"] = {"DRAYSON_SUPCOM_ASSIGN",{"DRAYSON_NEW_HOPE"},"Hiram Drayson"},
				["Nantz"] = {"NANTZ_SUPCOM_ASSIGN",{"NANTZ_INDEPENDENCE_SUPCOM","NANTZ_FAITHFUL_WATCHMAN_SUPCOM"},"Firmus Nantz"},
				--Duplicate entry to match the high command form count
				["Iblis"] = {"IBLIS_SUPCOM_ASSIGN",{"IBLIS_SELONIAN_FIRE_SUPCOM","IBLIS_SELONIAN_FIRE_SUPCOM","IBLIS_BAIL_ORGANA_SUPCOM","IBLIS_HARBINGER_SUPCOM"},"Garm Bel Iblis"},
				["Sovv"] = {"SOVV_SUPCOM_ASSIGN",{"SOVV_VOICE_OF_THE_PEOPLE_SUPCOM","SOVV_VOICE_OF_THE_PEOPLE_SUPCOM"},"Sien Sovv"},
				["Abaht"] = {"ABAHT_SUPCOM_ASSIGN",{"ABAHT_INTREPID_SUPCOM"},"Etahn A'baht"},
				["Krefey"] = {"KREFEY_SUPCOM_ASSIGN",{"KREFEY_RALROOST_SUPCOM"},"Traest Kre'fey"},
			},
			available_list = {--Heroes currently available for purchase. Seeded with those who have no special prereqs
				"Ackbar",
				"Drayson",
				"Nantz",
			},
			story_locked_list = {--Heroes not accessible, but able to return with the right conditions
			},
			active_player = Find_Player("Rebel"),
			extra_name = "EXTRA_SUPCOM_SLOT",
			random_name = "RANDOM_SUPCOM_ASSIGN",
			global_display_list = "NR_SUPCOM_LIST", --Name of global array used for documention of currently active heroes
			disabled = true
		},

		["HIGHCOM"] = {
			total_slots = 12,        --Max slot number. Set at the start of the GC and never change
			free_hero_slots = 12,    --Slots open to buy
			vacant_hero_slots = 0,  --Slots that need another action to move to free
			vacant_limit = 3,       --Number of times a lost slot can be reopened
			initialized = false,
			retire_object = "RETIRE_HIGHCOMS",
			full_list = { --All options for reference operations
				["Nantz"] = {"NANTZ_ASSIGN",{"NANTZ_INDEPENDENCE","NANTZ_FAITHFUL_WATCHMAN"},"Firmus Nantz"},
				["Iblis"] = {"IBLIS_ASSIGN",{"IBLIS_PEREGRINE","IBLIS_SELONIAN_FIRE","IBLIS_BAIL_ORGANA","IBLIS_HARBINGER"},"Garm Bel Iblis"},
				["Drayson"] = {"DRAYSON_ASSIGN",{"DRAYSON_TRUE_FIDELITY"},"Hiram Drayson"},
				["Kalback"] = {"KALBACK_ASSIGN",{"KALBACK_JUSTICE"},"Kalback"},
				["Tallon"] = {"TALLON_ASSIGN",{"TALLON_SILENT_WATER"},"Adar Tallon"},
				["Abaht"] = {"ABAHT_ASSIGN",{"ABAHT_INTREPID"},"Etahn A'baht"},
				["Nammo"] = {"NAMMO_ASSIGN",{"NAMMO_DEFIANCE"},"Nammo"},
				["Krefey"] = {"KREFEY_ASSIGN",{"KREFEY_RALROOST"},"Traest Kre'fey"},
				["Burke"] = {"BURKE_ASSIGN",{"BURKE_REMEMBER_ALDERAAN"},"Willham Burke"},
				["Massa"] = {"MASSA_ASSIGN",{"MASSA_LUCREHULK_AUXILIARY","MASSA_LUCREHULK_CARRIER"},"Voon Massa"},
				["Dorat"] = {"DORAT_ASSIGN",{"DORAT_ARROW_OF_SULLUST"},"Chel Dorat"},
				["Han_Solo_Intrepid"] = {"TEMPLATE_FLAGSHIP_SWAP",{"HAN_SOLO_INTREPID"},"Han Solo",["no_random"] = true, ["required_unit"] = "MILLENNIUM_FALCON", ["required_team"] = "HAN_SOLO_TEAM"}, --Han's forms are so different that it's easier to handle them separately
				---His assign is handled weirdly to require Abaht but not an open slot
			},
			available_list = {--Heroes currently available for purchase. Seeded with those who have no special prereqs
				"Nantz",
				"Drayson",
				"Kalback",
				"Tallon",
				"Nammo",
				"Burke",
				"Massa",
				"Dorat",
			},
			story_locked_list = {--Heroes not accessible, but able to return with the right conditions
			},
			active_player = Find_Player("Rebel"),
			extra_name = "EXTRA_HIGHCOM_SLOT",
			random_name = "RANDOM_HIGHCOM_ASSIGN",
			global_display_list = "NR_HIGHCOM_LIST", --Name of global array used for documention of currently active heroes
			disabled = true
		},

		["ADMIRAL"] = {
			total_slots = 18,        --Max slot number. Set at the start of the GC and never change
			free_hero_slots = 18,    --Slots open to buy
			vacant_hero_slots = 0,  --Slots that need another action to move to free
			vacant_limit = 5,       --Number of times a lost slot can be reopened
			initialized = false,
			retire_object = "RETIRE_ADMIRALS",
			full_list = { --All options for reference operations
				["Sovv"] = {"SOVV_ASSIGN",{"SOVV_DAUNTLESS","SOVV_VOICE_OF_THE_PEOPLE"},"Sien Sovv"},
				["Han_Solo_Mon_Remonda"] = {"HAN_SOLO_MON_REMONDA_ASSIGN",{"HAN_SOLO_MON_REMONDA"},"Han Solo",["no_random"] = true, ["required_unit"] = "MILLENNIUM_FALCON", ["required_team"] = "HAN_SOLO_TEAM"},
				["Ragab"] = {"RAGAB_ASSIGN",{"RAGAB_EMANCIPATOR"},"Ragab"},
				["Vantai"] = {"VANTAI_ASSIGN",{"VANTAI_MOONSHADOW"},"Kir Vantai"},
				["Whyrrryk"] = {"WHYRRRYK_ASSIGN",{"WHYRRRYK_OBI_WAN"},"Whyrrryk"},
				["Holt"] = {"HOLT_ASSIGN",{"HOLT_SIMOOM"},"Arhul Holt"},
				["Krane"] = {"KRANE_ASSIGN",{"KRANE_RAND_ECLIPTIC"},"Krane"},
				["Brand"] = {"BRAND_ASSIGN",{"BRAND_INDOMITABLE","BRAND_YALD"},"Turk Brand"},
				["Bell"] = {"BELL_ASSIGN",{"BELL_SWIFT_LIBERTY","BELL_ENDURANCE"},"Areta Bell"},
				["Snunb"] = {"SNUNB_ASSIGN",{"SNUNB_ANTARES_SIX","SNUNB_RESOLVE"},"Syub Snunb"},
				["Ackdool"] = {"ACKDOOL_ASSIGN",{"ACKDOOL_MEDIATOR"},"Ackdool"},
				["Matthews"] = {"MATTHEWS_ASSIGN",{"MATTHEWS_SIBWARRA"},"Ty Matthews"},
				["Grant"] = {"GRANT_ASSIGN",{"GRANT_ORIFLAMME_NR"},"Octavian Grant"},
				["Iillor"] = {"IILLOR_ASSIGN",{"IILLOR_CORUSCA_RAINBOW"},"Uwlla Iillor"},
				["Lando"] = {"LANDO_ASSIGN",{"LANDO_LIBERATOR","LANDO_ALLEGIANCE"},"Lando Calrissian",["no_random"] = true},
				["Viedas"] = {"VIEDAS_ASSIGN",{"VIEDAS_SOLIDARITY"},"Yat-De Viedas"},
				["Raddus"] = {"RADDUS_ASSIGN",{"RADDUS_PROFUNDITY"},"Raddus"},
				["Hera"] = {"HERA_ASSIGN",{"HERA_STARHAWK"},"Hera Syndulla"},
				-- Historical command staff
				["Standish"] = {"TEMPLATE_FLAGSHIP_SWAP",{"STANDISH_AAF2"},"Anton Standish",["Locked"] = true},
			},
			available_list = {--Heroes currently available for purchase. Seeded with those who have no special prereqs
				"Sovv",
				"Han_Solo_Mon_Remonda",
				"Ragab",
				"Vantai",
				"Snunb",
				"Bell",
				"Holt",
				"Krane",
				"Viedas",
				"Hera",
			},
			story_locked_list = {--Heroes not accessible, but able to return with the right conditions
				["Lando"] = true,
				
			},
			active_player = Find_Player("Rebel"),
			extra_name = "EXTRA_ADMIRAL_SLOT",
			random_name = "RANDOM_ADMIRAL_ASSIGN",
			global_display_list = "NR_ADMIRAL_LIST", --Name of global array used for documention of currently active heroes
			disabled = false
		},

		["ARMY"] = {
			total_slots = 12,        --Max slot number. Set at the start of the GC and never change
			free_hero_slots = 12,    --Slots open to buy
			vacant_hero_slots = 0,  --Slots that need another action to move to free
			vacant_limit = 3,       --Number of times a lost slot can be reopened
			initialized = false,
			retire_object = "RETIRE_GENERALS",
			full_list = { --All options for reference operations
				["Calrissian"] = {"CALRISSIAN_ASSIGN",{"LANDO_CALRISSIAN"},"Lando Calrissian", ["Companies"] = {"LANDO_CALRISSIAN_TEAM"}},
				["Northal"] = {"NORTHAL_ASSIGN",{"VIN_NORTHAL"},"Vin Northal", ["Companies"] = {"VIN_NORTHAL_TEAM"}},
				["Kryll"] = {"KRYLL_ASSIGN",{"KRYLL"},"Kryll", ["Companies"] = {"KRYLL_TEAM"}},
				["Garret"] = {"GARRET_ASSIGN",{"ROGAR_GARRET"},"Rogar Garret", ["Companies"] = {"ROGAR_GARRET_TEAM"}},
				["Madine"] = {"MADINE_ASSIGN",{"CRIX_MADINE"},"Crix Madine", ["Companies"] = {"CRIX_MADINE_TEAM"}},
				["Cracken"] = {"CRACKEN_ASSIGN",{"AIREN_CRACKEN"},"Airen Cracken", ["Companies"] = {"AIREN_CRACKEN_TEAM"}},
				["Taskeen"] = {"TASKEEN_ASSIGN",{"TYR_TASKEEN"},"Tyr Taskeen", ["Companies"] = {"TYR_TASKEEN_TEAM"}},
				["Tantor"] = {"TANTOR_ASSIGN",{"BRENN_TANTOR"},"Brenn Tantor", ["Companies"] = {"BRENN_TANTOR_TEAM"}},
				["Jamiro"] = {"JAMIRO_ASSIGN",{"TIGRAN_JAMIRO"},"Tigran Jamiro", ["Companies"] = {"TIGRAN_JAMIRO_TEAM"}},
				["Veertag"] = {"VEERTAG_ASSIGN",{"DURON_VEERTAG"},"Duron Veertag", ["Companies"] = {"DURON_VEERTAG_TEAM"}},
				["Tulon"] = {"TULON_ASSIGN",{"BERI_TULON"},"Beri Tulon", ["Companies"] = {"BERI_TULON_TEAM"}},
				["Tia_Ghia"] = {"TIA_GHIA_ASSIGN",{"TIA_GHIA_T47_AIRSPEEDER"},"Tia and Ghia", ["Companies"] = {"TIA_GHIA_TEAM"}},
			},
			available_list = {--Heroes currently available for purchase. Seeded with those who have no special prereqs
				"Calrissian",
				"Northal",
				"Kryll",
				"Garret",
				"Madine",
				"Cracken",
				"Taskeen",
				"Tantor",
				"Jamiro",
				"Veertag",
				"Tulon",
				"Tia_Ghia",
			},
			story_locked_list = {},--Heroes not accessible, but able to return with the right conditions
			active_player = Find_Player("Rebel"),
			extra_name = "EXTRA_GENERAL_SLOT",
			random_name = "RANDOM_GENERAL_ASSIGN",
			global_display_list = "NR_GENERAL_LIST", --Name of global array used for documention of currently active heroes
			disabled = true
		},

		["JEDI"] = {
			total_slots = 5,        --Max slot number. Set at the start of the GC and never change
			free_hero_slots = 5,    --Slots open to buy
			vacant_hero_slots = 0,  --Slots that need another action to move to free
			vacant_limit = 1,       --Number of times a lost slot can be reopened
			initialized = false,
			retire_object = "RETIRE_COUNCIL",
			full_list = { --All options for reference operations
				["Corran"] = {"CORRAN_ASSIGN",{"CORRAN_HORN"},"Corran Horn", ["Companies"] = {"CORRAN_HORN_TEAM"}},
				["Kyle"] = {"KYLE_ASSIGN",{"KYLE_KATARN_DUMMY"},"Kyle Katarn", ["Companies"] = {"KATARN_TEAM"}},
				["Mara"] = {"MARA_ASSIGN",{"MARA_JADE_LIGHTSABER"},"Mara Jade", ["Companies"] = {"MARA_SABER_TEAM"}},
				["Cilghal"] = {"CILGHAL_ASSIGN",{"CILGHAL"},"Cilghal", ["Companies"] = {"CILGHAL_TEAM"}},
				["Mander"] = {"TEMPLATE_FLAGSHIP_SWAP",{"MANDER_ZUMA"},"Mander Zuma", ["Companies"] = {"ZUMA_TEAM"},["Locked"] = true},
			},
			available_list = {--Heroes currently available for purchase. Seeded with those who have no special prereqs
				"Kyle",
			},
			story_locked_list = {},--Heroes not accessible, but able to return with the right conditions
			active_player = Find_Player("Rebel"),
			extra_name = "EXTRA_COUNCIL_SLOT",
			random_name = "RANDOM_COUNCIL_ASSIGN",
			global_display_list = "NR_JEDI_LIST", --Name of global array used for documention of currently active heroes
			disabled = true
		},
	}

	self.fighter_assigns = {
		"Wedge_Rogues_Location_Set",
		"Salm_Location_Set",
		"Ranulf_Trommer_Location_Set",
		"Jake_Farrell_Location_Set",
	}
	self.fighter_assign_enabled = false

	self.viewers = {
		["VIEW_ADMIRALS"] = 1,
		["VIEW_GENERALS"] = 2,
		["VIEW_COUNCIL"] = 3,
		["VIEW_COS"] = 4,
		["VIEW_FIGHTERS"] = 5,
		["VIEW_HIGHCOMS"] = 6,
		["VIEW_SUPCOMS"] = 7,
	}

	self.old_view = 1

	self.CoS_dummies = {
		"Candidate_Random",
		"Candidate_Feylya",
		"Candidate_Gavrisom",
		"Candidate_Mothma",
		"Candidate_Kerrithrarr",
		"Candidate_Organa_Solo",
		"Candidate_SoBilles",
		"Candidate_Tevv",
	}
	self.CoS_dummies_enabled = false
	self.COS_Organa_Solo_Active = false
	self.COS_Organa_Solo_Admiral_Power_Mode_On = false
	self.COS_Organa_Solo_General_Power_Mode_On = false
	self:Chief_Of_State_Transition()

	self.NJOspeech = false
	self.NJOinit = false
end


--shared functions

function RepublicHeroes:on_production_finished(planet, object_type_name)
	--Logger:trace("entering RepublicHeroes:on_production_finished")
	if not self.CommandStaff_Initialized then
		self:CommandStaff_Initialize()
	end

	if object_type_name == "CALRISSIAN_G2A" then
		Handle_Hero_Exit("Calrissian", self.library["ARMY"], true)
		Handle_Hero_Add("Lando", self.library["ADMIRAL"])
	elseif object_type_name == "LANDO_A2G" or object_type_name == "LANDO_A2G_TWO" then
		Handle_Hero_Exit("Lando", self.library["ADMIRAL"], true)
		Handle_Hero_Add("Calrissian", self.library["ARMY"])
	elseif object_type_name == "JEDI_TEMPLE" then
		self:New_Jedi_Order()
	elseif object_type_name == "SOVVDAUNT2VP" then
		Handle_Hero_Add("Sovv", self.library["SUPCOM"])
	else
		if self.viewers[object_type_name] and self.library["ADMIRAL"].active_player.Is_Human() then
			self:switch_views(self.viewers[object_type_name])
			local viewer = Find_First_Object(object_type_name)
			if TestValid(viewer) then
				viewer.Despawn()
			end
		end

		local action, tag = Handle_Build_Options(object_type_name, self.library["SUPCOM"])

		if action == "ASSIGN" then
			if self.library["ADMIRAL"].full_list[tag] then
				Handle_Hero_Exit(tag, self.library["ADMIRAL"], true)
				local oldid = self.library["SUPCOM"].full_list[tag].unit_id
				local newid = self.library["ADMIRAL"].full_list[tag].unit_id
				if newid == nil then
					newid = 1
				end
				local lowunit = self.library["ADMIRAL"].full_list[tag][2][newid]
				local newunit = self.library["SUPCOM"].full_list[tag][2][newid]
				if oldid ~= newid then
					if oldid == nil then
						oldid = 1
					end
					local oldunit = self.library["SUPCOM"].full_list[tag][2][oldid]
					UnitUtil.ReplaceAtLocation(oldunit, newunit)
				end
				Transfer_Fighter_Hero(string.upper(lowunit), string.upper(newunit))
			end

			if self.library["HIGHCOM"].full_list[tag] then
				Handle_Hero_Exit(tag, self.library["HIGHCOM"], true)
				local oldid = self.library["SUPCOM"].full_list[tag].unit_id
				local newid = self.library["HIGHCOM"].full_list[tag].unit_id
				if newid == nil then
					newid = 1
				end
				local lowunit = self.library["HIGHCOM"].full_list[tag][2][newid]
				local newunit = self.library["SUPCOM"].full_list[tag][2][newid]
				if oldid ~= newid then
					if oldid == nil then
						oldid = 1
					end
					local oldunit = self.library["SUPCOM"].full_list[tag][2][oldid]
					UnitUtil.ReplaceAtLocation(oldunit, newunit)
				end
				Transfer_Fighter_Hero(string.upper(lowunit), string.upper(newunit))
			end
		end

		if action == "RETIRE" then
			StoryUtil.ShowScreenText("supcom retire", 5, nil, {r = 255, g = 0, b = 0})
			for _, itag in pairs(tag) do
				StoryUtil.ShowScreenText("supcom " .. itag, 5, nil, {r = 255, g = 0, b = 0})
				if self.library["ADMIRAL"].full_list[itag] then
					Handle_Hero_Add(itag, self.library["ADMIRAL"])
					local unitid = self.library["ADMIRAL"].full_list[itag].unit_id
					if unitid == nil then
						unitid = 1
					end
					local lowunit = self.library["ADMIRAL"].full_list[itag][2][unitid]
					local highunit = self.library["SUPCOM"].full_list[itag][2][unitid]
					Transfer_Fighter_Hero(string.upper(highunit), string.upper(lowunit))
				end
				if self.library["HIGHCOM"].full_list[itag] then
					Handle_Hero_Add(itag, self.library["HIGHCOM"], true)
					local unitid = self.library["HIGHCOM"].full_list[itag].unit_id
					if unitid == nil then
						unitid = 1
					end
					local lowunit = self.library["HIGHCOM"].full_list[itag][2][unitid]
					local highunit = self.library["SUPCOM"].full_list[itag][2][unitid]
					Transfer_Fighter_Hero(string.upper(highunit), string.upper(lowunit))
				end
			end
		end

		local action, tag = Handle_Build_Options(object_type_name, self.library["HIGHCOM"])
		
		if action == "RETIRE" then
			for _, itag in pairs(tag) do
				if itag == "Han_Solo_Intrepid" then
					Handle_Hero_Add("Abaht", self.library["HIGHCOM"])
					Handle_Hero_Add("Abaht", self.library["SUPCOM"])
					Transfer_Fighter_Hero("HAN_SOLO_INTREPID", "ABAHT_INTREPID")
				end
			end
		end

		Handle_Build_Options(object_type_name, self.library["ADMIRAL"])

		if object_type_name == "EXTRA_ADMIRAL_SLOT" and self.COS_Organa_Solo_Admiral_Power_Mode_On == true then
			self.library["ADMIRAL"].active_player.Lock_Tech(Find_Object_Type("EXTRA_ADMIRAL_SLOT"))
			self.COS_Organa_Solo_Admiral_Power_Mode_On = false
		end

		Handle_Build_Options(object_type_name, self.library["ARMY"])

		if object_type_name == "EXTRA_GENERAL_SLOT" and self.COS_Organa_Solo_General_Power_Mode_On == true then
			self.library["ADMIRAL"].active_player.Lock_Tech(Find_Object_Type("EXTRA_GENERAL_SLOT"))
			self.COS_Organa_Solo_General_Power_Mode_On = false
		end

		Handle_Build_Options(object_type_name, self.library["JEDI"])

		if object_type_name == "HAN_SOLO_INTREPID_ASSIGN" then
			local check_hero = Find_First_Object("HAN_SOLO_INTREPID_ASSIGN")
			local place = check_hero.Get_Planet_Location()
			check_hero.Despawn()
			Handle_Hero_Exit("Abaht", self.library["HIGHCOM"])
			Handle_Hero_Exit("Abaht", self.library["SUPCOM"])
			Transfer_Fighter_Hero("ABAHT_INTREPID", "HAN_SOLO_INTREPID")
			if self.library["HIGHCOM"].active_player.Is_Human() then
				StoryUtil.Multimedia("TEXT_CONQUEST_HAN_INTREPID", 20, nil, "Han_Solo_Loop", 0)
			end
			Handle_Hero_Spawn("Han_Solo_Intrepid", self.library["HIGHCOM"], place)		
		end
	end
end

function RepublicHeroes:switch_views(new_view)
	--Logger:trace("entering RepublicHeroes:switch_views")

	local tech_unit

	if new_view == 1 then
		tech_unit = Find_Object_Type("VIEW_ADMIRALS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		Enable_Hero_Options(self.library["ADMIRAL"])
		Show_Hero_Info(self.library["ADMIRAL"])
	end

	if new_view == 2 then
		tech_unit = Find_Object_Type("VIEW_GENERALS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		Enable_Hero_Options(self.library["ARMY"])
		Show_Hero_Info(self.library["ARMY"])
	end

	if new_view == 3 then
		tech_unit = Find_Object_Type("VIEW_COUNCIL")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		Enable_Hero_Options(self.library["JEDI"])
		Show_Hero_Info(self.library["JEDI"])
	end

	if new_view == 4 then
		tech_unit = Find_Object_Type("VIEW_COS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		self:Enable_CoS_Dummies()
		self.CoS_dummies_enabled = true
	end

	if new_view == 5 then
		tech_unit = Find_Object_Type("VIEW_FIGHTERS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		self:Enable_Fighter_Sets()
		self.fighter_assign_enabled = true
	end

	if new_view == 6 then
		tech_unit = Find_Object_Type("VIEW_HIGHCOMS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		Enable_Hero_Options(self.library["HIGHCOM"])
		Show_Hero_Info(self.library["HIGHCOM"])
	end

	if new_view == 7 then
		tech_unit = Find_Object_Type("VIEW_SUPCOMS")
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
		Enable_Hero_Options(self.library["SUPCOM"])
		Show_Hero_Info(self.library["SUPCOM"])
	end

	if self.old_view == 1 and self.library["ADMIRAL"].vacant_limit > -1 then
		tech_unit = Find_Object_Type("VIEW_ADMIRALS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		Disable_Hero_Options(self.library["ADMIRAL"])
	end

	if self.old_view == 2 and self.library["ARMY"].vacant_limit > -1 then
		tech_unit = Find_Object_Type("VIEW_GENERALS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		Disable_Hero_Options(self.library["ARMY"])
	end

	if self.old_view == 3 and self.library["JEDI"].vacant_limit > -1 then
		tech_unit = Find_Object_Type("VIEW_COUNCIL")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		Disable_Hero_Options(self.library["JEDI"])
	end

	if self.old_view == 4 then
		tech_unit = Find_Object_Type("VIEW_COS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		self:Disable_CoS_Dummies()
		self.CoS_dummies_enabled = false
	end

	if self.old_view == 5 then
		tech_unit = Find_Object_Type("VIEW_FIGHTERS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		self:Disable_Fighter_Sets()
		self.fighter_assign_enabled = false
	end

	if self.old_view == 6 and self.library["HIGHCOM"].vacant_limit > -1 then
		tech_unit = Find_Object_Type("VIEW_HIGHCOMS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		Disable_Hero_Options(self.library["HIGHCOM"])
	end

	if self.old_view == 7 and self.library["SUPCOM"].vacant_limit > -1 then
		tech_unit = Find_Object_Type("VIEW_SUPCOMS")
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
		Disable_Hero_Options(self.library["SUPCOM"])
	end

	self.old_view = new_view
end

function RepublicHeroes:CommandStaff_Initialize(command_staffs)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Initialize")
	self.CommandStaff_Initialized = true

	init_hero_system(self.library["ADMIRAL"])
	init_hero_system(self.library["ARMY"])
	init_hero_system(self.library["JEDI"])
	init_hero_system(self.library["HIGHCOM"])
	init_hero_system(self.library["SUPCOM"])

	local tech_level = GlobalValue.Get("CURRENT_ERA")

	local temp = Find_First_Object("Jedi_Temple")
	if TestValid(temp) then
		self:New_Jedi_Order()
	end

	--Handle special actions for starting tech level
	if tech_level >= 2 then
		Handle_Hero_Add("Iillor", self.library["ADMIRAL"])
		Handle_Hero_Add("Matthews", self.library["ADMIRAL"])
		Handle_Hero_Exit("Kalback", self.library["HIGHCOM"])
		Handle_Hero_Exit("Massa", self.library["HIGHCOM"])
	end

	if tech_level >= 3 then
		Handle_Hero_Add("Iblis", self.library["HIGHCOM"])
		Handle_Hero_Add("Iblis", self.library["SUPCOM"])
		self:Add_Fighter_Set("Alexandra_Winger_Location_Set")
	end

	if tech_level >= 4 then
		Handle_Hero_Exit("Han_Solo_Mon_Remonda", self.library["ADMIRAL"])
		Handle_Hero_Add("Grant", self.library["ADMIRAL"])
	end

	if tech_level >= 5 then
		Handle_Hero_Exit("Ragab", self.library["ADMIRAL"])
		set_unit_index("Lando", 2, self.library["ADMIRAL"])
	end

	if tech_level >= 7 then
		Handle_Hero_Add("Brand", self.library["ADMIRAL"])
		Handle_Hero_Add("Whyrrryk", self.library["ADMIRAL"])
		Handle_Hero_Add("Abaht", self.library["HIGHCOM"])
		Handle_Hero_Add("Abaht", self.library["SUPCOM"])
		Handle_Hero_Add("Krefey", self.library["HIGHCOM"])
		Handle_Hero_Add("Krefey", self.library["SUPCOM"])
		self.library["HIGHCOM"].active_player.Unlock_Tech(Find_Object_Type("HAN_SOLO_INTREPID_ASSIGN"))
		Handle_Hero_Exit("Madine", self.library["ARMY"])
		set_unit_index("Bell", 2, self.library["ADMIRAL"])
		self:Add_CoS("Candidate_Shesh")
		self:New_Jedi_Order()

		self.library["HIGHCOM"].total_slots = self.library["HIGHCOM"].total_slots + 1
		self.library["HIGHCOM"].free_hero_slots = self.library["HIGHCOM"].free_hero_slots + 1
		Unlock_Hero_Options(self.library["HIGHCOM"])
	end
	
	local current_year = GlobalValue.Get("GALACTIC_YEAR")
	if current_year >= 13 then
		Handle_Hero_Exit("Bell", self.library["ADMIRAL"])
	end

	if not self.library["ADMIRAL"].active_player.Is_Human() then --All options for AI
		Enable_Hero_Options(self.library["ADMIRAL"])
		Enable_Hero_Options(self.library["JEDI"])
		Enable_Hero_Options(self.library["ARMY"])
		Enable_Hero_Options(self.library["HIGHCOM"])
		Enable_Hero_Options(self.library["SUPCOM"])
	end

--Historical GC slot adjustments, hero lockins, returns, and exits
	if not command_staffs then
		return
	end

	for staff_name,data in pairs(command_staffs) do
		if data["SLOT_ADJUST"] then
			self:CommandStaff_Slot_Adjust(data["SLOT_ADJUST"], staff_name)
		end

		if data["SLOT_SET"] then
			self:CommandStaff_Slot_Adjust(data["SLOT_SET"], staff_name, true)
		end

		if data["VACANCY"] then
			self:CommandStaff_Add_Vacancy(data["VACANCY"], staff_name)
		end

		if data["LOCKIN"] then

			self:CommandStaff_Lockin(data["LOCKIN"], staff_name)
		end

		if data["RETURN"] then
			self:CommandStaff_Return(data["RETURN"], staff_name)
		end

		if data["EXIT"] then
			self:CommandStaff_Exit(data["EXIT"], staff_name)
		end

		if data["STORY_LOCK"] then
			self:CommandStaff_Exit(data["STORY_LOCK"], staff_name, true)
		end
	end
end

function RepublicHeroes:CommandStaff_Slot_Adjust(amount, set, slot_set)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Slot_Adjust")
	if self.library[set] then
		Adjust_Hero_Amount(amount, self.library[set], slot_set)
	end
end

function RepublicHeroes:CommandStaff_Add_Vacancy(amount, set)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Add_Vacancy")
	if self.library[set] then
		Set_Locked_Slots(self.library[set], amount)
	end
end

function RepublicHeroes:CommandStaff_Lockin(list, set)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Lockin")
	if self.library[set] then
		lock_retires(list, self.library[set])
	end
end

function RepublicHeroes:CommandStaff_Exit(list, set, storylock)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Exit")
	if self.library[set] then
		for _, tag in pairs(list) do
			Handle_Hero_Exit(tag, self.library[set], storylock)
		end
	end
end

function RepublicHeroes:CommandStaff_Return(list, set, skip_existence_check)
	--Logger:trace("entering RepublicHeroes:CommandStaff_Return")
	if self.library[set] then
		for _, tag in pairs(list) do
			if check_hero_exists(tag, self.library[set]) or skip_existence_check then
				Handle_Hero_Add(tag, self.library[set])
			end
		end
	end
end

function RepublicHeroes:CommandStaff_Census()
	--Logger:trace("entering RepublicHeroes:CommandStaff_Census")

	local command_staffs = {}
	for staff_name,data in pairs(self.library) do
		table.insert(command_staffs,staff_name)
	end

	for _,staff_name in pairs(command_staffs) do
		Get_Active_Heroes(true, self.library[staff_name])
	end

	for _,staff_name in pairs(command_staffs) do
		Lock_Hero_Options(self.library[staff_name])
	end

	for _,staff_name in pairs(command_staffs) do
		Unlock_Hero_Options(self.library[staff_name])
	end
end

function RepublicHeroes:on_galactic_hero_killed(hero_name, owner)
	--Logger:trace("entering RepublicHeroes:on_galactic_hero_killed")
	if hero_name == "THRAWN_CHIMAERA" then
		if Handle_Hero_Exit("Kalback", self.library["HIGHCOM"]) then
			if self.library["ADMIRAL"].active_player.Is_Human() then
				StoryUtil.Multimedia("TEXT_CONQUEST_KALBACK_RETIRE", 20, nil, "Kalback_Loop", 0)
			end
		end
	end

	local tag = Handle_Hero_Killed(hero_name, owner, self.library["ADMIRAL"])
	if self.library["SUPCOM"].full_list[tag] then
		Handle_Hero_Exit(tag, self.library["SUPCOM"])
	end

	if self.COS_Organa_Solo_Active == true and tag ~= nil then
		if self.library["ADMIRAL"].vacant_limit < 0 then
			self.library["ADMIRAL"].vacant_limit = 0
			if self.library["ADMIRAL"].total_slots == self.library["ADMIRAL"].vacant_hero_slots then
				self.library["ADMIRAL"].active_player.Unlock_Tech(Find_Object_Type(self.library["ADMIRAL"].extra_name))
				self.COS_Organa_Solo_Admiral_Power_Mode_On = true
			end
		end
	end

	if tag == "Han_Solo_Intrepid" or tag == "Han_Solo_Mon_Remonda" then
		local planet = StoryUtil.FindFriendlyPlanet(self.library["ADMIRAL"].active_player)
		SpawnList({"Han_Solo_Team"}, planet, self.library["ADMIRAL"].active_player, true, false)
		if self.library["ADMIRAL"].active_player.Is_Human() then
			StoryUtil.Multimedia("TEXT_CONQUEST_HAN_RESPAWN", 20, nil, "Han_Solo_Loop", 0)
		end
	elseif tag == "Lando" then
		Handle_Hero_Add("Calrissian", self.library["ARMY"])
		local assign_unit = Find_Object_Type("CALRISSIAN_G2A")
		self.library["ADMIRAL"].active_player.Lock_Tech(assign_unit)
		if self.library["ADMIRAL"].active_player.Is_Human() then
			StoryUtil.Multimedia("TEXT_CONQUEST_LANDO_RESPAWN", 20, nil, "Lando_Loop", 0)
		end
	end

	tag = Handle_Hero_Killed(hero_name, owner, self.library["ARMY"])

	if self.COS_Organa_Solo_Active == true and tag ~= nil then
		if self.library["ARMY"].vacant_limit < 0 then
			self.library["ARMY"].vacant_limit = 0
			if self.library["ARMY"].total_slots == self.library["ARMY"].vacant_hero_slots then
				self.library["ARMY"].active_player.Unlock_Tech(Find_Object_Type(self.library["ARMY"].extra_name))
				self.COS_Organa_Solo_General_Power_Mode_On = true
			end
		end
	end

	Handle_Hero_Killed(hero_name, owner, self.library["JEDI"])

	tag = Handle_Hero_Killed(hero_name, owner, self.library["HIGHCOM"])
	if self.library["SUPCOM"].full_list[tag] then
		Handle_Hero_Exit(tag, self.library["SUPCOM"])
	end

	Handle_Hero_Killed(hero_name, owner, self.library["SUPCOM"])
end

function RepublicHeroes:Enable_Fighter_Sets()
	--Logger:trace("entering RepublicHeroes:Enable_Fighter_Sets")
	for _, setter in pairs(self.fighter_assigns) do
		tech_unit = Find_Object_Type(setter)
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
	end
end

function RepublicHeroes:Disable_Fighter_Sets()
	--Logger:trace("entering RepublicHeroes:Disable_Fighter_Sets")
	for _, setter in pairs(self.fighter_assigns) do
		tech_unit = Find_Object_Type(setter)
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
	end
end

function RepublicHeroes:Add_Fighter_Set(set, nounlock)
--Logger:trace("entering RepublicHeroes:Add_Fighter_Sets")
	--Wrapper for avoiding duplicates in list
	for i, setter in pairs(self.fighter_assigns) do
		if setter == set then
			return
		end
	end
	table.insert(self.fighter_assigns,set)
	if self.fighter_assign_enabled and nounlock == nil then
		self:Enable_Fighter_Sets()
	end
end

function RepublicHeroes:Remove_Fighter_Set(set, nolock)
--Logger:trace("entering RepublicHeroes:Disable_Fighter_Set")
	for i, setter in pairs(self.fighter_assigns) do
		if setter == set then
			table.remove(self.fighter_assigns,i)
			local assign_unit = Find_Object_Type(setter)
			self.library["ADMIRAL"].active_player.Lock_Tech(assign_unit)
		end
	end
	if self.fighter_assign_enabled and nolock == nil then
		self:Enable_Fighter_Sets()
	end
end


--TR mutations of mostly shared functions

function RepublicHeroes:Era_Transitions(new_era_number)
	--Logger:trace("entering RepublicHeroes:Era_Transitions")
	if new_era_number == 2 then
		Handle_Hero_Add("Iillor", self.library["ADMIRAL"])
	elseif new_era_number == 3 then
		Handle_Hero_Add("Iblis", self.library["HIGHCOM"])
		Handle_Hero_Add("Iblis", self.library["SUPCOM"])
		self:Add_Fighter_Set("Alexandra_Winger_Location_Set")
	elseif new_era_number == 4 then
		Handle_Hero_Exit("Kalback", self.library["HIGHCOM"])
	elseif new_era_number == 7 then
		Handle_Hero_Add("Han_Solo_Intrepid", self.library["HIGHCOM"])
		Handle_Hero_Add("Krefey", self.library["HIGHCOM"])
		Handle_Hero_Add("Krefey", self.library["SUPCOM"])
		self:Add_CoS("Candidate_Shesh")
	end
end

function RepublicHeroes:Add_Filter_Options(sets, filter)
--Logger:trace("entering RepublicHeroes:Add_Filter_Options")
	if filter == 1 then
		for _, set in pairs(sets) do
			self:Add_CoS(set, true)
		end
		if self.CoS_dummies_enabled then
			self:Enable_CoS_Dummies()
		end
	end
	if filter == 2 then
		for _, set in pairs(sets) do
			self:Add_Fighter_Set(set, true)
		end
		if self.fighter_assign_enabled then
			self:Enable_Fighter_Sets()
		end
	end
end

function RepublicHeroes:Remove_Filter_Options(sets, filter)
--Logger:trace("entering RepublicHeroes:Remove_Filter_Options")
	if filter == 1 then
		for _, set in pairs(sets) do
			self:Remove_CoS(set, true)
		end
		if self.CoS_dummies_enabled then
			self:Enable_CoS_Dummies()
		end
	end
	if filter == 2 then
		for _, set in pairs(sets) do
			self:Remove_Fighter_Set(set, true)
		end
		if self.fighter_assign_enabled then
			self:Enable_Fighter_Sets()
		end
	end
end


--TR specific Functions

function RepublicHeroes:Enable_CoS_Dummies()
	--Logger:trace("entering RepublicHeroes:Enable_CoS_Dummies")
	for _, setter in pairs(self.CoS_dummies) do
		tech_unit = Find_Object_Type(setter)
		self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
	end
end

function RepublicHeroes:Disable_CoS_Dummies()
	--Logger:trace("entering RepublicHeroes:Disable_Fighter_Sets")
	for _, setter in pairs(self.CoS_dummies) do
		tech_unit = Find_Object_Type(setter)
		self.library["ADMIRAL"].active_player.Lock_Tech(tech_unit)
	end
end

function RepublicHeroes:Add_CoS(set, nounlock)
--Logger:trace("entering RepublicHeroes:Add_CoS")
	--Wrapper for avoiding duplicates in list
	for i, setter in pairs(self.CoS_dummies) do
		if setter == set then
			return
		end
	end
	table.insert(self.CoS_dummies,set)
	if self.CoS_dummies_enabled and nounlock == nil then
		self:Enable_CoS_Dummies()
	end
end

function RepublicHeroes:Remove_CoS(set, nolock)
--Logger:trace("entering RepublicHeroes:Remove_CoS")
	for i, setter in pairs(self.CoS_dummies) do
		if setter == set then
			table.remove(self.CoS_dummies,i)
			local assign_unit = Find_Object_Type(setter)
			self.library["ADMIRAL"].active_player.Lock_Tech(assign_unit)
		end
	end
	if self.CoS_dummies_enabled and nolock == nil then
		self:Enable_CoS_Dummies()
	end
end

function RepublicHeroes:Chief_Of_State_Transition()
	local CoS = GlobalValue.Get("ChiefOfState")

	--transition from other to Leia
	if CoS == "DUMMY_CHIEFOFSTATE_ORGANA_SOLO" and self.COS_Organa_Solo_Active == false then
		self.COS_Organa_Solo_Active = true

		--ADMIRALS

		--if all normal rebuys are gone
		if self.library["ADMIRAL"].vacant_limit < 0 then
			self.library["ADMIRAL"].vacant_limit = 0
			if self.library["ADMIRAL"].total_slots == self.library["ADMIRAL"].vacant_hero_slots then
				self.library["ADMIRAL"].active_player.Unlock_Tech(Find_Object_Type(self.library["ADMIRAL"].extra_name))
				self.COS_Organa_Solo_Admiral_Power_Mode_On = true
			end
			self:switch_views(1)
		else
		--if there is still at least one rebuy left
			self.library["ADMIRAL"].total_slots = self.library["ADMIRAL"].total_slots + 1
			self.library["ADMIRAL"].free_hero_slots = self.library["ADMIRAL"].free_hero_slots + 1
		end
		Get_Active_Heroes(false, self.library["ADMIRAL"])

		--GENERALS

		--if all normal rebuys are gone
		if self.library["ARMY"].vacant_limit < 0 then
			self.library["ARMY"].vacant_limit = 0
			if self.library["ARMY"].total_slots == self.library["ARMY"].vacant_hero_slots then
				self.library["ARMY"].active_player.Unlock_Tech(Find_Object_Type(self.library["ARMY"].extra_name))
				self.COS_Organa_Solo_General_Power_Mode_On = true
			end
			self:switch_views(2)
		else
		--if there is still at least one rebuy left
			self.library["ARMY"].total_slots = self.library["ARMY"].total_slots + 1
			self.library["ARMY"].free_hero_slots = self.library["ARMY"].free_hero_slots + 1
		end
		Get_Active_Heroes(false, self.library["ARMY"])

	--transition from Leia to other
	elseif CoS ~= "DUMMY_CHIEFOFSTATE_ORGANA_SOLO" and self.COS_Organa_Solo_Active == true then
		self.COS_Organa_Solo_Active = false
		self.COS_Organa_Solo_Admiral_Power_Mode_On = false
		self.COS_Organa_Solo_General_Power_Mode_On = false

		--ADMIRALS

		--if there are free slots, reduce them by 1
		if self.library["ADMIRAL"].free_hero_slots > 0 then
			self.library["ADMIRAL"].free_hero_slots = self.library["ADMIRAL"].free_hero_slots - 1
		elseif self.library["ADMIRAL"].total_slots > self.library["ADMIRAL"].vacant_hero_slots then
		--if there are occupied slots, fire somebody
			Get_Active_Heroes(false, self.library["ADMIRAL"])
			local admirals = GlobalValue.Get("NR_ADMIRAL_LIST")
			local interim_list = admirals
			for i, admiral_display_name in pairs (interim_list) do
				if string.find(admiral_display_name," %[Locked%]") ~= nil then
					table.remove(admirals,i)
				end
			end

			local admiral_to_fire_index = GameRandom.Free_Random(1,table.getn(admirals))
			local admiral_to_fire_display_name = admirals[admiral_to_fire_index]
			local admiral_to_fire_tag = nil
			for tag,entry in pairs(self.library["ADMIRAL"].full_list) do
				if entry[3] == admiral_to_fire_display_name then
					admiral_to_fire_tag = tag
				end
			end
			Handle_Hero_Despawn(self.library["ADMIRAL"], admiral_to_fire_tag)
			self.library["ADMIRAL"].free_hero_slots = self.library["ADMIRAL"].free_hero_slots - 1
		else
			self.library["ADMIRAL"].vacant_hero_slots = self.library["ADMIRAL"].vacant_hero_slots - 1
		end
		self.library["ADMIRAL"].total_slots = self.library["ADMIRAL"].total_slots - 1
		Get_Active_Heroes(false, self.library["ADMIRAL"])

		--GENERALS

		--if there are free slots, reduce them by 1
		if self.library["ARMY"].free_hero_slots > 0 then
			self.library["ARMY"].free_hero_slots = self.library["ARMY"].free_hero_slots - 1
		elseif self.library["ARMY"].total_slots > self.library["ARMY"].vacant_hero_slots then
		--if there are occupied slots, fire somebody
			Get_Active_Heroes(false, self.library["ARMY"])
			local generals = GlobalValue.Get("NR_GENERAL_LIST")
			local interim_list = generals
			for i, general_display_name in pairs (interim_list) do
				if string.find(general_display_name," %[Locked%]") ~= nil then
					table.remove(generals,i)
				end
			end

			local general_to_fire_index = GameRandom.Free_Random(1,table.getn(generals))
			local general_to_fire_display_name = generals[general_to_fire_index]
			local general_to_fire_tag = nil
			for tag,entry in pairs(self.library["ARMY"].full_list) do
				if entry[3] == general_to_fire_display_name then
					general_to_fire_tag = tag
				end
			end
			Handle_Hero_Despawn(self.library["ARMY"], general_to_fire_tag)
			self.library["ARMY"].free_hero_slots = self.library["ARMY"].free_hero_slots - 1
		else
			self.library["ARMY"].vacant_hero_slots = self.library["ARMY"].vacant_hero_slots - 1
		end
		self.library["ARMY"].total_slots = self.library["ARMY"].total_slots - 1
		Get_Active_Heroes(false, self.library["ARMY"])
	end
end

function RepublicHeroes:New_Jedi_Order_Init()
	--Logger:trace("entering RepublicHeroes:New_Jedi_Order_Init")
	if self.library["ADMIRAL"].active_player.Is_Human() and not self.NJOspeech then
		StoryUtil.Multimedia("TEXT_CONQUEST_LUKE_NJO", 20, nil, "Luke_Loop", 0)
	end
	self.NJOspeech = true
	local tech_unit = Find_Object_Type("JEDI_TEMPLE")
	self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
	tech_unit = Find_Object_Type("NEW_REPUBLIC_JEDI_KNIGHT_COMPANY")
	self.library["ADMIRAL"].active_player.Unlock_Tech(tech_unit)
end

function RepublicHeroes:New_Jedi_Order()
	--Logger:trace("entering RepublicHeroes:New_Jedi_Order")
	if not self.NJOinit then
		self.library["JEDI"].total_slots = self.library["JEDI"].total_slots + 1
		self.library["JEDI"].free_hero_slots = self.library["JEDI"].free_hero_slots + 1
		Handle_Hero_Add("Corran", self.library["JEDI"])
		Handle_Hero_Add("Mara", self.library["JEDI"])
		Handle_Hero_Add("Cilghal", self.library["JEDI"])
		Get_Active_Heroes(false, self.library["JEDI"])
	end
	self.NJOinit = true
end

function RepublicHeroes:NCMP2_handler()
	--Logger:trace("entering RepublicHeroes:NCMP2_handler")
	self.library["HIGHCOM"].total_slots = self.library["HIGHCOM"].total_slots + 1
	self.library["HIGHCOM"].free_hero_slots = self.library["HIGHCOM"].free_hero_slots + 1

	Handle_Hero_Add("Brand", self.library["ADMIRAL"])
	Handle_Hero_Add("Whyrrryk", self.library["ADMIRAL"])
	Handle_Hero_Add("Abaht", self.library["HIGHCOM"])
	Handle_Hero_Add("Abaht", self.library["SUPCOM"])
	self.library["HIGHCOM"].active_player.Unlock_Tech(Find_Object_Type("HAN_SOLO_INTREPID_ASSIGN"))

	local Han_Solo_Mon_Remonda_object = Find_First_Object("Han_Solo_Mon_Remonda")
	if TestValid(Han_Solo_Mon_Remonda_object) then
		local planet = Han_Solo_Mon_Remonda_object.Get_Planet_Location()
		if not TestValid(planet) then
			planet = StoryUtil.FindFriendlyPlanet(self.library["ADMIRAL"].active_player, true)
		elseif not StoryUtil.CheckFriendlyPlanet(planet, self.library["ADMIRAL"].active_player) then
			planet = StoryUtil.FindFriendlyPlanet(self.library["ADMIRAL"].active_player, true)
		end
		if Handle_Hero_Exit("Han_Solo_Mon_Remonda", self.library["ADMIRAL"]) then
			SpawnList({"Han_Solo_Team"}, planet, self.library["ADMIRAL"].active_player, true, false)
			if self.library["ADMIRAL"].active_player.Is_Human() then
				StoryUtil.Multimedia("TEXT_CONQUEST_HAN_RETIRE", 20, nil, "Han_Solo_Loop", 0)
			end
		end
	else
		Handle_Hero_Exit("Han_Solo_Mon_Remonda", self.library["ADMIRAL"])
	end
	Get_Active_Heroes(false, self.library["ADMIRAL"])
end

function RepublicHeroes:Mediator_Heroes()
	--Logger:trace("entering RepublicHeroes:Mediator_Heroes")
	Handle_Hero_Add("Ackdool", self.library["ADMIRAL"])
end

function RepublicHeroes:Canon_Heroes()
	--Logger:trace("entering RepublicHeroes:Canon_Heroes")
	Handle_Hero_Add("Raddus", self.library["ADMIRAL"])
	if check_hero_exists("Hera", self.library["ADMIRAL"]) then --ensure she wasn't removed fromn the story locked list
		Handle_Hero_Add("Hera", self.library["ADMIRAL"])
	end
end
