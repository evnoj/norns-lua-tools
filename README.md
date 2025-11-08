A repository containing useful lua tools, for use on the [monome norns](https://monome.org/docs/norns/) sound computer.

# installation
The repo should be cloned into `code/tools`, ex. while SSHed into norns run
```sh
git clone https://github.com/evannjohnson/norns-lua-tools.git /home/we/dust/code/tools
```

# usage
- load all tools with `include(tools/tools)`
- load a specific tool like `inspect = require("tools.inspect")` or `file = require("tools.pl.file")`

# the tools
- [inspect](https://github.com/kikito/inspect.lua)
- [base64](http://lua-users.org/wiki/BaseSixtyFour)
- [lunajson](https://github.com/grafi-tt/lunajson)
- [Penlight](https://github.com/lunarmodules/Penlight)
- [debugger.lua](https://github.com/slembcke/debugger.lua)

# notes
`.lua` files are directly copied rather than using submodules. This is for simplicity. However, it means I must manually update this library. If you need me to update something in this library, let me know.

## compilation
- compiled `.so` files go into `./bin`, and `package.cpath` needs to have this dir appended to it, `require("tools.add_tools_cpath")()` will accomplish this
  - I have added this to some of the files when it is needed
- Penlight
  - Some Penlight modules depend on luafilesystem, a C module. I compiled `lfs.so` on norns by cloning [the luafilesystem repo](https://github.com/lunarmodules/luafilesystem), setting the lua version in the `config` file to 5.3, building it, and placing it in the `bin` folder. `pl/path.lua` appends to `package.cpath` so that lua can find `lfs.so` in this location.
- luasocket
```sh
git clone https://github.com/lunarmodules/luasocket/
cd luasocket
make LUAV=5.3
cd src
mv socket.lua ltn12.lua mime.lua ../../.
mkdir -p ../../socket
mv http.lua url.lua tp.lua ftp.lua headers.lua smtp.lua unix.so serial.so ../../socket/
mkdir -p ../../bin/socket
mv socket-3.1.0.so ../../bin/socket/core.so
mkdir -p ../../bin/mime
mv mime-1.0.3.so ../../bin/mime/core.so
```
  - modify `socket.lua` to call `add_tools_cpath`
