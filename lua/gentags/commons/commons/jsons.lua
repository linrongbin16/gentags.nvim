-- Json encode/decode

local actboy168_json = require(
  (vim.env._COMMONS_NVIM_MODULE_PREFIX or "") .. "commons.actboy168_json"
)

local M = {
  encode = (vim.fn.has("nvim-0.9") and vim.json ~= nil) and vim.json.encode
    or actboy168_json.encode,
  decode = (vim.fn.has("nvim-0.9") and vim.json ~= nil) and vim.json.decode
    or actboy168_json.decode,
}

return M
