-- Render text with terminal colors

local strings =
  require((vim.env._COMMONS_NVIM_MODULE_PREFIX or "") .. "commons.strings")

local M = {}

-- Format ANSI/RGB color code to terminal print style
--
-- Returns the rendered text content in terminal colors. For example:
-- \27[38;2;216;166;87mCTRL-U\27[0m  (CTRL-U)
--
--- @param code string
--- @param ground "fg"|"bg"|nil   by default "fg"
--- @return string
M.csi = function(code, ground)
  assert(type(code) == "string")
  assert(ground == nil or ground == "bg" or ground == "fg")

  local control = ground == "bg" and 48 or 38
  local r, g, b = code:match("#(..)(..)(..)")
  if r and g and b then
    r = tonumber(r, 16)
    g = tonumber(g, 16)
    b = tonumber(b, 16)
    return string.format("%d;2;%d;%d;%d", control, r, g, b)
  else
    return string.format("%d;5;%s", control, code)
  end
end

-- Pre-defined CSS colors
-- Also see: https://www.quackit.com/css/css_color_codes.cfm
local CSS_COLORS = {
  black = "0;30",
  grey = M.csi("#808080"),
  silver = M.csi("#c0c0c0"),
  white = M.csi("#ffffff"),
  violet = M.csi("#EE82EE"),
  magenta = "0;35",
  fuchsia = M.csi("#FF00FF"),
  red = "0;31",
  purple = M.csi("#800080"),
  indigo = M.csi("#4B0082"),
  yellow = "0;33",
  gold = M.csi("#FFD700"),
  orange = M.csi("#FFA500"),
  chocolate = M.csi("#D2691E"),
  olive = M.csi("#808000"),
  green = "0;32",
  lime = M.csi("#00FF00"),
  teal = M.csi("#008080"),
  cyan = "0;36",
  aqua = M.csi("#00FFFF"),
  blue = "0;34",
  navy = M.csi("#000080"),
  slateblue = M.csi("#6A5ACD"),
  steelblue = M.csi("#4682B4"),
}

-- Retrieve ANSI/RGB color codes from vim's syntax highlighting group name.
--
-- Returns ANSI color codes (30, 35, etc) or RGB color codes (#808080, #FF00FF, etc).
--
--- @param hl string?
--- @param ground "fg"|"bg"
--- @return string?
M.hlcode = function(hl, ground)
  if strings.empty(hl) then
    return nil
  end

  assert(ground == "bg" or ground == "fg")

  local gui = vim.fn.has("termguicolors") > 0 and vim.o.termguicolors
  local family = gui and "gui" or "cterm"
  local pattern = gui and "^#[%l%d]+" or "^[%d]+$"
  local code =
    vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(hl)), ground, family) --[[@as string]]
  if string.find(code, pattern) then
    return code
  end
  return nil
end

-- Render `text` content with ANSI color name (yellow, red, blue, etc) and RGB color codes (#808080, #FF00FF, etc), or vim's syntax highlighting group.
-- Vim's syntax highlighting group has higher priority, but only working when it's provided.
--
-- Returns the rendered text content in terminal colors. For example:
-- \27[38;2;216;166;87mCTRL-U\27[0m  (CTRL-U)
--
--- @param text string   the text content to be rendered
--- @param name string      the ANSI color name or RGB color codes
--- @param hl string?       the highlighting group name
--- @return string
M.render = function(text, name, hl)
  local fgfmt = nil
  local fgcode = M.hlcode(hl, "fg")
  if type(fgcode) == "string" then
    fgfmt = M.csi(fgcode, "fg")
  elseif CSS_COLORS[name] then
    fgfmt = CSS_COLORS[name]
  else
    fgfmt = M.csi(name)
  end

  local fmt = nil
  local bgcode = M.hlcode(hl, "bg")
  if type(bgcode) == "string" then
    local bgcolor = M.csi(bgcode, "bg")
    fmt = string.format("%s;%s", fgfmt, bgcolor)
  else
    fmt = fgfmt
  end
  return string.format("[%sm%s[0m", fmt, text)
end

-- Erase the terminal colors from `text` content.
--
-- Returns the raw text content.
--
--- @param text string?
--- @return string?
M.erase = function(text)
  if type(text) ~= "string" then
    return text
  end
  local result, pos = text
    :gsub("\x1b%[%d+m\x1b%[K", "")
    :gsub("\x1b%[m\x1b%[K", "")
    :gsub("\x1b%[%d+;%d+;%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+;%d+m", "")
    :gsub("\x1b%[%d+;%d+m", "")
    :gsub("\x1b%[%d+m", "")
  return result
end

-- Helper function for the `render` API.
-- Render `text` content with pre-defined CSS color (see CSS_COLORS), or vim's syntax highlighting group (only if been provided).
do
  for name, code in pairs(CSS_COLORS) do
    --- @param text string
    --- @param hl string?
    --- @return string
    M[name] = function(text, hl)
      return M.render(text, name, hl)
    end
  end
end

return M
