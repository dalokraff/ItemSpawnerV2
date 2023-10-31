local mod = get_mod("itemspawnerV2") -- luacheck: ignore get_mod

-- luacheck: globals AllPickups Spawn Unit NetworkLookup Managers Keyboard Localize

local pl = require'pl.import_into'()
local stringx = require'pl.stringx'

mod.pickup_names = pl.Map{}

mod.persistent_storage = mod:persistent_table("persistent_storage")
mod.current_pickup_name = mod.persistent_storage.pickup_name

mod.spawn_item = function(pickup_name)
	mod:pcall(function()
		if not Managers.player.is_server
		and (pickup_name == "training_dummy"
		or pickup_name == "training_dummy_armored"
		or pickup_name == "training_dummy_skaven")
		then
			mod:echo("Need to be host to spawn training dummies!")
			return
		end

		local spawn_method = "rpc_spawn_pickup_with_physics"
		if pickup_name == "all_ammo" then
			spawn_method = "rpc_spawn_pickup"
		end

		local local_player_unit = Managers.player:local_player().player_unit
		Managers.state.network.network_transmit:send_rpc_server(
			spawn_method,
			NetworkLookup.pickup_names[pickup_name],
			Unit.local_position(local_player_unit, 0),
			Unit.local_rotation(local_player_unit, 0),
			NetworkLookup.pickup_spawn_types['dropped']
		)
	end)
end

mod.init_pickups = function()
	mod:pcall(function()
		if AllPickups and mod.pickup_names:len() == 0 then
			-- get a list of pickup names without those that crash
			mod.pickup_names = pl.Map(AllPickups)
				:keys()
				:remove_value("loot_die")
				:remove_value("lorebook_pages")
				:remove_value("beer_barrel")
				:filter(function(pickup_name)
					return stringx.count(AllPickups[pickup_name].unit_template_name or "", "_limited") == 0
					and stringx.count(pickup_name, "endurance_badge") == 0
				end)

			if not mod.current_pickup_name then
				mod.current_pickup_name = mod.pickup_names[1]
			end
		end
	end)
end

mod.next_pickup = function()
	if not mod:is_enabled() then
		return
	end

	mod.init_pickups()

	mod.current_pickup_name = mod.pickup_names[mod.pickup_names:index(mod.current_pickup_name) + 1]
	if not mod.current_pickup_name then
		mod.current_pickup_name = mod.pickup_names[1]
	end

	mod:echo("Switched to: "..mod.current_pickup_name)
end

mod.prev_pickup = function()
	if not mod:is_enabled() then
		return
	end

	mod.init_pickups()

	mod.current_pickup_name = mod.pickup_names[mod.pickup_names:index(mod.current_pickup_name) - 1]
	if not mod.current_pickup_name then
		mod.current_pickup_name = mod.pickup_names[#mod.pickup_names]
	end

	mod:echo("Switched to: "..mod.current_pickup_name)
end

mod.spawn_pickup = function()
	if not mod:is_enabled() then
		return
	end

	mod.init_pickups()

	mod.spawn_item(mod.current_pickup_name)

	mod:echo("Spawned: "..mod.current_pickup_name)
end

mod.switch_item = function(user_input)
	mod:pcall(function()
		mod.init_pickups()

		local filtered_by_user_input =
			mod.pickup_names:filter(function(pickup_name)
				return stringx.count(pickup_name, user_input) > 0
					or stringx.count(Localize(AllPickups[pickup_name].item_name or ""), user_input) > 0
			end)

		if filtered_by_user_input[1] then
			mod.current_pickup_name = filtered_by_user_input[1]
			mod:echo("Switched to: "..mod.current_pickup_name)
		else
			mod:echo("Cannot find item that matches: "..user_input)
		end
	end)
end

mod.on_unload = function()
	mod.persistent_storage.pickup_name = mod.current_pickup_name
end

mod:command("item", mod:localize("switch_item_command_description"), mod.switch_item)
