

# About

ffi_bitcask.lua was a Key/Value store for LuaJIT, uses [Bitcask](https://en.wikipedia.org/wiki/Bitcask)  on-disk layout, pure LuaJIT code depends on lfs and crc32.

only test in MacOS/Linux.

# Example

```lua
local Bitcask = require("ffi_bitcask")

local config = {
    dir = "/tmp/bitcask",       -- database dir
    file_size = 64*1024*1024    -- each data file 64M
}

local db = Bitcask.opendb(config) -- open database with config

local count = 128
local value = "abcdefghijklmnopqrstuvwxyz"

for i = 1, count, 1 do
    db:set(tostring(i), value)
end

for i = 1, count, 1 do
    if db:get(tostring(i)) ~= value then
        print("invalid get ", i)
    end
end

for i = 1, count, 2 do
    db:remove(tostring(i))
end

db:gc("0") -- garbage collection in bucket '0'

for i = 1, count, 2 do
    if db:get(tostring(i)) then
        print("failed to delete ", i)
    end
end

-- db:closedb() -- no close

```

# Test

```bash
$ luajit test/test_bitcask.lua
PASS Set/Get
PASS Delete
PASS GC
```

