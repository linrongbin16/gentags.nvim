local cwd = vim.fn.getcwd()

describe("gentags.configs", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local configs = require("gentags.configs")
  describe("[configs]", function()
    it("setup", function()
      local cfg = configs.setup()
      assert_eq(type(cfg), "table")
      local cfg2 = configs.get()
      assert_eq(type(cfg2), "table")
      assert_true(vim.deep_equal(cfg, cfg2))
    end)
  end)
end)
