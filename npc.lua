local npc = {}
npc.data = {}
npc.greetings = {
"Howdy!", "What's up?", "Yo", "Yaw"
}

npc.player_introduce = {
"Hi RP_A, I'm RP_B.", "What can I do you for RP_A?", "Yaw RP_A"
}

npc.unknown = {
"It is with great intelligence, we know of RP_A.", "I don't come across RP_A.", "RP_A? Not around here."
}

npc.player_rename = {
"What do you want to be called?", "My bad, you are?"
}

npc.random = {
"What?", "What do you mean?", "I don't understand."
}

INTENT_UNKNOWN = 0
INTENT_NOT = 100
INTENT_YOU = 99
INTENT_NAME = 98
INTENT_STOP_WORDS = 1

npc.intent_name = {
"call", "called", "calls", "im", "alias", "name", "names", "known"
}
npc.intent_name.index = INTENT_NAME

npc.intent_negate = {
"not", "no"
}
npc.intent_name.index = INTENT_NAME

npc.intent_you = {
'you', 'your', 'yours'
}
npc.intent_you.index = INTENT_YOU

npc.stop_words = {
"i",
"me",
"my",
"myself",
"we",
"our",
"ours",
"ourselves",
"you",
"your",
"yours",
"yourself",
"yourselves",
"he",
"him",
"his",
"himself",
"she",
"her",
"hers",
"herself",
"it",
"its",
"itself",
"they",
"them",
"their",
"theirs",
"themselves",
"what",
"which",
"who",
"whom",
"this",
"that",
"these",
"those",
"am",
"is",
"are",
"was",
"were",
"be",
"been",
"being",
"have",
"has",
"had",
"having",
"do",
"does",
"did",
"doing",
"a",
"an",
"the",
"and",
"but",
"if",
"or",
"because",
"as",
"until",
"while",
"of",
"at",
"by",
"for",
"with",
"about",
"against",
"between",
"into",
"through",
"during",
"before",
"after",
"above",
"below",
"to",
"from",
"up",
"down",
"in",
"out",
"on",
"off",
"over",
"under",
"again",
"further",
"then",
"once",
"here",
"there",
"when",
"where",
"why",
"how",
"all",
"any",
"both",
"each",
"few",
"more",
"most",
"other",
"some",
"such",
"no",
"nor",
"not",
"only",
"own",
"same",
"so",
"than",
"too",
"very",
"s",
"t",
"can",
"will",
"just",
"don",
"should",
"now"
}
npc.stop_words.index = INTENT_STOP_WORDS

npc.intentions = {npc.intent_name, npc.intent_negate, npc.stop_words}

function npc.new(name)
	local index = #npc.data + 1
	local tbl = {}
	tbl.name = name
	tbl.player_name = ""
	tbl.garbage = ""
	npc.data[index] = tbl
	
	return index
end

function npc.tokenizer(str)
	str = str:lower()
	local tokens = {}
	local new_token = ""
	
	local i = 1
	while i <= str:len() do
	
		local chr = str:sub(i, i)
		if (string.byte(chr) >= 97 and string.byte(chr) <= 122) or chr == " " then
			if (i + 1 > str:len()) then
				new_token = new_token .. chr
				table.insert(tokens, new_token)
			elseif (chr == " " and new_token ~= "") then
				table.insert(tokens, new_token)
				new_token = ""
			else
				new_token = new_token .. chr
			end
		end
		
		i = i + 1
	end
	
	npc.processTokens(tokens)
end

function npc.renamer(str)
	local new_token = ""
	local capitalize = true
	
	local i = 1
	while i <= str:len() do
	
		local chr = str:sub(i, i)
		
		if capitalize then
			chr = chr:upper()
			capitalize = false
		end
		
		if (chr == " " and new_token ~= "") then
			new_token = new_token .. " "
			capitalize = true
		else
			new_token = new_token .. chr
		end
		
		i = i + 1
	end
	
	return new_token
end

function npc.stringUnknowns(str, index, intentions, unknowns, deb)
	local unknown_counter = #unknowns - 1
	local j = index - 1
	while j >= 1 do
		if intentions[j] ~= nil and intentions[j] == INTENT_UNKNOWN and unknowns[unknown_counter] ~= nil then
			str = unknowns[unknown_counter] .. " " .. str
			unknown_counter = unknown_counter - 1
		else
			j = 0
		end
		j = j - 1
	end
	
	return str
end

function npc.processTokens(tokens)

	local intentions = {}
	local i = 1
	while i <= #tokens do
		
		intentions[i] = INTENT_UNKNOWN
	
		local j = 1
		while j <= #npc.intentions do
			
			local k = 1
			while k <= #npc.intentions[j] do
				
				if tokens[i] == npc.intentions[j][k] then
					
					if intentions[i] == INTENT_UNKNOWN or npc.intentions[j].index > intentions[i] then
						intentions[i] = npc.intentions[j].index
					end
					
					k = #npc.intentions[j] + 1
				end
				
				k = k + 1
				
			end
			
			j = j + 1
		end
		
		i = i + 1
	end
	
	local looking_for_name = false
	local negate = false
	local unknowns = {}
	local last_unknown = 0
		
	local i = 1
	while i <= #intentions do
		
		if intentions[i] == INTENT_UNKNOWN then
			last_unknown = i
			table.insert(unknowns, tokens[i])
		elseif intentions[i] == INTENT_NAME then
			looking_for_name = true
		elseif intentions[i] == INTENT_NOT then
			negate = true
		end
		
		i = i + 1
	end
	
	if looking_for_name or FLAG_NAME then
		if negate then
			talk_state = TALK_RENAME
			FLAG_NAME = true
		else
			if unknowns[1] ~= nil then
				talk_state = TALK_NAME
				npc.data[current_speaker].player_name = unknowns[#unknowns]
				npc.data[current_speaker].player_name = npc.stringUnknowns(npc.data[current_speaker].player_name, last_unknown, intentions, unknowns, tokens)
				npc.data[current_speaker].player_name = npc.renamer(npc.data[current_speaker].player_name)
				
				FLAG_NAME = false
			else
				talk_state = TALK_RANDOM
			end
		end
		
	elseif unknowns[1] ~= nil then
		talk_state = TALK_UNKNOWN
		npc.data[current_speaker].garbage = unknowns[#unknowns]
		npc.data[current_speaker].garbage = npc.stringUnknowns(npc.data[current_speaker].garbage, last_unknown, intentions, unknowns, tokens)
	else
		talk_state = TALK_RANDOM
	end

end

return npc