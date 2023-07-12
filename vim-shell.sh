if [[ -n "$VIM_TERMINAL" ]]; then
	function _vim_sync_PWD() {
		printf '\033]7;file://%s\033\\' "$PWD"
	}
	PROMPT_COMMAND="_vim_sync_PWD;${PROMPT_COMMAND}"
fi
