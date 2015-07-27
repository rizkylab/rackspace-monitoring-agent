--[[
Copyright 2015 Rackspace

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS-IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--]]
local HostInfo = require('./base').HostInfo

local fs = require('fs')
local los = require('los')
local table = require('table')
local misc = require('./misc')

--[[ Passwordstatus Variables ]]--
local Info = HostInfo:extend()
function Info:initialize()
  HostInfo.initialize(self)
end

function Info:run(callback)
  if los.type() ~= 'linux' then
    self._error = 'Unsupported OS for passwdstatus'
    return callback()
  end

  fs.readFile('/etc/passwd', function(err, data)
    if err then
      self._error = "Couldn't read /etc/passwd"
      return callback()
    end

    local users = {}

    for line in data:gmatch("[^\r\n]+") do
      local name = line:match("[^:]*")
      table.insert(users, name)
    end

    local function spawnFunc(datum)
      local cmd = 'passwd'
      local args = {'-S', datum}
      return cmd, args
    end

    local function successFunc(data, obj, datum)
      if data ~= nil and data ~= '' then
        data = data:gsub('[\n|"]','')
        local iter = data:gmatch("%S+")
        obj[iter()] = {
          status = iter(),
          last_changed = iter(),
          minimum_age = iter(),
          warning_period = iter(),
          inactivity_period = iter()
        }
        return
      end
    end

    local function finalCb(obj, errData)
      if obj ~= nil then
        table.insert(self._params, obj)
        if errData ~= nil then
          table.insert(self._params, {
            warnings = errData
          })
        end
        return callback()
      else
        if errData == nil then errData = '' end
        table.insert(self._error, errData)
        return callback()
      end
    end

    return misc.asyncSpawn(users, spawnFunc, successFunc, finalCb)
  end)
end

function Info:getType()
  return 'PASSWD'
end

return Info
