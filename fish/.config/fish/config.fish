# Autostart Hyprland on TTY1
if status is-login
    if test -z "$DISPLAY" && test $XDG_VTNR -eq 1
        exec start-hyprland
    end
end

if status is-interactive

    cat ~/.cache/matugen/sequences

    # ── Aliases ──────────────────────────────────────────────
    alias vim nvim
    alias v nvim
    alias ls 'ls --color=auto'
    alias ll 'ls -lah --color=auto'
    alias la 'ls -A --color=auto'
    alias mv 'mv -iv'
    alias mkdir 'mkdir -pv'
    alias df 'df -h'
    alias free 'free -h'
    alias grep 'grep --color=auto'

    alias g git
    alias gs 'git status'
    alias ga 'git add'
    alias gc 'git commit'
    alias gp 'git push'
    alias gl 'git log --oneline --graph'
    alias firefox="firefox --profile ~/.config/mozilla/firefox/jxpfrbmw.default-release"

    # ── Exports ──────────────────────────────────────────────
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx PICO_SDK_PATH /home/ajrom/projects/pico-sdk
    set -gx XDG_CONFIG_HOME $HOME/.config
    set -gx XDG_DATA_HOME $HOME/.local/share

    # Wayland
    set -gx WAYLAND_DISPLAY wayland-1
    set -gx QT_QPA_PLATFORM wayland
    set -gx MOZ_ENABLE_WAYLAND 1

    # ── Keybinds ─────────────────────────────────────────────
    bind ctrl-f accept-autosuggestion
    bind ctrl-g forward-word

    # ── Path ─────────────────────────────────────────────────
    fish_add_path ~/.local/bin
    fish_add_path ~/scripts

    # -- Greeting ---------------------------------------------
    set -g fish_greeting ""

    function fish_prompt
        set_color $matugen_primary
        echo -n (whoami)
        set_color normal
        echo -n ':'
        set_color $matugen_tertiary
        echo -n (prompt_pwd)
        set_color normal
        echo -n '$ '
    end


    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if set cwd (command cat -- "$tmp"); and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end

    function android-emulator
        env QT_QPA_PLATFORM=xcb $ANDROID_HOME/emulator/emulator $argv
    end


    zoxide init fish | source

end
