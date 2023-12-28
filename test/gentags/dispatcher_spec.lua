local cwd = vim.fn.getcwd()

describe("gentags.dispatcher", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local dispatcher = require("gentags.dispatcher")
  require("gentags").setup()

  describe("[load]", function()
    it("test", function()
      local ok, err = pcall(dispatcher.load)
    end)
  end)
  describe("[init]", function()
    it("test", function()
      local ok, err = pcall(dispatcher.init)
    end)
  end)
  describe("[update]", function()
    it("test", function()
      local ok, err = pcall(dispatcher.update)
    end)
  end)
  describe("[terminate]", function()
    it("test", function()
      local ok, err = pcall(dispatcher.terminate)
    end)
  end)
end)
