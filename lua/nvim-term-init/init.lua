local M = {}

-- Create a persistent terminal instance, initially nil
local my_term_bufnr = nil
local previous_buf = nil -- To keep track of the previous buffer
local tt_term_job_id = nil -- To keep track of the terminal job ID

-- Function to initialize the terminal if not already created
local function initialize_my_term()
	if not my_term_bufnr or not vim.api.nvim_buf_is_valid(my_term_bufnr) then
		print("Initializing my_term instance") -- Debugging message
		-- Create a terminal buffer running the 'tt-setup' command
		my_term_bufnr = vim.api.nvim_create_buf(false, true) -- Create a hidden buffer
		vim.api.nvim_open_win(my_term_bufnr, true, { relative = "editor", width = 80, height = 20, row = 10, col = 10 }) -- Open a floating window
		tt_term_job_id = vim.fn.termopen("tt-setup") -- Start the terminal command
	end
end

-- Function to toggle between the terminal and the previous buffer
function M.toggle_my_term()
	-- Get the current buffer number
	local current_buf = vim.api.nvim_get_current_buf()

	-- Check if the terminal has been initialized
	if my_term_bufnr and vim.api.nvim_buf_is_valid(my_term_bufnr) then
		-- If the terminal buffer is open and we are currently in it, switch back to the previous buffer
		if current_buf == my_term_bufnr then
			if previous_buf and vim.api.nvim_buf_is_valid(previous_buf) then
				vim.api.nvim_set_current_buf(previous_buf) -- Switch to the previous buffer
			end
		else
			-- Otherwise, save the current buffer as the previous buffer and toggle the terminal
			previous_buf = current_buf
			vim.api.nvim_set_current_buf(my_term_bufnr) -- Switch to the terminal buffer
		end
	else
		-- If the terminal hasn't been initialized, initialize and open it
		print("my_term is nil, initializing") -- Debugging message
		initialize_my_term()
		previous_buf = current_buf -- Save the current buffer as the previous buffer
	end
end

-- Function to start 'tt-setup' in the built-in terminal on startup
function M.start_tt_setup_in_term()
	initialize_my_term() -- Ensure the terminal is initialized
	if my_term_bufnr and vim.api.nvim_buf_is_valid(my_term_bufnr) then
		print("Opening terminal for tt-setup") -- Debugging message

		-- Optionally hide the terminal after running tt-setup
		vim.defer_fn(function()
			if vim.api.nvim_buf_is_valid(my_term_bufnr) then
				print("Hiding the terminal after tt-setup") -- Debugging message
				vim.api.nvim_buf_delete(my_term_bufnr, { force = true }) -- Close the terminal
				my_term_bufnr = nil
			end
		end, 500) -- Small delay to ensure tt-setup runs
	else
		print("Failed to initialize my_term") -- Debugging message
	end
end

-- Function to automatically run 'tt-setup' in the built-in terminal on Neovim startup if the temp file exists
function M.auto_run_tt_setup()
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			local file = io.open("/tmp/nvim_first_run", "r")
			if file ~= nil then
				io.close(file)
				-- Start the terminal and store the instance
				print("Starting tt-setup from temp file") -- Debugging message
				M.start_tt_setup_in_term()
				-- Remove the temp file after the first run
				os.remove("/tmp/nvim_first_run")
			end
		end,
	})
end

return M
