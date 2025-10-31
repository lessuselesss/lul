# Fish shell completions for Claude Code CLI
# Based on claude --help output from version 2.0.27

# Helper function to check if we're in a subcommand
function __fish_claude_using_subcommand
    set -l cmd (commandline -opc)
    set -e cmd[1] # Remove 'claude'

    # If no arguments or only options, we're not in a subcommand
    if test (count $cmd) -eq 0
        return 0
    end

    # Check if any argument is a known subcommand
    for arg in $cmd
        string match -q -- '-*' $arg; or return 1
    end
    return 0
end

# Check if we're in a specific subcommand
function __fish_claude_using_command
    set -l cmd (commandline -opc)
    test (count $cmd) -gt 1; and contains -- $cmd[2] $argv
end

# Main commands
complete -c claude -f -n __fish_claude_using_subcommand -a mcp -d "Configure and manage MCP servers"
complete -c claude -f -n __fish_claude_using_subcommand -a plugin -d "Manage Claude Code plugins"
complete -c claude -f -n __fish_claude_using_subcommand -a migrate-installer -d "Migrate from global npm to local installation"
complete -c claude -f -n __fish_claude_using_subcommand -a setup-token -d "Set up long-lived authentication token"
complete -c claude -f -n __fish_claude_using_subcommand -a doctor -d "Check health of auto-updater"
complete -c claude -f -n __fish_claude_using_subcommand -a update -d "Check for and install updates"
complete -c claude -f -n __fish_claude_using_subcommand -a install -d "Install Claude Code native build"

# Global options - work with any command
complete -c claude -s d -l debug -d "Enable debug mode with optional category filtering"
complete -c claude -l verbose -d "Override verbose mode setting from config"
complete -c claude -s p -l print -d "Print response and exit (useful for pipes)"
complete -c claude -l output-format -xa "text json stream-json" -d "Output format (only with --print)"
complete -c claude -l include-partial-messages -d "Include partial messages as they arrive"
complete -c claude -l input-format -xa "text stream-json" -d "Input format (only with --print)"
complete -c claude -l mcp-debug -d "[DEPRECATED] Enable MCP debug mode"
complete -c claude -l dangerously-skip-permissions -d "Bypass all permission checks"
complete -c claude -l allow-dangerously-skip-permissions -d "Enable skip permissions as option"
complete -c claude -l replay-user-messages -d "Re-emit user messages from stdin"
complete -c claude -l allowedTools -l allowed-tools -d "Comma/space-separated list of tool names to allow"
complete -c claude -l disallowedTools -l disallowed-tools -d "Comma/space-separated list of tool names to deny"
complete -c claude -l mcp-config -F -d "Load MCP servers from JSON files"
complete -c claude -l system-prompt -d "System prompt for the session"
complete -c claude -l append-system-prompt -d "Append to default system prompt"
complete -c claude -l permission-mode -xa "acceptEdits bypassPermissions default plan" -d "Permission mode for session"
complete -c claude -s c -l continue -d "Continue the most recent conversation"
complete -c claude -s r -l resume -d "Resume a conversation (provide session ID or select)"
complete -c claude -l fork-session -d "Create new session ID when resuming"
complete -c claude -l model -d "Model for current session (e.g. 'sonnet', 'opus')"
complete -c claude -l fallback-model -d "Automatic fallback model when overloaded"
complete -c claude -l settings -F -d "Path to settings JSON or JSON string"
complete -c claude -l add-dir -xa "(__fish_complete_directories)" -d "Additional directories for tool access"
complete -c claude -l ide -d "Auto-connect to IDE on startup"
complete -c claude -l strict-mcp-config -d "Only use MCP servers from --mcp-config"
complete -c claude -l session-id -d "Use specific session ID (must be UUID)"
complete -c claude -l agents -d "JSON object defining custom agents"
complete -c claude -l setting-sources -d "Comma-separated setting sources (user, project, local)"
complete -c claude -l plugin-dir -xa "(__fish_complete_directories)" -d "Load plugins from directories"
complete -c claude -s v -l version -d "Output version number"
complete -c claude -s h -l help -d "Display help for command"

# Tool suggestions for --allowedTools / --disallowedTools
set -l claude_tools "Bash Edit Read Write Glob Grep Task WebFetch WebSearch SlashCommand Skill AskUserQuestion"
complete -c claude -l allowedTools -l allowed-tools -xa "$claude_tools" -d "Available tools"
complete -c claude -l disallowedTools -l disallowed-tools -xa "$claude_tools" -d "Available tools"

# MCP subcommands
complete -c claude -f -n '__fish_claude_using_command mcp' -a serve -d "Start MCP server"
complete -c claude -f -n '__fish_claude_using_command mcp' -a add -d "Add MCP server configuration"
complete -c claude -f -n '__fish_claude_using_command mcp' -a remove -d "Remove MCP server"
complete -c claude -f -n '__fish_claude_using_command mcp' -a list -d "List configured MCP servers"
complete -c claude -f -n '__fish_claude_using_command mcp' -a get -d "Get MCP server configuration"
complete -c claude -f -n '__fish_claude_using_command mcp' -a add-json -d "Add MCP server from JSON"
complete -c claude -f -n '__fish_claude_using_command mcp' -a add-from-claude-desktop -d "Import from Claude Desktop config"
complete -c claude -f -n '__fish_claude_using_command mcp' -a reset-project-choices -d "Reset project MCP choices"

# Plugin subcommands
complete -c claude -f -n '__fish_claude_using_command plugin' -a list -d "List installed plugins"
complete -c claude -f -n '__fish_claude_using_command plugin' -a add -d "Add a plugin"
complete -c claude -f -n '__fish_claude_using_command plugin' -a remove -d "Remove a plugin"
complete -c claude -f -n '__fish_claude_using_command plugin' -a update -d "Update plugins"
complete -c claude -f -n '__fish_claude_using_command plugin' -a info -d "Show plugin information"

# Install command options
complete -c claude -n '__fish_claude_using_command install' -xa "stable latest" -d "Install target version"
complete -c claude -n '__fish_claude_using_command install' -l force -d "Force reinstallation"

# Model aliases for quick reference
set -l claude_models "sonnet opus haiku"
complete -c claude -l model -xa "$claude_models" -d "Model alias"
complete -c claude -l fallback-model -xa "$claude_models" -d "Fallback model alias"

# Permission modes
set -l permission_modes "acceptEdits bypassPermissions default plan"
complete -c claude -l permission-mode -xa "$permission_modes"
