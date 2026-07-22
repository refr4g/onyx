--[[ ================================================================
  Neovim — oxocarbon theme · clangd LSP · lazy.nvim
  Migrated from ~/.vimrc (classic vim left intact as a fallback).
  Sections: options → keymaps → plugins → LSP/completion.
================================================================ ]]

vim.g.have_nerd_font = false -- ascii fallbacks; no Nerd Font required

-- leader kept as default "\" so your <leader><space> still works.
-- (swap to Space by uncommenting the next line)
-- vim.g.mapleader = " "

-------------------------------------------------- options
local opt = vim.opt
-- indentation (from your .vimrc: real tabs, width 4)
opt.tabstop = 4
opt.softtabstop = 0
opt.shiftwidth = 4
opt.expandtab = false
-- ui
opt.number = true
opt.showcmd = true
opt.showmatch = true
opt.wildmenu = true
opt.lazyredraw = true
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"
opt.scrolloff = 5
-- search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true
-- folding (from your .vimrc)
opt.foldenable = true
opt.foldlevelstart = 10
opt.foldmethod = "indent"
-- quality of life
opt.clipboard = "unnamedplus" -- yanks go to the system clipboard
opt.undofile = true           -- persistent undo across sessions
opt.splitright = true
opt.splitbelow = true
opt.hidden = true
opt.updatetime = 250
-- mouse off, so iTerm2 handles selection/copy-paste like your old vim
opt.mouse = ""

-------------------------------------------------- keymaps (preserved from .vimrc)
local map = vim.keymap.set
map("n", "<leader><space>", ":nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("n", "zf2j", "za", { desc = "Toggle fold" })
map("n", "<F5>", ":set nonumber<CR>", { silent = true, desc = "Hide line numbers" })
map("n", "<F3>", ":set number<CR>", { silent = true, desc = "Show line numbers" })
map("n", "<F6>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle file tree" })

-------------------------------------------------- bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
opt.rtp:prepend(lazypath)

-------------------------------------------------- plugins
require("lazy").setup({
  -- theme: real oxocarbon (matches your terminal)
  {
    "nyoom-engineering/oxocarbon.nvim",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("oxocarbon")
    end,
  },

  -- syntax via treesitter (replaces vim-cpp-enhanced-highlight)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- classic API (main branch dropped .configs.setup)
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "c", "cpp",                              -- uni C later
          "python", "php", "java",                 -- your main languages
          "javascript", "typescript", "tsx",       -- JS/TS
          "html", "css", "json",                   -- web
          "lua", "vim", "vimdoc", "bash", "markdown",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- file tree (replaces nerdtree) — text arrows, no Nerd Font needed
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require("nvim-tree").setup({
        renderer = {
          icons = {
            show = { file = false, folder = false, folder_arrow = true, git = false },
            glyphs = { folder = { arrow_closed = "▸", arrow_open = "▾" } },
          },
        },
      })
    end,
  },

  -- statusline (replaces airline) — icon-free, no powerline glyphs
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "auto",
          icons_enabled = false,
          section_separators = "",
          component_separators = "|",
        },
      })
    end,
  },

  -- LSP (clangd) + completion (replaces YouCompleteMe)
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      -- mason first, so its bin dir is on PATH before servers start
      require("mason").setup()

      -- auto-install language servers (portable across machines)
      local mason_tools = { "clangd", "pyright", "intelephense", "typescript-language-server", "jdtls" }
      local reg = require("mason-registry")
      local function ensure_installed()
        for _, name in ipairs(mason_tools) do
          local ok, pkg = pcall(reg.get_package, name)
          if ok and not pkg:is_installed() then pkg:install() end
        end
      end
      if reg.refresh then reg.refresh(ensure_installed) else ensure_installed() end

      -- completion
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(a) luasnip.lsp_expand(a.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      -- shared capabilities + enable each server (neovim 0.11+ native LSP API;
      -- nvim-lspconfig ships the default config for each of these).
      --   python=pyright  php=intelephense  js/ts=ts_ls  java=jdtls  c/c++=clangd
      local caps = require("cmp_nvim_lsp").default_capabilities()
      vim.lsp.config("*", { capabilities = caps })
      vim.lsp.enable({ "clangd", "pyright", "intelephense", "ts_ls", "jdtls" })

      -- LSP keymaps, active only in buffers that have a language server
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true }
          map("n", "gd", vim.lsp.buf.definition, o)
          map("n", "gr", vim.lsp.buf.references, o)
          map("n", "gi", vim.lsp.buf.implementation, o)
          map("n", "K", vim.lsp.buf.hover, o)
          map("n", "<leader>rn", vim.lsp.buf.rename, o)
          map("n", "<leader>ca", vim.lsp.buf.code_action, o)
          map("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, o)
          local prev = vim.diagnostic.jump and function() vim.diagnostic.jump({ count = -1, float = true }) end
            or vim.diagnostic.goto_prev
          local next = vim.diagnostic.jump and function() vim.diagnostic.jump({ count = 1, float = true }) end
            or vim.diagnostic.goto_next
          map("n", "[d", prev, o)
          map("n", "]d", next, o)
        end,
      })
    end,
  },
}, {
  ui = { icons = {} }, -- lazy UI without Nerd Font glyphs
})
