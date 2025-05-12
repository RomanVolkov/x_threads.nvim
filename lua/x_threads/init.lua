local M = {}

local config = {
	max_tweet_length = 190,
	counter_format = "[%d/%d] ",
}

local function split_into_tweets(text)
	text = text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")

	local sentences = {}
	for sentence in text:gmatch("[^%.!?]+[%.!?]") do
		local trimmed_sentence = sentence:gsub("^%s+", ""):gsub("%s+$", "")
		sentences[#sentences + 1] = trimmed_sentence
	end

	local tweets = {}
	local current_tweet = ""

	for _, sentence in ipairs(sentences) do
		local tweet_length_with_counter = config.max_tweet_length - #string.format(config.counter_format, 1, 1)
		local potential_tweet = (current_tweet ~= "" and current_tweet .. " " or "") .. sentence

		if #potential_tweet > tweet_length_with_counter then
			if current_tweet ~= "" then
				tweets[#tweets + 1] = current_tweet
			end
			current_tweet = sentence
		else
			current_tweet = potential_tweet
		end
	end

	if current_tweet ~= "" then
		tweets[#tweets + 1] = current_tweet
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

-- local test =
-- 	"This is a very long piece of text that needs to be split into multiple tweets for a coherent thread. The plugin will automatically handle breaking the text into manageable chunks while preserving the overall meaning and readability. This is a very long piece of text that needs to be split into multiple tweets for a coherent thread. The plugin will automatically handle breaking the text into manageable chunks while preserving the overall meaning and readability."
--
-- local res = split_into_tweets(test)
-- print(res)
--
-- vim.api.nvim_buf_set_lines(0, 198, 198 + 1, false, res)

return M
