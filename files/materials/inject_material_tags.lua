function InjectTags(namepattern, tag)
    local pattern = "(<[%s]-CellData[^>]-%sname=\"" .. namepattern .. "\"[^>]-%stags=\")([^\"]-)(\"[^>]->)"
    -- local pattern2 = "(<[%s]-CellData[^>]-%stags=\")([^\"]-)(\"%sname=\"" .. namepattern .. "\"[^>]-[^>]->)"
    local mats = ModTextFileGetContent("data/materials.xml")
    mats = string.gsub(mats, pattern, "%1%2," .. tag .. "%3")
    ModTextFileSetContent("data/materials.xml", mats)
end

InjectTags("[^\"]-wood[^\"]-", "[azoth_wood]")
