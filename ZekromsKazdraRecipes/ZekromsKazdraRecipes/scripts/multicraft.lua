function int()
	overflow={}
	recipes=root.assetJson(config.getParameter("recipefile"))
	for i in recipes do
		if recipes[i]["input"]== nil or recipes[i]["output"]== nil then
			table.remove(recipes, i)
			i-=1
		end
	end
end

function update(dt)
	if not(overflow==nil or overflow=={}) then
		overflow=world.containerAddItems(entity.id(), overflow)
	end
	if overflow==nil or overflow=={} then
		for t in recipes do
			overflow=consumeItems(recipes[t]["input"], recipes[t]["output"])
			if overflow~=false then
				break
			end
		end
	end
end

function consumeItemsO(items, prod) --In order
	stack=world.containerItems(entity.id())
	for i in items do
		if not(items[i]["name"]==stack[i]["name"] and items[i]["count"]>=stack[i]["count"]) then
			return false
		end
	end
	for i in items do
		world.containerConsume(entity.id(), items[i])
	end
	for i in prod do
		if prod[i]["pool"]~=nil then
			local pool=root.createTreasure(prod[i]["pool"], prod[i]["level"] or 0)
			table.remove(prod, i)
			i-=1
			for l in pool do
				prod+=pool[l]
			end
		end
	end
	return world.containerAddItems(entity.id(), prod)
end

function consumeItems(items, prod) --No order
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
	return world.containerAddItems(entity.id(), prod)
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