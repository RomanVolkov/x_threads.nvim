local M = {}

local config = {
	max_tweet_length = 195, -- Maximum characters per tweet
	counter_format = "[%d/%d] ", -- Format for the tweet counter
}

local function split_into_tweets(text)
	text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	local tweets = {}
	local current_tweet = ""
	local remaining_text = text

	while #remaining_text > 0 do
		local next_end = nil
		local next_pattern = nil

		for _, pattern in ipairs({ "%.%s", "!%s", "?%s", "%.%.%.%s", "%.$", "!$", "?$", "%.%.%.$" }) do
			local pos = remaining_text:find(pattern)
			if pos and (next_end == nil or pos < next_end) then
				next_end = pos
				next_pattern = pattern
			end
		end

		if next_end == nil then
			if #current_tweet + #remaining_text <= config.max_tweet_length - 7 then
				current_tweet = current_tweet .. remaining_text
				remaining_text = ""
			else
				local space_pos = nil
				local remaining_length = config.max_tweet_length - #current_tweet - 7 -- accounting for counter

				if #current_tweet > 0 then
					space_pos = remaining_text:sub(1, remaining_length):find("%s[^%s]*$")
				else
					remaining_length = config.max_tweet_length - 7 -- accounting for counter
					space_pos = remaining_text:sub(1, remaining_length):find("%s[^%s]*$")

					if space_pos == nil then
						space_pos = remaining_length
					end
				end

				if space_pos then
					current_tweet = current_tweet .. remaining_text:sub(1, space_pos)
					table.insert(tweets, current_tweet)
					current_tweet = ""
					remaining_text = remaining_text:sub(space_pos + 1):gsub("^%s+", "")
				else
					table.insert(tweets, current_tweet .. remaining_text:sub(1, remaining_length))
					current_tweet = ""
					remaining_text = remaining_text:sub(remaining_length + 1):gsub("^%s+", "")
				end
			end
		else
			local sentence = remaining_text:sub(1, next_end + #next_pattern - 1)

			if #current_tweet + #sentence <= config.max_tweet_length - 7 then
				current_tweet = current_tweet .. sentence
				remaining_text = remaining_text:sub(next_end + #next_pattern):gsub("^%s+", "")
			else
				if #current_tweet > 0 then
					table.insert(tweets, current_tweet)
					current_tweet = sentence
					remaining_text = remaining_text:sub(next_end + #next_pattern):gsub("^%s+", "")
				else
					local space_pos = nil
					local remaining_length = config.max_tweet_length - 7 -- accounting for counter
					space_pos = sentence:sub(1, remaining_length):find("%s[^%s]*$")

					if space_pos and space_pos > 0 then
						current_tweet = sentence:sub(1, space_pos)
						table.insert(tweets, current_tweet)
						current_tweet = ""
						remaining_text = sentence:sub(space_pos + 1):gsub("^%s+", "")
							.. remaining_text:sub(next_end + #next_pattern)
					else
						table.insert(tweets, sentence:sub(1, remaining_length))
						current_tweet = ""
						remaining_text = sentence:sub(remaining_length + 1):gsub("^%s+", "")
							.. remaining_text:sub(next_end + #next_pattern)
					end
				end
			end
		end

		if #current_tweet > 0 and #remaining_text == 0 then
			table.insert(tweets, current_tweet)
		end
	end

	return tweets
end

local function format_tweets_with_counters(tweets)
	local formatted_tweets = {}
	local total = #tweets

	for i, tweet in ipairs(tweets) do
		local counter = string.format(config.counter_format, i, total)
		table.insert(formatted_tweets, counter .. tweet)
	end

	return formatted_tweets
end

function M.format_x_threads()
	local start_pos = vim.fn.getpos("'<")
	local end_pos = vim.fn.getpos("'>")

	local start_line = start_pos[2] - 1
	local start_col = start_pos[3] - 1
	local end_line = end_pos[2] - 1
	local end_col = end_pos[3]

	local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)

	if #lines == 1 then
		local line = lines[1]
		local selection = line:sub(start_col + 1, end_col)
		lines = { selection }
	else
		if start_col > 0 then
			lines[1] = lines[1]:sub(start_col + 1)
		end

		if end_col > 0 then
			lines[#lines] = lines[#lines]:sub(1, end_col)
		end
	end

	local combined_text = table.concat(lines, " ")
	local tweets = split_into_tweets(combined_text)
	local formatted_tweets = format_tweets_with_counters(tweets)

	vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, formatted_tweets)

	vim.api.nvim_echo({ { "Formatted text into " .. #formatted_tweets .. " tweets", "Normal" } }, true, {})
end

function M.setup(opts)
	if opts then
		for k, v in pairs(opts) do
			config[k] = v
		end
	end

	vim.api.nvim_create_user_command("XThreadsFormat", function()
		M.format_x_threads()
	end, { range = true })

	vim.api.nvim_set_keymap("v", "<leader>tf", ":XThreadsFormat<CR>", { noremap = true, silent = true })

	return M
end

return M
