local cwd = vim.fn.getcwd()

describe("gentags.utils", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local utils = require("gentags.utils")
  require("gentags").setup()
  describe("[get_workspace]", function()
    it("test", function()
      local actual1 = utils.get_workspace()
      if actual1 then
        assert_eq(type(actual1), "string")
        assert_true(vim.fn.isdirectory(actual1) > 0)
      end
      local actual2 = utils.get_workspace(vim.fn.expand("~"))
      if actual2 then
        assert_eq(type(actual2), "string")
        assert_true(vim.fn.isdirectory(actual2) > 0)
      end
    end)
  end)
  describe("[get_filename]", function()
    it("test", function()
      vim.cmd([[edit README.md]])
      local actual1 = utils.get_filename()
      if actual1 then
        assert_eq(type(actual1), "string")
        assert_true(vim.fn.filereadable(actual1) > 0)
      end
    end)
  end)
  describe("[get_filetype]", function()
    it("test", function()
      vim.cmd([[edit README.md]])
      local actual1 = utils.get_filetype()
      if actual1 then
        assert_eq(type(actual1), "string")
      end
    end)
  end)
end)
