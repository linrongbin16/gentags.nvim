local cwd = vim.fn.getcwd()

describe("gentags.ctags", function()
  local assert_eq = assert.is_equal
  local assert_true = assert.is_true
  local assert_false = assert.is_false

  before_each(function()
    vim.api.nvim_command("cd " .. cwd)
    vim.opt.swapfile = false
    vim.cmd([[edit README.md]])
  end)

  local github_actions = os.getenv("GITHUB_ACTIONS") == "true"

  local ctags = require("gentags.ctags")
  local dispatcher = require("gentags.dispatcher")
  require("gentags").setup({
    debug = {
      enable = true,
      file_log = true,
    },
  })
  describe("[load]", function()
    it("test", function()
      local ok, err = pcall(ctags.load, dispatcher.get_context())
    end)
  end)
  describe("[_write]", function()
    it("workspace", function()
      local ok, result = pcall(ctags._write, dispatcher.get_context())
      print(
        string.format(
          "_write-workspace ok:%s, result:%s\n",
          vim.inspect(ok),
          vim.inspect(result)
        )
      )
      if ok then
        assert_eq(type(result), "table")
        assert_eq(type(result.cmds), "table")
        assert_eq(type(result.system_obj), "table")
      end
    end)
    it("singlefile", function()
      vim.cmd([[edit $HOME/test.txt]])
      local ok, result = pcall(ctags._write, dispatcher.get_context())
      print(
        string.format(
          "_write-singlefile ok:%s, result:%s\n",
          vim.inspect(ok),
          vim.inspect(result)
        )
      )
      if ok then
        assert_eq(type(result), "table")
        assert_eq(type(result.cmds), "table")
        assert_eq(type(result.system_obj), "table")
      end
    end)
  end)
  describe("[_append]", function()
    it("test", function()
      local ok, result_or_err = pcall(ctags._append, dispatcher.get_context())
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
end)
