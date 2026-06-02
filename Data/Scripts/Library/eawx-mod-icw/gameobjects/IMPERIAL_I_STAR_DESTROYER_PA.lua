return {
	Ship_Crew_Requirement = 480,
	Fighters = {
		["LIGHT_FIGHTER"] = {
			DEFAULT = {Initial = 1, Reserve = 2}
		},
		["INTERCEPTOR"] = {
			DEFAULT = {Initial = 1, Reserve = 2}
		},
		["BLASTBOAT_HALF"] = {
			DEFAULT = {Initial = 1, Reserve = 1}
		},
		["BOMBER_HALF"] = {
			DEFAULT = {Initial = 1, Reserve = 1}
		}
	},
	Native = "IMPERIAL",
	FighterFlags = {"ISD"},
	Scripts = {"multilayer", "fighter-spawn"}
}