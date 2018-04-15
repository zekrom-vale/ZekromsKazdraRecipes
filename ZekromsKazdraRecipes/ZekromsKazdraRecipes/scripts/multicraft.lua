function init()
	--self.clock=0
	self.input=config.getParameter("input", nil)
	self.output=config.getParameter("output", nil)
	self.recipes=root.assetJson(config.getParameter("recipefile"))
	for key,value in pairs(self.recipes) do
		if value["input"]==nil or value["output"]==nil then
			sb.logWarn(sb.printJson(value,1))
			table.remove(self.recipes, key)
			key=key-1
		end
	end
end

function update(dt)
	--self.clock=self.clock+1
	storage.overflow=containerTryAdd(storage.overflow)
	storage.overflow=containerTryAdd(storage.overflow)
	if type(storage.overflow)~="table" then
		local stack=world.containerItems(entity.id())
		for key,value in pairs(self.recipes) do
			storage.overflow=consumeItems(value.input, value.output, stack)
			if storage.overflow~=false then	break	end
		end
	end
end

function containerTryAdd(items)
	if type(items)~="table" or next(items)==nil then
		return nil
	else
		return containerAddItems(items)
	end
end

function containerAddItems(items)
	local id=entity.id()
	local arr={}
	for key,item in pairs(items) do
		local t=containerPutAt(item, self.output)
		if type(t)=="table" then table.insert(arr, t) end
	end
	return arr
end

function consumeItemsO(items, prod, stack) --In order
	for key,value in pairs(items) do
		if stack[key]==nil then	return false	end
		if not(value["name"]==stack[key]["name"] and value["count"]<=stack[key]["count"]) then
			return false
		end
	end
	for key,value in pairs(items) do
		containerConsumeAt(value, self.input)
	end
	prod=treasure(prod)
	return containerAddItems(prod)
end

function consumeItems(items, prod, stack) --No order
	for key,item in pairs(items) do
		if 1==1 then
			local counts=0
			for key2,value2 in pairs(stack) do
				if item.name==value2.name then
					counts=counts+value2.count
					if item.count<=counts then
						goto skip
					end
				end
			end
			return false --Must be last statement in a block
		end
		::skip::
	end
	for key,value in pairs(items) do
		containerConsumeAt(value, self.input)
	end
	prod=treasure(prod)
	return containerAddItems(prod)
end

function treasure(items)
	for key,item in pairs(items) do
		if item.pool~=nil then
			if root.isTreasurePool(item.pool) then
				local pool=root.createTreasure(item.pool, item.level or 0)
				table.remove(items, key)
				key=key-1
				for key2,val in pairs(pool) do
					table.insert(items, val)
				end
			else
				sb.logWarn("Invalid pool")
				sb.logWarn(sb.printJson(item,1))
				table.remove(items, key)
				key=key-1
			end
		end
	end
	return items
end

function die()
	local poz=entity.position()
	for key,item in storage.overflow do
		world.spawnItem(item.name, poz, item.count)
	end
end

function containerConsumeAt(item, range)
	sb.logInfo(sb.printJson(range))
	for offset=range[1],range[2] do
		local stack=world.containerItemAt(entity.id(), offset)
		if stack~=nil and stack.name==item.name then
			world.containerConsumeAt(entity.id(), offset, item.count)
			item.count=item.count-stack.count
			if item.count<=0 then	return true	end
		end
	end
	return false
end

function containerPutAt(item, range)
	sb.logInfo(sb.printJson(range))
	for offset=range[1],range[2] do
		local stack=world.containerItemAt(entity.id(), offset)
		if stack~=nil and stack.name==item.name then
			world.containerPutItemsAt(entity.id(), item, offset)
			item.count=item.count-stack.count
			if item.count<=0 then	return true	end
		end
	end
	return items
end