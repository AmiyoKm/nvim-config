require('config.options')
require('config.keybinds')
require('config.lazy')


vim.cmd [[
  autocmd VimEnter * if argc() == 0 | Alpha | endif
]]

