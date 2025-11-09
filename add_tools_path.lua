return function()
    if not string.find(package.path, "/home/we/dust/code/tools/%?%.lua") then
        package.path=package.path..";/home/we/dust/code/tools/?.lua"
    end
end
