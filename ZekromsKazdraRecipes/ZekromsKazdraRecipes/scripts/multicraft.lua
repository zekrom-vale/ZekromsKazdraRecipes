function int()
	overflow={}
	recipes=root.assetJson(config.getParameter("recipefile"))
	for key,value in pairs(recipes) do
		if value["input"]== nil or value["output"]== nil then
			table.remove(recipes, key)
			key=key-1
		end
	end
end

function update(dt)
	if not(overflow==nil or overflow=={}) then
		overflow=world.containerAddItems(entity.id(), overflow)
	end
	if overflow==nil or overflow=={} then
		for key,value in pairs(recipes) do
			overflow=consumeItems(value["input"], value["output"])
			if overflow~=false then
				break
			end
		end
	end
end

function consumeItemsO(items, prod) --In order
	stack=world.containerItems(entity.id())
	for key.value in pairs(items) do
		if not(value["name"]==stack[key]["name"] and value["count"]>=stack[key]["count"]) then
			return false
		end
	end
	for key,value in pairs(items) do
		world.containerConsume(entity.id(), value)
	end
	for key,value in pairs(prod) do
		if value["pool"]~=nil then
			local pool=root.createTreasure(value["pool"], value["level"] or 0)
			table.remove(prod, key)
			key=key-1
			for key2,value2 in pairs(pool) do
				table.insert(prod, value2)
			end
		end
	end
	return world.containerAddItems(entity.id(), prod)
end

function consumeItems(items, prod) --No order
	stack=world.containerItems(entity.id())
	for key,value in pairs(items) do
		local counts=0
		for key2,value2 in pairs(stack) do
			counts=counts+value2["count"]
			if value["name"]==value2["name"] and value2["count"]>=counts then
				goto continue
			end
		end
		return false
		::continue::
	end
	for key,value in pairs(items) do
		world.containerConsume(entity.id(), value)
	end
	for key,value in pairs(prod) do
		if value["pool"]~=nil then
			local pool=root.createTreasure(value["pool"], value["level"] or 0)
			table.remove(prod, key)
			key=key-1
			for key2,value2 in pairs(pool) do
				table.insert(prod, value2)
			end
		end
	end
	return world.containerAddItems(entity.id(), prod)
end