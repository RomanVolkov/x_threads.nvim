# ~~Twitter~~ X Threads Formatter Neovim Plugin

## Overview

X Threads Formatter is a Neovim plugin that helps you easily convert selected text into Twitter/X thread-friendly format. The plugin automatically:

- Splits long text into multiple tweets
- Adds tweet numbering (e.g., `[1/3] [2/3] [3/3]`)
- Respects maximum tweet length

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  "https://github.com/RomanVolkov/x_threads.nvim",
  opts = {
    -- Optional: Customize max tweet length (default: 190)
    max_tweet_length = 190,
    -- Optional: Customize counter format (default: "[%d/%d] ")
    counter_format = "[%d/%d] ",
  },
}
```

## Usage

1. In Neovim, enter visual mode and select the text you want to convert to a thread
2. Press `<leader>tf` to format the selection into tweets
3. Or, you can bind `:XThreadsFormat` command to anything you like to be.

### Example

Before:
```
This is a very long piece of text that needs to be split into multiple tweets for a coherent thread. The plugin will automatically handle breaking the text into manageable chunks while preserving the overall meaning and readability.
```

After formatting:
```
[1/2] This is a very long piece of text that needs to be split into multiple tweets for a coherent thread.
[2/2] The plugin will automatically handle breaking the text into manageable chunks while preserving the overall meaning and readability.
```

## Configuration

You can customize the plugin by passing options to `setup()`:

```lua
require('x-threads').setup({
    -- Maximum characters per tweet (default: 190)
    max_tweet_length = 190,
    
    -- Custom format for tweet counters (default: "[%d/%d] ")
    counter_format = "[%d/%d] "
})
```

## Requirements

- Neovim 0.7+
- Lua

## License

MIT License

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on the GitHub repository.

