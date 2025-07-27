require 'core.keymaps'
require 'core.options'

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)
require('lazy').setup {
  require 'plugins.alpha',
  require 'plugins.autopairs',
  require 'plugins.blink',
  require 'plugins.conform',
  require 'plugins.debug',
  require 'plugins.gitsigns',
  require 'plugins.indent_line',
  require 'plugins.lazydev',
  require 'plugins.lint',
  require 'plugins.lspconfig',
  require 'plugins.lualine',
  require 'plugins.mini',
  require 'plugins.neo-tree',
  require 'plugins.noice',
  require 'plugins.nvim-treesitter',
  require 'plugins.telescope',
  require 'plugins.theme',
  require 'plugins.toggleterm',
  require 'plugins.which-key',
}
