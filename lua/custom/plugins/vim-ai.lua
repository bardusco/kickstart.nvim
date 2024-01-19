-- " ============================================================================
-- " VIM-AI {{{
-- " ============================================================================
-- " :AI
-- " - engine: complete | chat - see how to configure chat engine in the section below
-- " - options: openai config (see https://platform.openai.com/docs/api-reference/completions)
-- " - options.request_timeout: request timeout in seconds
-- " - options.enable_auth: enable authorization using openai key
-- " - options.selection_boundary: seleciton prompt wrapper (eliminates empty responses, see #20)
-- " - ui.paste_mode: use paste mode (see more info in the Notes below)

vim.g.vim_ai_debug = "1"
vim.g.vim_ai_debug_log_file = "/home/bardusco/.vim_ai_debug_log_file.log"
vim.g.vim_ai_complete = {
  engine = "complete",
  options = {
    model = "gpt-3.5-turbo-instruct",
    endpoint_url = "https://api.openai.com/v1/completions",
    max_tokens = 1000,
    temperature = 0.1,
    request_timeout = 20,
    enable_auth = 1,
    selection_boundary = "#####",
  },
  ui = {
    paste_mode = 1,
  },
}

-- " :AIEdit
-- " - engine: complete | chat - see how to configure chat engine in the section below
-- " - options: openai config (see https://platform.openai.com/docs/api-reference/completions)
-- " - options.request_timeout: request timeout in seconds
-- " - options.enable_auth: enable authorization using openai key
-- " - options.selection_boundary: seleciton prompt wrapper (eliminates empty responses, see #20)
-- " - ui.paste_mode: use paste mode (see more info in the Notes below)
vim.g.vim_ai_edit = {
  engine = "complete",
  options = {
    model = "gpt-3.5-turbo-instruct",
    endpoint_url = "https://api.openai.com/v1/completions",
    max_tokens = 1000,
    temperature = 0.1,
    request_timeout = 20,
    enable_auth = 1,
    selection_boundary = "#####",
  },
  ui = {
    paste_mode = 1,
  },
}

-- " This prompt instructs model to work with syntax highlighting
local initial_chat_prompt = [[
>>> system

You are a general assistant.
If you attach a code block add syntax type after ``` to enable syntax highlighting.
]]

-- " :AIChat
-- " - options: openai config (see https://platform.openai.com/docs/api-reference/chat)
-- " - options.initial_prompt: prompt prepended to every chat request (list of lines or string)
-- " - options.request_timeout: request timeout in seconds
-- " - options.enable_auth: enable authorization using openai key
-- " - options.selection_boundary: seleciton prompt wrapper (eliminates empty responses, see #20)
-- " - ui.populate_options: put [chat-options] to the chat header
-- " - ui.open_chat_command: preset (preset_below, preset_tab, preset_right) or a custom command
-- " - ui.scratch_buffer_keep_open: re-use scratch buffer within the vim session
-- " - ui.paste_mode: use paste mode (see more info in the Notes below)
vim.g.vim_ai_chat = {
  options = {
    model = "gpt-4-1106-preview",
    endpoint_url = "https://api.openai.com/v1/chat/completions",
    max_tokens = 1000,
    temperature = 1,
    request_timeout = 20,
    enable_auth = 1,
    selection_boundary = "",
    initial_prompt = initial_chat_prompt,
  },
  ui = {
    code_syntax_enabled = 1,
    populate_options = 0,
    open_chat_command = "preset_below",
    scratch_buffer_keep_open = 0,
    paste_mode = 1,
  },
}

-- " Notes:
-- " ui.paste_mode
-- " - if disabled code indentation will work but AI doesn't always respond with a code block
-- "   therefore it could be messed up
-- " - find out more in vim's help `:help paste`
-- " options.max_tokens
-- " - note that prompt + max_tokens must be less than model's token limit, see #42, #46
-- " - setting max tokens to 0 will exclude it from the OpenAI API request parameters, it is
-- "   unclear/undocumented what it exactly does, but it seems to resolve issues when the model
-- "   hits token limit, which respond with `OpenAI: HTTPError 400`

local initial_prompt = [[
>>> system

You are going to play a role of a completion engine with following parameters:
Task: Provide compact code/text completion, generation, transformation or explanation
Topic: general programming and text editing
Style: Plain result without any commentary, unless commentary is necessary
Audience: Users of text editor and programmers that need to transform/generate text
]]

vim.chat_engine_config = {
  engine = "chat",
  options = {
    model = "gpt-3.5-turbo-1106",
    max_tokens = 2000,
    temperature = 0.7,
    request_timeout = 20,
    selection_boundary = "",
    initial_prompt = initial_prompt,
  },
}

-- " let g:vim_ai_complete = chat_engine_config
-- " let g:vim_ai_edit = chat_engine_config

-- Função para perguntar a intenção do commit ao usuário
local function askCommitIntention()
  return vim.fn.input('Enter the intention of the commit: ')
end

-- Função para obter o diff do git
local function getGitDiff()
  return vim.fn.system('git --no-pager diff --staged')
end

-- Function to build the prompt for the GPT-4 model
local function buildPrompt(diff, intention)
  local instructions = "Generate a professional git commit message using the Conventional Commits format. " ..
      "This includes using a commit type (such as 'feat', 'fix', 'refactor', etc.), " ..
      "optionally a scope in parentheses, and a brief description that reflects the intention '" ..
      intention ..
      "'. All explanation must be inside the commit message. Do not write" ..
      " anything before or affter." ..
      "Do not enclose the commit message between ``` and ``` " ..
      "Base the commit message on the changes provided below:\n" ..
      diff

  return instructions
end

-- Função para executar a IA e gerar a mensagem de commit
local function generateCommitMessage()
  local intention = askCommitIntention()
  local diff = getGitDiff()

  if diff == "" then
    print("No changes detected. Cannot generate commit message.")
    return
  end

  local prompt = buildPrompt(diff, intention)
  local range = 0
  local config = {
    engine = "chat",
    options = {
      model = "gpt-4-1106-preview",
      endpoint_url = "https://api.openai.com/v1/chat/completions",
      max_tokens = 1000,
      initial_prompt = ">>> system\nyou are a code assistant",
      temperature = 1,
    },
  }

  -- Executar a IA com a configuração fornecida
  vim.api.nvim_call_function('vim_ai#AIRun', { range, config, prompt })
end

-- " Comando personalizado para sugerir mensagem de commit
vim.api.nvim_create_user_command('GitCommitMessage', generateCommitMessage, {})

local function CodeReviewFn(range)
  local prompt = "programming syntax is " .. vim.bo.filetype .. ", review the code below"
  local config = {
    options = {
      model = "gpt-4-1106-preview",
      initial_prompt = ">>> system\nyou are a clean code expert",
    },
  }

  vim.api.nvim_call_function('vim_ai#AIChatRun', { range, config, prompt })
end

vim.api.nvim_create_user_command('CodeReview', CodeReviewFn, { range = true })

return {
  'madox2/vim-ai'

}
