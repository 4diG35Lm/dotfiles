Vim�UnDo� Kx���P<@�͒H���7y�s�&0$UPq�[       {   �                           eJ$    _�                     �        ����                                                                                                                                                                                                                                                                                                                            �           �           V        eGg    �   �   �           �   �   �            },�   �   �              end,�   �   �          	      end�   �   �          %        telescope.load_extension(ext)�   �   �          3      for _, ext in ipairs(opts.extensions_list) do�   �   �                -- load extensions�   �   �           �   �   �                telescope.setup(opts)�   �   �          +      local telescope = require "telescope"�   �   �          /      dofile(vim.g.base46_cache .. "telescope")�   �   �              config = function(_, opts)�   �   �              end,�   �   �          0      return require "plugins.configs.telescope"�   �   �              opts = function()�   �   �              end,�   �   �          5      require("core.utils").load_mappings "telescope"�   �   �              init = function()�   �   �              cmd = "Telescope",�   �   �          5    dependencies = "nvim-treesitter/nvim-treesitter",�   �   �          $    "nvim-telescope/telescope.nvim",�   �   �          {5��    �                      D                     �    �                      I                     �    �                      o                     �    �                      �                     �    �                      �                     �    �                      �                     �    �                                           �    �                                           �    �                      -                     �    �                      _                     �    �                      i                     �    �                      �                     �    �                      �                     �    �                      �                     �    �                                           �    �                                           �    �                                            �    �                      U                     �    �                      |                     �    �                      �                     �    �                      �                     �    �                      �                     5�_�                     �        ����                                                                                                                                                                                                                                                                                                                            �           �                   eJ#    �   �   �        #  {   %#    "nvim-telescope/telescope.nvim",   6#    dependencies = "nvim-treesitter/nvim-treesitter",   #    cmd = "Telescope",   #    init = function()   6#      require("core.utils").load_mappings "telescope"   	#    end,   #    opts = function()   1#      return require "plugins.configs.telescope"   	#    end,   #    config = function(_, opts)   0#      dofile(vim.g.base46_cache .. "telescope")   ,#      local telescope = require "telescope"   #      telescope.setup(opts)   #   #      -- load extensions   4#      for _, ext in ipairs(opts.extensions_list) do   &#        telescope.load_extension(ext)   
#      end   	#    end,   #  },   #5��    �                      D                     �    �                      H                     �    �                      m                     �    �                      �                     �    �                      �                     �    �                      �                     �    �                                           �    �                                           �    �                      %                     �    �                      V                     �    �                      _                     �    �                      ~                     �    �                      �                     �    �                      �                     �    �                      �                     �    �                      �                     �    �                                           �    �                      D                     �    �                      j                     �    �                      t                     �    �                      }                     �    �                      �                     5��