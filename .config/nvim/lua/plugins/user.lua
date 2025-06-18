return {
	{
		"christoomey/vim-tmux-navigator",
		lazy = false,
	},

	-- disable bufferline
	{
		"akinsho/bufferline.nvim",
		enabled = false,
	},
	{
		"folke/tokyonight.nvim",
		opts = {
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons", -- or 'echasnovski/mini.icons'
		},
		opts = {},
	},
}
