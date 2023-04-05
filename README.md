# statGPT

A simple RStudio addin to instantly transform broken English into working code, visualization, analysis, and more using OpenAI's GPT models. When activated, the addin will attempt to replace the highlighted text request with working code.

Attempts to provide context of previously written slightly minified code (currently only removing explicit comments & whitespace). If the code context is too large it will be truncated such that the total prompt is by default around ~2750 tokens, leaving the remainder of the 4096 tokens (assuming gpt-3-turbo) for the response. Precise truncation is done via Open AI's ['tiktoken'](https://github.com/openai/tiktoken) library via linked python code. Python > 3.8 is required for this.

Future updates will include more sophisticated context compression.

## Installation & Setup

Install the addin in RStudio:

```remotes::install_github("1223423/statGPT")```

Then set up the required temporary environment variables in RStudio:

```
Sys.setenv(OPENAI_API_KEY = "your api key here")    # API key
Sys.setenv(OPENAI_MODEL = "gpt-3.5-turbo")          # Model (optional; default: gpt-3.5-turbo)
Sys.setenv(OPENAI_TEMPERATURE = 0.25)               # Temperature (optional; default 0.25)
Sys.setenv(STATGPT_DEBUG = 0)                       # Debug logging (optional; default: 0)
Sys.setenv(STATGPT_CTXLIM = 2750)                   # Input context limit (optional; default ~2750 tokens)
```
Alternatively, you can set persistent keys in your `.Renviron` file.

## Demo

[demo.webm](https://user-images.githubusercontent.com/40682719/229134788-66de0b87-24bb-4a14-bb83-06b094d42918.webm)

## Dependencies

statGPT requires Open AI's `tiktoken` and therefore Python 3.8 or higher. It also uses the R packages  `reticulate`, `httr`, and `jsonlite`.

## Questions

**What does OPENAI_TEMPERATURE do?** Temperature ranges 0-2 and controls the level of randomness and creativity in output, with values at or close to 0 being nearly deterministic. Default left at 0.25.

**What does STATGPT_CTXLIM do?** Each OpenAI model comes with a token limitation shared between input and response. For instance, `gpt-3.5-turbo` has a limit of 4096 tokens. CTXLIM puts an upper bound on the input, by default 2750 tokens, which leaves ~1346 tokens for the response, however, even using OpenAI's tokenizer this can be off by a few tokens (see: ['openai-cookbook'](https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb)). If you're using gpt-4 you'd want to to set this limit to something much higher.

**Why is the code I got not working?** Dunno try asking it again differently lmao
