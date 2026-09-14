{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.neovim.extraLuaConfig = ''
    vim.g.mapleader = " "
    vim.g.maplocalleader = " "
  '';

  home.file.".config/nvim/lua/init.lua".text = ''
    -- init.lua
    vim.cmd("colorscheme artgreendream")
    require("options")
    require("keymaps")
    require("autocmds")
    require("lazy")
  '';

  home.file.".config/nvim/lua/colors/artgreendream.lua".text = ''
    local colors = {
      bg        = "NONE",
      fg        = "${c.primary}",
      lavender  = "${c.secondary}",
      cyan      = "${c.accentBlue}",
      yellow    = "${c.warning}",
      blue      = "${c.accentBlue}",
      pink      = "${c.error}",
      turquoise = "${c.accentBlue}",
      red       = "${c.error}",
      gray      = "${c.comment}",
      darkgray  = "${c.bgAlt}",
    }

    local hi = function(group, opts)
      vim.api.nvim_set_hl(0, group, opts)
    end

    vim.cmd("highlight clear")

    hi("Normal",        { fg = colors.fg, bg = colors.bg })
    hi("Comment",       { fg = colors.gray, italic = true })
    hi("LineNr",        { fg = "${c.primary}" })
    hi("CursorLineNr",  { fg = colors.yellow, bold = true })
    hi("CursorLine",    { bg = colors.darkgray })
    hi("Visual",        { bg = colors.turquoise, fg = "#000000", bold = true })
    hi("Search",        { fg = "#000000", bg = colors.yellow, bold = true })
    hi("IncSearch",     { fg = "#000000", bg = colors.pink, bold = true })
    hi("StatusLine",    { fg = colors.fg, bg = "${c.bg}" })
    hi("StatusLineNC",  { fg = colors.gray, bg = "${c.bg}" })

    hi("Constant",      { fg = colors.pink })
    hi("String",        { fg = colors.pink })
    hi("Number",        { fg = colors.blue })
    hi("Boolean",       { fg = colors.blue })
    hi("Identifier",    { fg = colors.fg })
    hi("Function",      { fg = colors.cyan, bold = true })
    hi("Statement",     { fg = colors.lavender })
    hi("Keyword",       { fg = colors.lavender, italic = true })
    hi("Operator",      { fg = colors.cyan })
    hi("Type",          { fg = colors.yellow, bold = true })
    hi("StorageClass",  { fg = colors.yellow })
    hi("Structure",     { fg = colors.yellow })
    hi("Special",       { fg = colors.cyan })
    hi("PreProc",       { fg = colors.lavender })
    hi("Todo",          { fg = "#000000", bg = colors.yellow, bold = true })

    hi("@variable",     { fg = colors.fg })
    hi("@variable.builtin", { fg = colors.cyan, italic = true })
    hi("@function",     { fg = colors.cyan, bold = true })
    hi("@function.builtin", { fg = colors.cyan, italic = true })
    hi("@method",       { fg = colors.cyan })
    hi("@field",        { fg = colors.fg })
    hi("@property",     { fg = colors.yellow })
    hi("@parameter",    { fg = colors.fg, italic = true })
    hi("@keyword",      { fg = colors.lavender, italic = true })
    hi("@keyword.function", { fg = colors.lavender })
    hi("@type",         { fg = colors.yellow, bold = true })
    hi("@type.builtin", { fg = colors.yellow, italic = true })
    hi("@constant",     { fg = colors.pink })
    hi("@constant.builtin", { fg = colors.pink, italic = true })
    hi("@number",       { fg = colors.blue })
    hi("@boolean",      { fg = colors.blue })
    hi("@string",       { fg = colors.pink })
    hi("@comment",      { fg = colors.gray, italic = true })

    hi("DiagnosticError", { fg = colors.red })
    hi("DiagnosticWarn",  { fg = colors.yellow })
    hi("DiagnosticInfo",  { fg = colors.lavender })
    hi("DiagnosticHint",  { fg = colors.cyan })

    hi("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
    hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = colors.yellow })
    hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = colors.lavender })
    hi("DiagnosticUnderlineHint",  { undercurl = true, sp = colors.cyan })

    hi("DiffAdd",       { fg = "${c.success}" })
    hi("DiffChange",    { fg = colors.cyan })
    hi("DiffDelete",    { fg = colors.red })
    hi("DiffText",      { fg = colors.yellow })
  '';
}