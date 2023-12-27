local configs = require("gentags.configs")

local M = {}

local WORKER_MAP = {
  ctags = require("gentags.ctags"),
}

local function get_worker()
  local binary = configs.get().bin
  local target = string.lower(binary)
  local worker = WORKER_MAP[target]
  assert(
    worker ~= nil,
    string.format("%s is not supported!", vim.inspect(binary))
  )
  return worker
end

M.load = function()
  get_worker().load()
end

M.run = function()
  get_worker().run()
end

M.terminate = function()
  get_worker().terminate()
end

return M
