-- " ============================================================================
-- " VIM-AI {{{
-- " ============================================================================
--[[
This prompt instructs model to be concise in order to be used inline in editor
]]
local initial_complete_prompt = [[

			system

You are a general assistant.
Answer shortly, concisely and only what you are asked.
Do not provide any explanation or comments if not requested.
If you answer in a code, do not wrap it in a markdown code block.
]]

--[[
:AI
	•	prompt: optional prepended prompt
	•	engine: chat | complete - see how to configure complete engine in the section below
	•	options: openai config (see https://platform.openai.com/docs/api-reference/completions)
	•	options.initial_prompt: prompt prepended to every chat request (list of lines or string)
	•	options.request_timeout: request timeout in seconds
	•	options.enable_auth: enable authorization using openai key
	•	options.token_file_path: override global token configuration
	•	options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
	•	ui.paste_mode: use paste mode (see more info in the Notes below)
]]
vim.g.vim_ai_complete = {
	prompt = "",
	engine = "chat",
	options = {
		model = "gpt-4o",
		endpoint_url = "https://api.openai.com/v1/chat/completions",
		max_tokens = 0,
		max_completion_tokens = 0,
		--   temperature = 0.1,
		request_timeout = 20,
		stream = 1,
		enable_auth = 1,
		token_file_path = "",
		selection_boundary = "#####",
		initial_prompt = initial_complete_prompt,
	},
	ui = {
		paste_mode = 1,
	},
}

--[[
:AIEdit
	•	prompt: optional prepended prompt
	•	engine: chat | complete - see how to configure complete engine in the section below
	•	options: openai config (see https://platform.openai.com/docs/api-reference/completions)
	•	options.initial_prompt: prompt prepended to every chat request (list of lines or string)
	•	options.request_timeout: request timeout in seconds
	•	options.enable_auth: enable authorization using openai key
	•	options.token_file_path: override global token configuration
	•	options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
	•	ui.paste_mode: use paste mode (see more info in the Notes below)
]]
vim.g.vim_ai_edit = {
	prompt = "",
	engine = "chat",
	options = {
		model = "o3-mini",
		endpoint_url = "https://api.openai.com/v1/chat/completions",
		max_tokens = 0,
		max_completion_tokens = 0,
		temperature = 1,
		request_timeout = 20,
		stream = 1,
		enable_auth = 1,
		token_file_path = "",
		selection_boundary = "#####",
		initial_prompt = initial_complete_prompt,
	},
	ui = {
		paste_mode = 1,
	},
}

--[[
This prompt instructs model to work with syntax highlighting
]]
local initial_chat_prompt = [[

			system

You are a general assistant.
If you attach a code block add syntax type after ``` to enable syntax highlighting.
]]

--[[
:AIChat
	•	prompt: optional prepended prompt
	•	options: openai config (see https://platform.openai.com/docs/api-reference/chat)
	•	options.initial_prompt: prompt prepended to every chat request (list of lines or string)
	•	options.request_timeout: request timeout in seconds
	•	options.enable_auth: enable authorization using openai key
	•	options.token_file_path: override global token configuration
	•	options.selection_boundary: selection prompt wrapper (eliminates empty responses, see #20)
	•	ui.open_chat_command: preset (preset_below, preset_tab, preset_right) or a custom command
	•	ui.populate_options: put [chat-options] to the chat header
	•	ui.scratch_buffer_keep_open: re-use scratch buffer within the vim session
	•	ui.force_new_chat: force new chat window (used in chat opening roles e.g. /tab)
	•	ui.paste_mode: use paste mode (see more info in the Notes below)
]]
vim.g.vim_ai_chat = {
	prompt = "",
	options = {
		model = "gpt-4o",
		endpoint_url = "https://api.openai.com/v1/chat/completions",
		max_tokens = 0,
		max_completion_tokens = 0,
		--    temperature = 1,
		request_timeout = 20,
		stream = 1,
		enable_auth = 1,
		token_file_path = "",
		selection_boundary = "",
		initial_prompt = initial_chat_prompt,
	},
	ui = {
		open_chat_command = "preset_below",
		scratch_buffer_keep_open = 0,
		populate_options = 0,
		code_syntax_enabled = 1,
		force_new_chat = 0,
		paste_mode = 1,
	},
}

--[[
:AIImage
	•	prompt: optional prepended prompt
	•	options: openai config (https://platform.openai.com/docs/api-reference/images/create)
	•	options.request_timeout: request timeout in seconds
	•	options.enable_auth: enable authorization using openai key
	•	options.token_file_path: override global token configuration
	•	options.download_dir: path to image download directory, cwd if not defined
]]
vim.g.vim_ai_image_default = {
	prompt = "",
	options = {
		model = "dall-e-3",
		endpoint_url = "https://api.openai.com/v1/images/generations",
		quality = "standard",
		size = "1024x1024",
		style = "vivid",
		request_timeout = 20,
		enable_auth = 1,
		token_file_path = "",
	},
	ui = {
		download_dir = "",
	},
}

-- custom roles file location
vim.g.vim_ai_roles_config_file = "~/.config/nvim/lua/custom/plugins/vim-ai-roles.ini"

-- custom token file location
--vim.g.vim_ai_token_file_path = "~/.config/openai.token"

-- debug settings
vim.g.vim_ai_debug = 0
vim.g.vim_ai_debug_log_file = "/tmp/vim_ai_debug.log"

--[[
Notes:
ui.paste_mode
	•	if disabled code indentation will work but AI doesn’t always respond with a code block
therefore it could be messed up
	•	find out more in vim’s help :help paste
options.max_tokens
	•	note that prompt + max_tokens must be less than model’s token limit, see #42, #46
	•	setting max tokens to 0 will exclude it from the OpenAI API request parameters, it is
unclear/undocumented what it exactly does, but it seems to resolve issues when the model
hits token limit, which respond with OpenAI: HTTPError 400
]]

-- Função para perguntar a intenção do commit ao usuário
local function askCommitIntention()
	return vim.fn.input('Enter the intention of the commit: ')
end

-- Função para obter o diff do git
local function getGitDiff()
	return vim.fn.system('git --no-pager diff --staged')
end

-- Função para construir o prompt para o modelo GPT-4
local function buildPrompt(diff, intention)
	local instructions = "Generate a professional git commit message using the" ..
			" Conventional Commits format. " ..
			"This includes using a commit type (such as 'feat', 'fix', 'refactor', etc.), " ..
			"optionally a scope in parentheses, and a brief description that reflects" ..
			" the intention '" .. intention .. "'." ..
			"- All explanation must be inside the commit message. Do not write" ..
			" anything before or after." ..
			"- Do not enclose the commit message between ``` and ```" ..
			"- Add line breaks at column 78" ..
			"- Base the commit message on the changes provided below:\n" ..
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
			model = "gpt-4o-mini",
			endpoint_url = "https://api.openai.com/v1/chat/completions",
			max_tokens = 1000,
			initial_prompt = ">>> system\nyou are a code assistant",
			--      temperature = 1,
		},
	}

	-- Executar a IA com a configuração fornecida
	vim.api.nvim_call_function('vim_ai#AIRun', { range, config, prompt })
end

-- Comando personalizado para sugerir mensagem de commit
vim.api.nvim_create_user_command('GitCommitMessage', generateCommitMessage, {})

-- Cria o comando GitAICommit
vim.api.nvim_create_user_command('GitAICommit', function()
	-- Inicia o Git commit
	vim.cmd('Git commit')

	-- Define um timer para esperar antes de executar GitCommitMessage
	vim.defer_fn(function()
		vim.cmd('GitCommitMessage')
	end, 1500) -- Ajuste o tempo de espera conforme necessário (em milissegundos)
end, {})

local function CodeReviewFn(range)
	local prompt = "programming syntax is " .. vim.bo.filetype .. ", review the code below"
	local config = {
		options = {
			model = "gpt-4-1106-preview",
			initial_prompt = ">>> system\nyou are a clean code expert",
		},
	}

	vim.fn['vim_ai#AIChatRun'](range, config, prompt)
end

vim.api.nvim_create_user_command('CodeReview', CodeReviewFn, { range = true })

return {
	'madox2/vim-ai'
}
