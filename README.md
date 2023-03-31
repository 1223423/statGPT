# statGPT

A extreme barebones RStudio addin to instantly transform broken nonsense English into working code, visualization, analysis, and more using OpenAI's GPT models. When acticated, the OpenAI model will attempt to replace the highlighted text request into working code. The addin attempts to provide context by also providing code already written before the highlighted line, subject to token limitations. So it's best to use it in smaller, isolated documents. I plan to add a context compression layer that should allow more code context while sparing tokens.

## Installation & Setup

Install the addin in RStudio:

```remotes::install_github("1223423/statGPT")```

Then set up the required temporary environment variables in RStudio:

```
Sys.setenv(OPENAI_API_KEY = "<your api key here>")
Sys.setenv(OPENAI_MODEL = "gpt-3.5-turbo")
Sys.getenv(STATGPT_DEBUG = 0) #(optional)
```

Alternatively, you can set persistent keys in your `.Renviron` file.

## Demo

[demo.webm](https://user-images.githubusercontent.com/40682719/229134788-66de0b87-24bb-4a14-bb83-06b094d42918.webm)

## I didn't get working code

Dunno try asking it again differently lmao
