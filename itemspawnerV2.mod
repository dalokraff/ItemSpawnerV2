return {
	run = function()
		fassert(rawget(_G, "new_mod"), "`itemspawnerV2` mod must be lower than Vermintide Mod Framework in your launcher's load order.")

		new_mod("itemspawnerV2", {
			mod_script       = "scripts/mods/itemspawnerV2/itemspawnerV2",
			mod_data         = "scripts/mods/itemspawnerV2/itemspawnerV2_data",
			mod_localization = "scripts/mods/itemspawnerV2/itemspawnerV2_localization",
		})
	end,
	packages = {
		"resource_packages/itemspawnerV2/itemspawnerV2",
	},
}
