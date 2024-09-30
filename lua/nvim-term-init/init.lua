local M = {}

-- Variables to keep track of the terminal buffer and window
local my_term_buf = nil
local my_term_win = nil
local previous_layout = nil

-- Function to check if a buffer with a given name exists
local function get_buf_by_name(name)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf):match(name) then
			return buf
		end
	end
	return nil
end

-- Function to save the current window layout
local function save_layout()
	previous_layout = vim.fn.winrestcmd() -- Save the window layout as a command
end

-- Function to restore the previous window layout
local function restore_layout()
	if previous_layout then
		vim.cmd(previous_layout) -- Execute the saved window layout command
	end
end

-- Function to toggle `tt-setup` terminal
function M.toggle_tt_setup()
	-- Check if a buffer named 'tmux' exists
	my_term_buf = get_buf_by_name("tmux")

	-- If the terminal is already open, close it and restore layout
	if my_term_win and vim.api.nvim_win_is_valid(my_term_win) then
		vim.api.nvim_win_close(my_term_win, true)
		restore_layout() -- Restore previous layout
		my_term_win = nil
		vim.cmd('echo "Closed tt-setup terminal"') -- Debugging message
	else
		-- If the buffer exists, just open it full screen
		if my_term_buf then
			save_layout()
			vim.cmd("tabnew") -- Open a new tab to simulate full-screen effect
			vim.api.nvim_set_current_buf(my_term_buf)
			my_term_win = vim.api.nvim_get_current_win()
			vim.cmd("startinsert")
			vim.cmd('echo "Opened existing tt-setup terminal"') -- Debugging message
		else
			-- Save the current layout before opening a new terminal
			save_layout()

			-- Create a new terminal buffer if it doesn't exist
			my_term_buf = vim.api.nvim_create_buf(false, true) -- Create a new buffer
			vim.cmd("tabnew") -- Open in a new tab (simulate full-screen)
			vim.api.nvim_set_current_buf(my_term_buf) -- Set the new buffer as the current one
			vim.cmd("terminal tt-setup") -- Run the `tt-setup` command in the terminal

			-- Set the buffer name to 'tmux'
			vim.api.nvim_buf_set_name(my_term_buf, "tmux")

			-- Store the terminal window
			my_term_win = vim.api.nvim_get_current_win()

			-- Enter insert mode
			vim.cmd("startinsert")
			vim.cmd('echo "Opened new tt-setup terminal"') -- Debugging message
		end
	end
end

-- Setup function to initialize the plugin if needed
function M.setup()
	-- Any setup logic if necessary, otherwise leave empty
end

return M
