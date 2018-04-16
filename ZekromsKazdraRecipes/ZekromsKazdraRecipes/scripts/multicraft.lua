function init()
	if storage.clock==nil then
		storage.clock=0
	end
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
	storage.clock=(storage.clock+1)%1000000
	if storage.wait==storage.clock then
		storage.overflow=containerAddItems(storage.overflow)
		storage.wait=nil
		return
	elseif not(storage.wait==nil or storage.wait==0) then
		return
	end
	storage.overflow=containerTryAdd(storage.overflow)
	storage.overflow=containerTryAdd(storage.overflow)
	if type(storage.overflow)~="table" then
		local stack=world.containerItems(entity.id())
		for key,value in pairs(self.recipes) do
			if value.shaped then
				storage.overflow=consumeItemsShaped(value.input, value.output, stack, value.delay)
				if storage.overflow~=false then	break	end
			else
				storage.overflow=consumeItems(value.input, value.output, stack, value.delay)
				if storage.overflow~=false then	break	end
			end
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

function consumeItemsShaped(items, prod, stack, delay) --In order
	for key,value in pairs(items) do
		local value2=stack[key+self.input[1]-1]
		if value2==nil then	return false	end
		if not(value["name"]==value2["name"] and value["count"]<=value2["count"]) then
			return false
		end
	end
	for key,value in pairs(items) do
		containerConsumeAt(value, self.input)
	end
	prod=treasure(prod)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%1000000
		return prod
	end
	return containerAddItems(prod)
end

function consumeItems(items, prod, stack, delay) --No order
	for key,item in pairs(items) do
		if true then
			local counts=0
			for index=self.input[1],self.input[2] do
				if stack[index]~=nil and item.name==stack[index]["name"] then
					counts=counts+stack[index]["count"]
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
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%1000000
		return prod
	end
	return containerAddItems(prod)
end

function treasure(pass)
	local items=deepcopy(pass)
	sb.logInfo("treasure")
	for key,item in pairs(items) do
		sb.logInfo(sb.printJson(item))
		if item.pool~=nil then
			if root.isTreasurePool(item.pool) then
				local pool=root.createTreasure(item.pool, item.level or 0, math.randomseed(storage.clock))
				sb.logInfo(sb.printJson(pool))
				table.remove(items, key)
				key=key-1
				for key2,val in pairs(pool) do
					table.insert(items, val)
				end
				--Changes the recipe output
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
	local stack=world.containerItems(entity.id())
	for offset=range[1],range[2] do
		if stack[offset]~=nil and stack[offset]["name"]==item.name then
			if stack[offset]["count"]>=item.count then
				world.containerConsumeAt(entity.id(), offset-1, item.count)
				return true
			end
			item.count=item.count-stack[offset]["count"]
			world.containerTakeAt(entity.id(), offset)
		end
	end
	return false
end

function containerPutAt(item, range)
	local stack=world.containerItems(entity.id())
	for offset=range[1],range[2] do
		if stack[offset]==nil or stack[offset]["name"]==item.name then
			item=world.containerPutItemsAt(entity.id(), item, offset-1)
			if item==nil or next(item)==nil or item.count<=0 then
				return true
			end
		end
	end
	return items
end

--http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end