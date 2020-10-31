---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
--
-- xml.lua - XML parser for use with the Corona SDK.
--
-- version: 1.2
--
-- CHANGELOG:
--
-- 1.2 - Created new structure for returned table
-- 1.1 - Fixed base directory issue with the loadFile() function.
--
-- NOTE: This is a modified version of Alexander Makeev's Lua-only XML parser
-- found here: http://lua-users.org/wiki/LuaXml
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
function newParser()

    XmlParser = {};

    function XmlParser:ToXmlString(value)
        value = string.gsub(value, "&", "&amp;"); -- '&' -> "&amp;"
        value = string.gsub(value, "<", "&lt;"); -- '<' -> "&lt;"
        value = string.gsub(value, ">", "&gt;"); -- '>' -> "&gt;"
        value = string.gsub(value, "\"", "&quot;"); -- '"' -> "&quot;"
        value = string.gsub(value, "([^%w%&%;%p%\t% ])", function(c)
            return string.format("&#x%X;", string.byte(c))
        end);
        return value;
    end

    function XmlParser:FromXmlString(value)
        value = string.gsub(value, "&#x([%x]+)%;", function(h)
            return string.char(tonumber(h, 16))
        end);
        value = string.gsub(value, "&#([0-9]+)%;", function(h)
            return string.char(tonumber(h, 10))
        end);
        value = string.gsub(value, "&quot;", "\"");
        value = string.gsub(value, "&apos;", "'");
        value = string.gsub(value, "&gt;", ">");
        value = string.gsub(value, "&lt;", "<");
        value = string.gsub(value, "&amp;", "&");
        return value;
    end

    function XmlParser:ParseArgs(node, s)
        string.gsub(s, "([%w_:]+)=([\"'])(.-)%2", function(w, _, a)
            node:addProperty(w, self:FromXmlString(a))
        end)
    end

    function XmlParser:ParseXmlText(xmlText)
        local stack = {}
        local top = newNode()
        table.insert(stack, top)
        local ni, c, label, xarg, empty
        local i, j = 1, 1

        xmlText = string.gsub(xmlText, "<!%-%-.- %-%->", "")

        while true do
            ni, j, c, label, xarg, empty = string.find(xmlText, "<(%/?)([%w_:]+)(.-)(%/?)>", i)
            if not ni then
                break
            end
            local text = string.sub(xmlText, i, ni - 1);
            if not string.find(text, "^%s*$") then
                local lVal = (top:value() or "") .. self:FromXmlString(text)
                stack[#stack]:setValue(lVal)
            end
            if empty == "/" then -- empty element tag
                local lNode = newNode(label)
                self:ParseArgs(lNode, xarg)
                top:addChild(lNode)
            elseif c == "" then -- start tag
                local lNode = newNode(label)
                self:ParseArgs(lNode, xarg)
                table.insert(stack, lNode)
                top = lNode
            else -- end tag
                local toclose = table.remove(stack) -- remove top

                top = stack[#stack]
                if #stack < 1 then
                    error("XmlParser: nothing to close with " .. label)
                end
                if toclose:name() ~= label then
                    error("XmlParser: trying to close " .. toclose.name .. " with " .. label)
                end
                top:addChild(toclose)
            end
            i = j + 1
        end
        local text = string.sub(xmlText, i);
        if #stack > 1 then
            error("XmlParser: unclosed " .. stack[#stack]:name())
        end
        return top
    end

    function XmlParser:loadFile(xmlFilename, base)
        if not base then
            base = system.ResourceDirectory
        end

        local path = system.pathForFile(xmlFilename, base)
        local hFile, err = io.open(path, "r");

        if hFile and not err then
            local xmlText = hFile:read("*a"); -- read file content
            io.close(hFile);
            return self:ParseXmlText(xmlText), nil;
        else
            print(err)
            return nil
        end
    end

    return XmlParser
end

function newNode(name)
    local node = {}
    node.___value = nil
    node.___name = name
    node.___children = {}
    node.___props = {}

    function node:value()
        return self.___value
    end
    function node:setValue(val)
        self.___value = val
    end
    function node:name()
        return self.___name
    end
    function node:setName(name)
        self.___name = name
    end
    function node:children()
        return self.___children
    end
    function node:numChildren()
        return #self.___children
    end
    function node:addChild(child)
        if self[child:name()] ~= nil then
            if type(self[child:name()].name) == "function" then
                local tempTable = {}
                table.insert(tempTable, self[child:name()])
                self[child:name()] = tempTable
            end
            table.insert(self[child:name()], child)
        else
            self[child:name()] = child
        end
        table.insert(self.___children, child)
    end

    function node:addChildren(children)
        for i, child in ipairs(children) do
            self:addChild(child)
        end
    end

    function node:removeChildren(children)
        for i, c1 in ipairs(children) do
            for j, c2 in ipairs(self.___children) do
                if c1 == c2 then
                    table.remove(self.___children, j)
                    break
                end
            end
        end
    end

    function node:getChildrenWithProp(childname, propname, propval)
        -- Returns a list of child nodes with property @name equal to value
        -- if value is nil, returns all children that have the property at all
        local output = {}

        for k, child in ipairs(self.___children) do
            if childname ~= nil and child:name() ~= childname then
                -- Exclude children with the wrong name if relevant
                -- print("Excluding by name")
            elseif propname ~= nil and child["@" .. propname] == nil then
                -- Exclude children that don't have the property
                -- print("Excluding by nil property")
            elseif propname ~= nil and propval ~= nil and child["@" .. propname] ~= propval then
                -- Exclude children with the wrong peroperty value if relevant
                -- print("Excluding by property")
            else
                -- print("found child")
                table.insert(output, child)
            end
        end
        return output
    end

    function node:properties()
        return self.___props
    end
    function node:numProperties()
        return #self.___props
    end
    function node:addProperty(name, value)
        local lName = "@" .. name
        self[lName] = value
        table.insert(self.___props, {
            name = name,
            value = self[lName]
        })
    end
    function node:toString()
        local output = "<" .. tostring(self.___name) .. " "
        for k, val in ipairs(self.___props) do
            if type(val.value) == "table" then
                for i, j in pairs(val.value) do
                    print(tostring(i) .. ": " .. tostring(j))
                end
            end
            output = output .. val.name .. "=\"" .. val.value .. "\"\n"
        end
        output = output .. ">\n"
        for k, child in ipairs(self.___children) do
            output = output .. child:toString()
        end
        output = output .. "</" .. tostring(self.___name) .. ">\n"
        return output
    end

    return node
end

function nodeFromDict(name, properties)
    local new_node = newNode(name)
    for k, v in pairs(properties) do
        new_node:addProperty(k, v)
    end
    return new_node
end
