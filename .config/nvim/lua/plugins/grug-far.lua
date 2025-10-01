return {
  {
    'MagicDuck/grug-far.nvim',
    -- Note (lazy loading): grug-far.lua defers all it's requires so it's lazy by default
    -- additional lazy config to defer loading is not really needed...
    keys = {
      { '<leader>r', ':GrugFar ripgrep<CR>', desc = 'Search and [R]eplace', silent = true },
    },

    config = function()
      -- optional setup call to override plugin options
      -- alternatively you can set options with vim.g.grug_far = { ... }
      require('grug-far').setup {
        -- options, see Configuration section below
        -- there are no required options atm
        headerMaxWidth = 80,
      }
    end,
  },
}
