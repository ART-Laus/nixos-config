{
  home.file.".config/nvim/lua/plugins/autopairs.lua".text = ''
    return {
      "windwp/nvim-autopairs",
      config = function()
        local npairs = require("nvim-autopairs")

        npairs.setup({
          check_ts = true,
          ts_config = {
            lua = { "string" },
            javascript = { "template_string" },
            java = false,
          },
          disable_filetype = { "TelescopePrompt", "vim" },
          fast_wrap = {
            map = "<M-e>",
            chars = { "{", "[", "(", '"', "'" },
            pattern = [=[[%'%"%)%>%]%)%}%,]]=],
            offset = 0,
            end_key = "$",
            keys = "qwertyuiopzxcvbnmasdfghjkl",
            check_comma = true,
            highlight = "PmenuSel",
            highlight_grey = "LineNr",
          },
        })

        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        local cmp = require("cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
        npairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
      end
    }
  '';
}