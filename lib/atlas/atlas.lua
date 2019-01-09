function AtlasCL()
	local po2, info
	for _, v in pairs(arg) do
		if v:sub(1,6) == "--info" then info = true end
		if v:sub(1,5) == "--po2" then po2 = true end
		if v:sub(1,8) == "--silent" then silent = true end
	end
	return Atlas(1, 1, po2 or false, "out", "at1", info, silent)
end

function Atlas(w, h, po2, path, file, info, silent)

	local success

	local self = {w = w or 1, h = h or 1, map = {}, uv = {}, po2 = po2 or true}
	self.settings = {}

	local function Node(x, y, w, h)
		return {x = x, y = y, w = w, h = h}
	end

	local function nextp2(n)
		local res = 1
		while res <= n do
			res = res * 2
		end
		return res
	end

	local function add(root, id, w, h)
		if root.left or root.right then
			if root.left then
				local node = add(root.left, id, w, h)
				if node then return node end
			end
			if root.right then
				local node = add(root.right, id, w, h)
				if node then return node end
			end
			return nil
		end

		if w > root.w or h > root.h then return nil end

		local _w, _h = root.w - w, root.h - h

		if _w <= _h then
			root.left = Node(root.x + w, root.y, _w, h)
			root.right = Node(root.x, root.y + h, root.w, _h)
		else
			root.left = Node(root.x, root.y + h, w, _h)
			root.right = Node(root.x + w, root.y, _w, root.h)
		end

		root.w = w
		root.h = h
		root.id = id

		return root
	end

	local function unmap(root)
		if not root then return {} end

		local tree = {}
		if root.id then
			tree[root.id] = {}
			tree[root.id].x, tree[root.id].y = root.x, root.y
		end

		local left = unmap(root.left)
		local right = unmap(root.right)

		for k, v in pairs(left) do
			tree[k] = {}
			tree[k].x, tree[k].y = v.x, v.y
		end
		for k, v in pairs(right) do
			tree[k] = {}
			tree[k].x, tree[k].y = v.x, v.y
		end

		return tree
	end

	local function getImages(sort)
		local files, images = love.filesystem.getDirectoryItems(path), {}
		for i = 1, #files do
			images[i] = {}
			images[i].name = files[i]
			images[i].image = love.graphics.newImage(path .. "/" .. files[i])
			images[i].w = images[i].image:getWidth()
			images[i].h = images[i].image:getHeight()
			images[i].area = images[i].w * images[i].h
		end
		files = nil
		if sort ~= false then table.sort(images, function(a, b) return (a.area > b.area) end) end
		return images
	end

	function self.out(filename, format)
		local format = format or "png"
		local file = love.filesystem.newFile(filename .. ".txt")
		file:open("w")
		for i = 1, #self.uv do
			file:write(self.uv[i].name .. "," .. self.uv[i].x .. "," .. self.uv[i].y .. ";\r\n")
		end
		file:close()
		self.map:newImageData():encode(format, filename .. ".png")
	end

	function self.build(path)

		local root = {}
		local w, h = self.w, self.h

		local images = getImages()

		if w < images[1].w then w = images[1].w end
		if h < images[1].h then h = images[1].h end

		if po2 then
			if w % 1 == 0 then w = nextp2(w) end
			if h % 1 == 0 then h = nextp2(h) end
		end

		limit = 9999--love.graphics.getSystemLimit("texturesize")

		repeat
			local node

			root = Node(0, 0, w, h)

			for i = 1, #images do
				node = add(root, i, images[i].image:getWidth(), images[i].image:getHeight())
				if not node then break end
			end

			if not node then
				if h <= w then
					if po2 then h = h * 2 else h = h + 1 end
				else
					if po2 then w = w * 2 else w = w + 1 end
				end
			else
				break
			end
		until false

		success = (w <= limit and h <= limit)

		local coords = unmap(root)
		self.map = love.graphics.newCanvas(w, h)

		love.graphics.clear()

		love.graphics.setCanvas(self.map)
		for i = 1, #images do
			love.graphics.draw(images[i].image, coords[i].x, coords[i].y)
			self.uv[i] = {}
			self.uv[i].name = images[i].name
			self.uv[i].x, self.uv[i].y = coords[i].x, coords[i].y
			self.uv[i].w, self.uv[i].h = images[i].w, images[i].h
			if info then
				print(self.uv[i].name, self.uv[i].x, self.uv[i].y, self.uv[i].w, self.uv[i].h)
			end
		end
		love.graphics.setCanvas()
		images = nil
	end

	if path then self.build(path) end

	if success then
		if file then self.out(file) end
		if info then print(self.map:getWidth() .. " x " .. self.map:getHeight()) end
		res = self
	else
		res = "toolarge"
	end

	if silent then
		love.event.quit()
	else
		return res
	end
end
