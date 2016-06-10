--[[
Copyright 2016 Rackspace

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
local gatherReadWriteReadOnlyInfo = require('../ro').gatherReadWriteReadOnlyInfo

local HostInfo = require('./base').HostInfo

--[[ Filesystem RO Info ]]--
local Info = HostInfo:extend()
function Info:initialize()
  HostInfo.initialize(self)
end
function Info:_run(callback)
  local fs_list_ro, fs_list_rw = gatherReadWriteReadOnlyInfo()
  if #fs_list_ro == 0 then fs_list_ro = table.insert(fs_list_ro, '<none>') end
  if #fs_list_rw == 0 then fs_list_rw = table.insert(fs_list_rw, '<none>') end
  self._params = {
    total_ro = tostring(#fs_list_ro),
    total_rw = tostring(#fs_list_rw),
    devices_ro = table.concat(fs_list_ro, ','),
    devices_rw = table.concat(fs_list_rw, ',')
  }
  p(self._params)
  callback()
end

function Info:getType()
  return 'FILESYSTEM_RO'
end

function Info:getPlatforms()
  return {'linux'}
end

return Info
