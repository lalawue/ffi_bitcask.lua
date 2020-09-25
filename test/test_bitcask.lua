--
--

local Bitcask = require("ffi_bitcask")
local FileSystem = require("base.ffi_lfs")

local config = {
    dir = "/tmp/bitcask",
    file_size = 512 -- 512 byte
}

local db = Bitcask.opendb(config)

-- test bucket
db:changeBucket("hello")
db:set("a", "b")

local attr = FileSystem.attributes("/tmp/bitcask/hello")
if not attr or attr.mode ~= "directory" then
    print("failed to create bucket 'hello'")
    os.exit(0)
end

attr = FileSystem.attributes("/tmp/bitcask/hello/0000000000.dat")
if not attr or attr.mode ~= "file" then
    print("failed to set in bucket 'hello'")
    os.exit(0)
end

-- change to default bucket with set/get/delete/gc
--
db:changeBucket("0")

local count = 256

for i = 1, count, 1 do
    db:set(tostring(i), "abcdefghijklmnopqrstuvwxyz")
end

for i = 1, count, 1 do
    if db:get(tostring(i)) ~= "abcdefghijklmnopqrstuvwxyz" then
        print("invalid get ", i)
    end
end

for i = 1, count, 2 do
    db:remove(tostring(i))
end

for i = 1, count, 2 do
    if db:get(tostring(i)) then
        print("failed to delete ", i)
    end
end

db:gc("0")

for i = 1, count, 2 do
    if db:get(tostring(i)) then
        print("2 failed to delete ", i)
    end
end

