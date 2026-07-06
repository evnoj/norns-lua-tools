return function()
    if not string.find(package.path, "/usr/local/lib/lua/5.3/tools/%?%.lua") then
        package.path=package.path..";/usr/local/lib/lua/5.3/tools/?.lua"
    end
end
