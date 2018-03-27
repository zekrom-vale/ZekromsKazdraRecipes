Run after "vanilla assets" load:
for all files {extention:"JSON"} under "/dungeon/*/" do
	for all existing paths that follow "/layers/*/objects/*/properties/npc" do
		replace JSON-object with JSON-object.split(",");
	end
end

Run patch files on paths "/layers/*/objects/*/properties/npc"

Run before "end of" compiling:
for all files {extention:"JSON"} under "/dungeon/*/" do
	for all existing paths that follow "/layers/*/objects/*/properties/npc" do
		replace JSON-object with JSON-object.join(",");
	end
end