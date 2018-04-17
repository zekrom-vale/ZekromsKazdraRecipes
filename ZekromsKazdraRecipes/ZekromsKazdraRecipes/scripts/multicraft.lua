function init()
	if storage.clock==nil then
		storage.clock=0
	end
	self.input=config.getParameter("multicraftAPI.input", {1, size})
	self.output=config.getParameter("multicraftAPI.output", {1, size})
	self.recipes=root.assetJson(config.getParameter("multicraftAPI.recipefile"),{})
	self.clockMax=math.floor(config.getParameter("multicraftAPI.clockMax",10000))
	verify()
end

function verify()
	if #self.input>2 or #self.output>2 then
		logModAPI()
		sb.logInfo("Input/output array is not 2 elements for: "..sbName()..".  Ignoring the other ones")
	end
	local size=world.containerSize(entity.id())
	self.input={fixIO(self.input[1],size) or 1, fixIO(self.input[2],size) or size}
	self.output={fixIO(self.output[1],size) or 1, fixIO(self.output[2],size) or size}

	if self.input[1]>self.input[2] then
		local t=self.input[2]
		self.input[1]=self.input[2]
		self.input[2]=t
		t=nil
		logModAPI()
		sb.logInfo("Input values swapped, please use [small, large] for: "..sbName())
	end
	if self.output[1]>self.output[2] then
		local t=self.output[2]
		self.output[1]=self.output[2]
		self.output[2]=t
		t=nil
		logModAPI()
		sb.logInfo("Output values swapped, please use [small, large] for: "..sbName())
	end
	verifyIn()
	if next(self.recipes)==nil then
		logModAPI()
		sb.logError("No recipe file defined for: "..sbName())
	end
end

function fixIO(item,size)
	if item==nil or type(item)~="number" or item%1~=0 or item>size or item<=0 then
		logModAPI()
		sb.logWarn("Input/output array is not 2 elements for: "..sbName()..".  Trying to compensate")
		return nil
	end
	return item
end

function verifyIn()
	local act=function(value,key)
		sb.logInfo(sb.printJson(value,1))
		table.remove(self.recipes, key)
		return key-1
	end
	for key,value in pairs(self.recipes) do
		if value.input==nil or value.output==nil then
			logModAPI(); sb.logWarn("Input/output missing for: "..sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.input>self.input[2]-self.input[1]+1 then
			logModAPI(); sb.logWarn("Input overflow in: "..sbName())
			key=act(value,key)
			goto testEnd
		elseif #value.output>self.output[2]-self.output[1]+1 then
			logModAPI(); sb.logInfo("Output overflow in: "..sbName())
			sb.logInfo(sb.printJson(value,1))
		end
		if value.delay~=nil and value.delay%1~=0 then
			logModAPI(); sb.logInfo("Dellay is not an 'int' in: "..sbName())
			sb.logInfo(sb.printJson(value,1))
			value.delay=math.floor(value.delay)
		end
		for _,out in pairs(value.output) do
			if out.pool==nil then	break	end
			if not root.isTreasurePool(out.pool) then
				logModAPI()
				sb.logWarn("Invalid pool in: "..sbName())
				key=act(value,key)
				goto testEnd
			end
		end
		::testEnd::
	end
end


function logModAPI()
	sb.logInfo("---  API mod: 'ZekromsMulticraftAPI'  ---")
end

function sbName()
	local name=config.getParameter("objectName")
	if name~=nil then	name=config.getParameter("itemName")	end
	return "'"..(name or "null").."'"
end

function update(dt)
	storage.clock=(storage.clock+1)%self.clockMax
	if storage.wait~=nil and storage.wait==storage.clock then
		storage.overflow=containerTryAdd(storage.overflow)
		storage.wait=nil
		return
	elseif storage.wait~=nil then
		return
	end
	storage.overflow=containerTryAdd(storage.overflow)
	if type(storage.overflow)~="table" then
		local stack=world.containerItems(entity.id())
		for _,value in pairs(self.recipes) do
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
	for _,item in pairs(items) do
		local t=containerPutAt(item, self.output)
		if type(t)=="table" then table.insert(arr, t) end
	end
	return arr
end

function consumeItemsShaped(items, prod, stacks, delay) --In order
	for key,item in pairs(items) do
		local stack=stacks[key+self.input[1]-1]
		if stack==nil then	return false	end
		if not(item["name"]==stack["name"] and item["count"]<=stack["count"]) then
			return false
		end
	end
	for _,item in pairs(items) do
		containerConsumeAt(item, self.input)
	end
	prod=treasure(prod)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%self.clockMax
		return prod
	end
	return containerAddItems(prod)
end

function consumeItems(items, prod, stack, delay) --No order
	for _,item in pairs(items) do
		if true then
			local counts=0
			for index=self.input[1],self.input[2] do
				if stack[index]~=nil and item.name==stack[index]["name"] then
					counts=counts+stack[index]["count"]
					if item.count<=counts then	goto skip	end
				end
			end
			return false --Must be last statement in a block
		end
		::skip::
	end
	for _,item in pairs(items) do
		containerConsumeAt(item, self.input)
	end
	prod=treasure(prod)
	if not(delay==nil or delay==0) then
		storage.wait=(storage.clock+delay)%self.clockMax
		return prod
	end
	return containerAddItems(prod)
end

function treasure(pass)
	local items=deepcopy(pass)
	for key,item in pairs(items) do
		if item.pool~=nil then
			local pool=root.createTreasure(item.pool, item.level or 0)
			table.remove(items, key)
			key=key-1
			for _,val in pairs(pool) do
				table.insert(items, val)
			end
		end
	end
	return items
end

function die()
	local drop=config.getParameter("multicraftAPI.drop", "all")
	local poz=entity.position()
	if drop=="all" then
		for _,item in pairs(storage.overflow) do
			world.spawnItem(item.name, poz, item.count)
		end
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
	return item
end

--http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
	local copy
	if type(orig)=='table' then
		copy={}
		for orig_key,orig_value in next, orig, nil do
			copy[deepcopy(orig_key)]=deepcopy(orig_value)
		end
		setmetatable(copy, deepcopy(getmetatable(orig)))
	else
		return orig
	end
	return copy
end