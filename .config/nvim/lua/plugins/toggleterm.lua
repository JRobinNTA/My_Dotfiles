return {
  'akinsho/toggleterm.nvim',
  version = '*',
  config = function()
    require('toggleterm').setup {
      size = 10,
      open_mapping = [[<C-\>]],
      start_in_insert = true, -- enter insert mode automatically
      insert_mappings = true, -- allow mappings in terminal mode
      terminal_mappings = true,
      hidden = true,
      direction = 'horizontal',
      persist_size = true,
      shade_terminals = true,
      shading_factor = 1,
    }
  end,
}
