function addXMLComponent(to_file, from)
    local content = ModTextFileGetContent(to_file)
    content = string.gsub(content, "</Entity>", from .. "\n</Entity>")
    ModTextFileSetContent(to_file, content)
end
