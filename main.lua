function print_r ( t )
	local print_r_cache={}
	local function sub_print_r(t,indent)
		if (print_r_cache[tostring(t)]) then
			print(indent.."*"..tostring(t))
		else
			print_r_cache[tostring(t)]=true
			if (type(t)=="table") then
				for pos,val in pairs(t) do
					if (type(val)=="table") then
						print(indent.."["..pos.."] => "..tostring(t).." {")
						sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
						print(indent..string.rep(" ",string.len(pos)+6).."}")
					elseif (type(val)=="string") then
						print(indent.."["..pos..'] => "'..val..'"')
					else
						print(indent.."["..pos.."] => "..tostring(val))
					end
				end
			else
				print(indent..tostring(t))
			end
		end
	end
	if (type(t)=="table") then
		print(tostring(t).." {")
		sub_print_r(t,"  ")
		print("}")
	else
		sub_print_r(t,"  ")
	end
	print()
end

math.randomseed(os.clock())

TALK_START = 0
TALK_INPUT = 1
TALK_NAME = 2
TALK_RENAME = 3
TALK_UNKNOWN = 4
TALK_RANDOM = 5
talk_state = TALK_START

FLAG_NAME = false

local npc = require("npc")

jared_speaker = npc.new("Jared")

current_speaker = jared_speaker

function talk(other)

	if talk_state == TALK_START then
	
		print(npc.greetings[math.random(#npc.greetings)])
		talk_state = TALK_INPUT
		talk(other)
		
	elseif talk_state == TALK_INPUT then
		local input = io.read()
		
		if input ~= "q" then
			npc.tokenizer(input)
			talk(other)
		end
		
	elseif talk_state == TALK_NAME then
		
		local new_str = npc.player_introduce[math.random(#npc.player_introduce)]
		new_str = string.gsub(new_str, "RP_A", npc.data[current_speaker].player_name)
		new_str = string.gsub(new_str, "RP_B", npc.data[current_speaker].name)
		print(new_str)
		
		talk_state = TALK_INPUT
		talk(other)
	elseif talk_state == TALK_RENAME then
		
		local new_str = npc.player_rename[math.random(#npc.player_rename)]
		print(new_str)
		
		talk_state = TALK_INPUT
		talk(other)
	elseif talk_state == TALK_UNKNOWN then
		
		local new_str = npc.unknown[math.random(#npc.unknown)]
		new_str = string.gsub(new_str, "RP_A", npc.data[current_speaker].garbage)
		print(new_str)
		
		talk_state = TALK_INPUT
		talk(other)
	elseif talk_state == TALK_RANDOM then
		
		local new_str = npc.random[math.random(#npc.random)]
		print(new_str)
		
		talk_state = TALK_INPUT
		talk(other)
	end

end

talk(jared_speaker)