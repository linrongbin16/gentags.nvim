local configs = require("gentags.configs")

local M = {}

local WORKER_MAP = {
  ctags = require("gentags.ctags"),
}

M.run = function()
  local cfg = configs.get()

  local target = string.lower(cfg.bin)
  local worker = WORKER_MAP[target]
  if worker then
    worker.run()
  else
    assert(false, string.format("%s is not supported!", vim.inspect(cfg.bin)))
  end
end

M.terminate = function()
  local cfg = configs.get()

  local target = string.lower(cfg.bin)
  local worker = WORKER_MAP[target]
  if worker then
    worker.terminate()
  else
    assert(false, string.format("%s is not supported!", vim.inspect(cfg.bin)))
  end
end

return M
