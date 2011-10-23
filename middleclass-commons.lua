if common_class ~= false then
	common = type(common) == "table" and common or {}

	function common.class(name, class, superclass)
		local c = (superclass or Object):subclass(name)
		for i, v in pairs(class) do
			c[i] = v
		end
		if class.init then
			c.initialize = class.init
		end
		return c
	end
end
