local M = {}

function M.setup()
	-- Create a persistent terminal buffer, initially nil
	local my_term_buf = nil
	local my_term_win = nil

	-- Function to initialize the terminal if not already created
	local function initialize_my_term()
		if not my_term_buf or not vim.api.nvim_buf_is_valid(my_term_buf) then
			print("Initializing my_term instance") -- Debugging message
			my_term_buf = vim.api.nvim_create_buf(false, true) -- Create a new terminal buffer

			-- Open terminal and run the 'tt-setup' command
			vim.fn.termopen("tt-setup", {
				on_exit = function()
					print("tt-setup exited")
				end,
			})

			-- Optionally create a floating window for the terminal
			my_term_win = vim.api.nvim_open_win(my_term_buf, true, {
				relative = "editor",
				width = 80,
				height = 20,
				row = 10,
				col = 10,
				style = "minimal",
			})
		end
	end

	-- Function to toggle the terminal
	function M.toggle_my_term()
		if my_term_win and vim.api.nvim_win_is_valid(my_term_win) then
			print("Toggling terminal") -- Debugging message
			vim.api.nvim_win_close(my_term_win, true)
			my_term_win = nil
		else
			print("my_term is nil, initializing") -- Debugging message
			initialize_my_term()
		end
	end

	-- Function to start 'tt-setup' in Neovim's terminal on startup
	local function start_tt_setup_in_term()
		initialize_my_term()

		-- Optionally hide the terminal after running tt-setup
		vim.defer_fn(function()
			print("Hiding the terminal after tt-setup") -- Debugging message
			if my_term_win and vim.api.nvim_win_is_valid(my_term_win) then
				vim.api.nvim_win_close(my_term_win, true)
				my_term_win = nil
			end
		end, 100) -- Delay to ensure tt-setup runs
	end

	-- Automatically run 'tt-setup' in terminal on Neovim startup if the temp file exists
	vim.api.nvim_create_autocmd("VimEnter", {
		callback = function()
			-- Check if the temp file exists
			local file = io.open("/tmp/nvim_first_run", "r")
			if file ~= nil then
				io.close(file)
				print("Starting tt-setup from temp file") -- Debugging message
				start_tt_setup_in_term()
				-- Remove the temp file after the first run
				os.remove("/tmp/nvim_first_run")
			end
		end,
	})
end

return M
