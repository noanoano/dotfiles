-- 改行の文字はアイコンじゃなくてそのまま表示
local function newline_label()
	local ff = vim.bo.fileformat
	if ff == "unix" then
		return "LF(\\n)"
	elseif ff == "dos" then
		return "CRLF(\\r\\n)"
	elseif ff == "mac" then
		return "CR(\\r)"
	else
		return ff -- 想定外の値が来たときのフォールバック
	end
end

return {
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup {
				options = {
					theme = "auto",
					section_separators = "",
					component_separators = "",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "selectioncount" },
					lualine_y = {
						"encoding",
						newline_label,
						"filetype"
					},
					lualine_z = { "location" },
				},
			}
		end,
	}
}

