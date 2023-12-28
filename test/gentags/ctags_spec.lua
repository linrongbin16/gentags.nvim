local cwd = vim.fn.getcwd()

describe("gentags.ctags", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local ctags = require("gentags.ctags")
  require("gentags").setup()
  describe("[run]", function()
    it("test", function() end)
  end)
end)
