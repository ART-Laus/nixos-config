{
  home.file.".config/nvim/lua/plugins/lspsaga.lua".text = ''
    return {
      "nvimdev/lspsaga.nvim",
      dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "kyazdani42/nvim-web-devicons",
      },
      config = function()
        require("lspsaga").setup({})
      end
    }
  '';
}