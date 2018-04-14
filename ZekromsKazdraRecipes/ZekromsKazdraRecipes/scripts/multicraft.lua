function init()
	sb.logInfo("init")
	self.overflow={}
	self.recipes=root.assetJson(config.getParameter("recipefile"))
	for key,value in pairs(self.recipes) do
		if value["input"]==nil or value["output"]==nil then
			sb.logError("Invalid recipe")
			sb.logError(key)
			table.remove(self.recipes, key)
			key=key-1
		end
	end
	--[[if self.recipes==nil or next(self.recipes)==nil then
		uninit()
	end]]
end

function update(dt)
	sb.logInfo("update")
	if type(self.overflow)=="table" then
		sb.logInfo("update|overflow")
		self.overflow=containerAdd(self.overflow)
	end
	if self.overflow==nil or (
		type(self.overflow)=="table" and next(self.overflow)==nil
	) then
		for key,value in pairs(self.recipes) do
			sb.logInfo("update|consumeItems")
			self.overflow=consumeItemsO(value["input"], value["output"])
			if self.overflow~=false then
				break
			end
		end
	end
end

function containerAdd(items)
	if items==nil then return nil end
	ran,value=pcall(function(items) return world.containerAddItems(entity.id(), items) end)
	if ran then
		return value
	else
		return nil
	end
end

function consumeItemsO(items, prod) --In order
	sb.logInfo("consumeItemsO")
	stack=world.containerItems(entity.id())
	for key,value in pairs(items) do
		sb.logInfo("consumeItemsO|Has")
		if not(value["name"]==stack[key]["name"] and value["count"]>=stack[key]["count"]) then
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
	return world.containerAddItems(entity.id(), prod)
end

function consumeItems(items, prod) --No order
	sb.logInfo("consumeItems")
	stack=world.containerItems(entity.id())
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
	return world.containerAddItems(entity.id(), prod)
end