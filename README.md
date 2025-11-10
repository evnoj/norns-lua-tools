A repository containing useful lua tools, for use on the [monome norns](https://monome.org/docs/norns/) sound computer.

# installation
The repo should be cloned into `code/tools`, ex. while SSHed into norns run
```sh
git clone https://github.com/evannjohnson/norns-lua-tools.git /home/we/dust/code/tools
```

# usage
- load all tools with `include("tools/tools")`
- load a specific tool like `inspect = require("tools.inspect")` or `file = require("tools.pl.file")`

# the tools
- [inspect](https://github.com/kikito/inspect.lua)
- [base64](http://lua-users.org/wiki/BaseSixtyFour)
- [lunajson](https://github.com/grafi-tt/lunajson)
- [Penlight](https://github.com/lunarmodules/Penlight)
- [debugger.lua](https://github.com/slembcke/debugger.lua)
  - see [debugger usage](#debugger-usage)

## debugger usage
setup:
- SSH into norns
- install `screen` if not installed (`sudo apt update && sudo apt install screen`)
- copy `services/dbg-screen.service` from this repo to `/etc/systemd/system`, then run `sudo systemctl enable dbg-screen.service`
  - see below for a description of what this is doing
- reboot norns

usage:
- `dbg = require("tools.debugger")` to import debugger
- `dbg()` makes breakpoint, `dbg(<expression>)` is a conditional breakpoint (only breaks if `expression == true`)
- while SSHed into norns, run `screen -r dbg` to connect to the debugger
  - can also `ssh -t we@norns.local screen -r dbg`
  - normal `screen` controls apply, also `ctrl-c` to detach from the session
    - to scroll, enter `screen`'s "copy mode" with `ctrl-a [`, then use arrow keys or `ctrl-u` and `ctrl-d` to move around in the buffer, and use `q` or escape to return to controlling the debugger
    - to use the scroll wheel [see this discussion](https://stackoverflow.com/questions/359109/using-the-scrollwheel-in-gnu-screen), requires creating a `.screenrc` config file
  - if the screen session is killed, and a breakpoint is hit, it will freeze norns and likely require a reboot (either via hardware poweroff or `sudo shutdown now`)
- see [debugger.lua](https://github.com/slembcke/debugger.lua) docs for how to control the debugger
  - the repo has a good interactive tutorial if you clone the repo and run `lua tutorial.lua`
- while the debugger has suspended execution, norns UI is unresponsive
- after debugger resumes execution, may need to press K1 a few times to exit/enter system menu for it to become responsive again
- to easily disable the debugger without removing all `dbg()` calls, set `dbg = function() end` to turn the breakpoints into no-ops

configuration:
- `dbg.read` and `dbg.write` can be overwritten to change where the debugger is being controlled from (ex. could use a socket)
- set `DBG_NOCOLOR` global to `true` before `require`ing the module to disable color in the output
  - ex. `DBG_NOCOLOR = true; local dbg = require("tools.debugger")`

---

`debugger.lua` by default reads from stdin and writes to stdout. This doesn't work in norns. We need to have the debugger read and write from something else. We can create a tty with `screen`, connected to a session named `dbg`, and tell the debugger to use that tty. Then we can attach to that tty via `screen`. The systemd service `dbg-screen` calls a script within `tools` when norns starts up. The script uses `screen` to create the tty, and creates a symlink to it at `/tmp/dbg_tty`. This way we can hardcode the tty path in `debugger.lua`. If the debugger can't open this tty, it does not load.
- the `screen` session we create doesn't launch a shell, because a shell interferes with the interaction with the debugger. It just runs `sleep infinity`, which basically creates a blank slate tty for us to use.

# notes
Files from other libraries are copied into the repo rather than using submodules. This is for simplicity. However, it means I must manually update this library. If you need me to update something, let me know.

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
  - modify `socket.lua`'s submodules' to call `add_tools_path`
