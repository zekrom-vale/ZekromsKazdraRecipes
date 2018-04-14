function init()
	self.recipes=root.assetJson(config.getParameter("recipefile"))
	for key,value in pairs(self.recipes) do
		if value["input"]==nil or value["output"]==nil then
			sb.logWarn("Invalid recipe")
			sb.logInfo(key)
			table.remove(self.recipes, key)
			key=key-1
		end
	end
	--[[if self.recipes==nil or next(self.recipes)==nil then
		uninit()
	end]]
end

function update(dt)
	sb.logInfo("updateFN")
	storage.overflow=containerTryAdd(storage.overflow)
	storage.overflow=containerTryAdd(storage.overflow)
	sb.logInfo("update|overflowDN")
	if storage.overflow==nil then
		local stack=world.containerItems(entity.id())
		for key,value in pairs(self.recipes) do
			sb.logInfo("update|consumeItems")
			storage.overflow=consumeItemsO(value["input"], value["output"], stack)
			if storage.overflow~=false then	break	end
		end
	end
end

function containerTryAdd(items)
	if items==nil then	return nil	end
	local ran,value=pcall(function(items) return containerAddItems(items) end)
	if ran then
		return value
	else
		return nil
	end
end

function containerAddItems(items)
	local id=entity.id()
	local arr={}
	for key,item in pairs(items) do
		local t=world.containerAddItems(id, item)
		if type(t)=="table" then table.insert(arr, t) end
	end
	return arr
end

function consumeItemsO(items, prod, stack) --In order
	sb.logInfo("consumeItemsO")
	for key,value in pairs(items) do
		sb.logInfo("consumeItemsO|Has")
		if stack[key]==nil then	return false	end
		if not(value["name"]==stack[key]["name"] and value["count"]<stack[key]["count"]) then
			return false
		end
	end
	for key,value in pairs(items) do
		sb.logInfo("consumeItemsO|consume")
		world.containerConsume(entity.id(), value)
	end
	for key,value in pairs(prod) do
		sb.logInfo("consumeItemsO|pool")
		if value["pool"]~=nil then
			local pool=root.createTreasure(value["pool"], value["level"] or 0)
			table.remove(prod, key)
			key=key-1
			for key2,value2 in pairs(pool) do
				table.insert(prod, value2)
			end
		end
	end
	sb.logInfo("consumeItems|ret")
	return containerAddItems(prod)
end

function consumeItems(items, prod, stack) --No order
	sb.logInfo("consumeItems")
	for key,value in pairs(items) do
		sb.logInfo("consumeItems|Has")
		if world.containerAvailable(entity.id(), value["name"])<value["count"] then
			return false --!!Issue!!
		end
	end
	for key,value in pairs(items) do
		sb.logInfo("consumeItems|consume")
		world.containerConsume(entity.id(), value)
	end
	for key,value in pairs(prod) do
		sb.logInfo("consumeItems|pool")
		if value["pool"]~=nil then
			if root.isTreasurePool(value["pool"]) then
				local pool=root.createTreasure(value["pool"], value["level"] or 0)
				table.remove(prod, key)
				key=key-1
				for key2,value2 in pairs(pool) do
					table.insert(prod, value2)
				end
			else
				table.remove(prod, key)
			end
		end
	end
	sb.logInfo("consumeItems|ret")
	return containerAddItems(prod)
end

function die()
	local poz=entity.position()
	for key,item in storage.overflow do
		world.spawnItem(item.name, poz, item.count)
	end
end