return function()
    if not string.find(package.cpath, "/usr/local/lib/lua/5.3/tools/bin/%?%.so") then
        package.cpath=package.cpath..";/usr/local/lib/lua/5.3/tools/bin/?.so"
    end
end
