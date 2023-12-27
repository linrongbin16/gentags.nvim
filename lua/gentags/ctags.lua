local logging = require("gentags.commons.logging")

local utils = require("gentags.utils")

local M = {}

M.run = function()
  local logger = logging.get("gentags") --[[@as commons.logging.Logger]]

  local workspace = utils.get_workspace()
  local filename = utils.get_filename()
  local filetype = utils.get_filetype()
  logger:debug(
    "|run| workspace:%s, filename:%s, filetype:%s",
    vim.inspect(workspace),
    vim.inspect(filename),
    vim.inspect(filetype)
  )
end

M.terminate = function() end

M.gc = function() end

return M
