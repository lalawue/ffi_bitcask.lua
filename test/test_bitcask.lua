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
local value = "abcdefghijklmnopqrstuvwxyz"

for i = 1, count, 1 do
    db:set(tostring(i), value)
end

local has_invalid = false
for i = 1, count, 1 do
    if db:get(tostring(i)) ~= value then
        print("Invalid get ", i)
        has_invalid = true
    end
end

if not has_invalid then
    print("PASS Set/Get")
end

for i = 1, count, 2 do
    db:remove(tostring(i))
end

has_invalid = false
for i = 1, count, 2 do
    if db:get(tostring(i)) then
        has_invalid = true
        print("Failed to delete ", i)
    end
end

if not has_invalid then
    print("PASS Delete")
end

db:gc("0")

has_invalid = false
for i = 1, count, 1 do
    if i % 2 == 1 then
        if db:get(tostring(i)) then
            has_invalid = true
            print("GC failed to delete ", i)
        end
    else
        if db:get(tostring(i)) ~= value then
            has_invalid = true
            print("GC failed to get ", i)
        end
    end
end

if not has_invalid then
    print("PASS GC")
end

