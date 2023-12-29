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
  local dispatcher = require("gentags.dispatcher")
  require("gentags").setup()
  describe("[load]", function()
    it("test", function()
      local ok, err = pcall(ctags.load, dispatcher.get_context())
    end)
  end)
  describe("[init]", function()
    it("test", function()
      local ok, err = pcall(ctags.init, dispatcher.get_context())
    end)
  end)
  describe("[update]", function()
    it("test", function()
      local ok, err = pcall(ctags.update, dispatcher.get_context())
    end)
  end)
  describe("[terminate]", function()
    it("test", function()
      local ok, err = pcall(ctags.terminate, dispatcher.get_context())
    end)
  end)
  describe("[utils]", function()
    it("_close_file", function()
      local fp = io.open("test.txt", "w+")
      ctags._close_file(fp)
    end)
    it("_dump_file", function()
      ctags._dump_file("README.md", "test.txt")
      if vim.fn.filereadable("test.txt") > 0 then
        vim.cmd([[!rm test.txt]])
      end
    end)
  end)
end)
