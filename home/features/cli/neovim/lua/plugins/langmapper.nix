{
  home.file.".config/nvim/lua/plugins/langmapper.lua".text = ''
    return {
      "gen740/langmapper.nvim",
      config = function()
        require('langmapper').setup()
      end
    }
  '';
}