{
  inputs,
  pkgs,
  ...
}: let
  # from github.com/mrcjkb/kickstart-nix.nvim
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };
in {
  # Import all your configuration modules here
  imports = [
    ./plugins.nix
    ./keymaps.nix
    ./options.nix
  ];

  config = {
    colorschemes.catppuccin.enable = true;
    globals.mapleader = " ";

    clipboard = {
      register = "unnamedplus";
      providers.xclip.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      hover-nvim

      # gh:ThePrimeagen/harpoon/tree/harpoon2
      (mkNvimPlugin inputs.harpoon "harpoon")

      # gh:xiyaowong/transparent.nvim
      (mkNvimPlugin inputs.transparent-nvim "transparent.nvim")
    ];

    extraPackages = with pkgs; [
      alejandra
      xclip
    ];

    autoCmd = [
      # Highlight on Yank
      {
        event = ["TextYankPost"];
        pattern = ["*"];
        group = "YankHighlight";
        callback = {
          __raw = ''
            function()
              vim.highlight.on_yank({
                higroup = 'IncSearch',
                timeout = 40,
              })
            end
          '';
        };
      }
    ];

    autoGroups = {
      YankHighlight.clear = true;
    };

    extraFiles = {
      "ftplugin/nix.lua" =
        /*
        lua
        */
        ''
          vim.cmd("setlocal tabstop=2 softtabstop=2 shiftwidth=2")
        '';
    };

    # HACK/* lua */
    extraConfigLuaPost =
      /*
      lua
      */
      ''
        -- NOTE indent-blankline multicolor
        local ibl_high = { 'ctpRed', 'ctpPeach', 'ctpYellow', 'ctpGreen', 'ctpSky', 'ctpBlue', 'ctpMauve' }
        require('ibl.hooks').register(require('ibl.hooks').type.HIGHLIGHT_SETUP, function()
          local ibl_high_colors = {'#F38BA8', '#FAB387', '#F9E2AF', '#A6E3A1', '#89DCEB', '#89B4FA', '#CBA6F7'}
          for i, name in ipairs(ibl_high) do
            vim.api.nvim_set_hl(0, name, { fg = ibl_high_colors[i] })
          end
        end)
        require('ibl').setup({
          indent = { highlight = ibl_high, char = '┊' },
          scope = { enabled = false },
          viewport_buffer = { min = 128, max = 512 },
        })



        -- NOTE hover.nvim
        require("hover").setup {
          init = function()
            require("hover.providers.lsp")
            -- require('hover.providers.man')
            -- require('hover.providers.dictionary')
          end,
          preview_opts = {
            border = 'single'
          },
          -- Whether the contents of a currently open hover window should be moved
          -- to a :h preview-window when pressing the hover keymap.
          preview_window = false,
          title = false,
        }
        vim.keymap.set("n", "K", require("hover").hover, {desc = "hover.nvim"})
        vim.keymap.set("n", "gK", require("hover").hover_select, {desc = "hover.nvim (select)"})



        -- NOTE harpoon2
        require("harpoon"):setup()
      '';
  };
}
