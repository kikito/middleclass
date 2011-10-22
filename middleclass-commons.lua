common = type(common) == "table" and common or {}

function common.class(name, class, superclass)
	superclass = superclass or Object
	local c = superclass:subclass(name)
	for i, v in pairs(class) do
		c[i] = v
	end
	if class.init then
		c.initialize = class.init
	end
	return c
end
