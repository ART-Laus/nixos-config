-- colors/artgreendream.lua
-- AMOLED "Art Green Dream" theme with прозрачным фоном
-- Палитра под твой зелёный фон, с учётом Treesitter и LSP

local colors = {
  bg        = "NONE",      -- прозрачный фон
  fg        = "#66FF99",   -- основной текст (зелёный)
  lavender  = "#C4A0FF",   -- ключевые слова
  cyan      = "#88ddff",   -- функции / методы / операторы
  yellow    = "#FFD966",   -- классы / типы / предупреждения
  blue      = "#3399FF",   -- числа / булевы
  pink      = "#FF66CC",   -- строки
  turquoise = "#009999",   -- визуальное выделение
  red       = "#FF3355",   -- ошибки
  gray      = "#3D6655",   -- комментарии
  darkgray  = "#0D3322",   -- курсор, выделение строки
}

local hi = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Очистка
vim.cmd("highlight clear")

-- === Основное UI ===
hi("Normal",        { fg = colors.fg, bg = colors.bg })
hi("Comment",       { fg = colors.gray, italic = true })
hi("LineNr",        { fg = "#2FAA77" })
hi("CursorLineNr",  { fg = colors.yellow, bold = true })
hi("CursorLine",    { bg = colors.darkgray })
hi("Visual",        { bg = colors.turquoise, fg = "#000000", bold = true })
hi("Search",        { fg = "#000000", bg = colors.yellow, bold = true })
hi("IncSearch",     { fg = "#000000", bg = colors.pink, bold = true })
hi("StatusLine",    { fg = colors.fg, bg = "#111111" })
hi("StatusLineNC",  { fg = colors.gray, bg = "#111111" })

-- === Syntax ===
hi("Constant",      { fg = colors.pink })        -- литералы
hi("String",        { fg = colors.pink })        -- строки
hi("Number",        { fg = colors.blue })      -- числа
hi("Boolean",       { fg = colors.blue })      -- булевы
hi("Identifier",    { fg = colors.fg })          -- переменные
hi("Function",      { fg = colors.cyan, bold = true }) -- функции/методы
hi("Statement",     { fg = colors.lavender })    -- return, if, for
hi("Keyword",       { fg = colors.lavender, italic = true })
hi("Operator",      { fg = colors.cyan })        -- операторы
hi("Type",          { fg = colors.yellow, bold = true }) -- классы, типы
hi("StorageClass",  { fg = colors.yellow })
hi("Structure",     { fg = colors.yellow })
hi("Special",       { fg = colors.cyan })
hi("PreProc",       { fg = colors.lavender })
hi("Todo",          { fg = "#000000", bg = colors.yellow, bold = true })

-- === Treesitter ===
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

-- === LSP Diagnostics ===
hi("DiagnosticError", { fg = colors.red })
hi("DiagnosticWarn",  { fg = colors.yellow })
hi("DiagnosticInfo",  { fg = colors.lavender })
hi("DiagnosticHint",  { fg = colors.cyan })

hi("DiagnosticUnderlineError", { undercurl = true, sp = colors.red })
hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = colors.yellow })
hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = colors.lavender })
hi("DiagnosticUnderlineHint",  { undercurl = true, sp = colors.cyan })

-- === Diff / Git ===
hi("DiffAdd",       { fg = "#00FF88" })
hi("DiffChange",    { fg = colors.cyan })
hi("DiffDelete",    { fg = colors.red })
hi("DiffText",      { fg = colors.yellow })

return colors