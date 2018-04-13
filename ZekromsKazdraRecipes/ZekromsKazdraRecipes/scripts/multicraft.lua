function init()
	self.overflow={}
	self.recipes=root.assetJson(config.getParameter("recipefile"))
	for key,value in pairs(self.recipes) do
		if value["input"]== nil or value["input"][0]==nil or value["output"]== nil then
			sb.logError("Invalid recipe")
			sb.printJson(value, true)
			table.remove(self.recipes, key)
			key=key-1
		end
	end
	if self.recipes==nil or next(self.recipes)==nil then
		uninit()
	end
end

function update(dt)
	if not(self.overflow==nil or next(self.overflow)==nil) then
		self.overflow=world.containerAddItems(entity.id(), self.overflow)
	end
	if self.overflow==nil or next(self.overflow)==nil then
		for key,value in pairs(self.recipes) do
			self.overflow=consumeItems(value["input"], value["output"])
			if self.overflow~=false then
				break
			end
		end
	end
end

function consumeItemsO(items, prod) --In order
	stack=world.containerItems(entity.id())
	for key,value in pairs(items) do
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
		if not world.containerAvailable(entity.id(), value.name)>=value.count then
			return false
		end
	end
	for key,value in pairs(items) do
		world.containerConsume(entity.id(), value)
	end
	for key,value in pairs(prod) do
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
	return world.containerAddItems(entity.id(), prod)
end