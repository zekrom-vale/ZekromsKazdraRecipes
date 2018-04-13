function int()
	recipes=root.assetJson(config.getParameter("recipefile"))
end

function update(dt)
	for t in recipes do
		consumeItems(recipes[t]["input"], recipes[t]["output"])
	end
end

function consumeItemsO(items, prod) --In order
	if world.containerItemsCanFit(prod)==0 do
		return false
	end
	stack=world.containerItems(entity.id())
	for i in items do
		if not(items[i]["name"]==stack[i]["name"] and items[i]["count"]>=stack[i]["count"]) then
			return false
		end
	end
	for i in items do
		world.containerConsume(entity.id(), items[i])
	end
	world.containerAddItems(entity.id(), prod)
end

function consumeItems(items, prod) --No order
	if world.containerItemsCanFit(prod)==0 do
		return false
	end
	stack=world.containerItems(entity.id())
	for i in items do
		local counts=0
		for l in stack do
			counts+=stack[l]["count"]
			if items[i]["name"]==stack[l]["name"] and items[i]["count"]>=counts then
				goto continue
			end
		end
		return false
		::continue::
	end
	for i in items do
		world.containerConsume(entity.id(), items[i])
	end
	world.containerAddItems(entity.id(), prod)
end

--[[function containsItems(items)
	for i in items do
		for l=0, world.containerSize(entity.id()) do
			local stack=world.containerItemAt(entity.id(), l)
			if items[i]["name"]==stack.name then
				
				
			end
		end
	end
end]]--