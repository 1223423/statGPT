# statGPT

A simple RStudio addin to instantly transform broken English into working code, visualization, analysis, and more using OpenAI's GPT models. When activated, the addin will attempt to replace the highlighted text request into working code.

Attempts to provide context of previously written slightly minified code (currently only removing explicit comments & whitespace). If the code context is too large it will be truncated such that the total prompt is by default around ~2750 tokens, leaving the remainder of the 4096 tokens for the response.

Future updates will include more sophisticated minification via multiple prompting to allow for larger code contexts.

## Installation & Setup

Install the addin in RStudio:

```remotes::install_github("1223423/statGPT")```

Then set up the required temporary environment variables in RStudio:

```
Sys.setenv(OPENAI_API_KEY = "your api key here")    # API key
Sys.setenv(OPENAI_MODEL = "gpt-3.5-turbo")          # Model (optional; default: gpt-3.5-turbo)
Sys.setenv(OPENAI_TEMPERATURE = 1)                  # Temperature (optional; default 1)
Sys.setenv(STATGPT_DEBUG = 0) # (default : 0)       # Debug logging (optional; default: 0)
Sys.setenv(STATGPT_CTXLIM = 2750)                   # Input context limit (optional; default ~2750 tokens)
```
Alternatively, you can set persistent keys in your `.Renviron` file. Note that the temperature is left at the default of 1. Values close to 0 are nearly deterministic, whereas values close to 2 are more 'creative'.

## Demo

[demo.webm](https://user-images.githubusercontent.com/40682719/229134788-66de0b87-24bb-4a14-bb83-06b094d42918.webm)

## Questions

**Why is the code I got not working?** Dunno try asking it again differently lmao
