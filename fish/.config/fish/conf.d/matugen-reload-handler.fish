function _matugen_reload --on-signal SIGUSR1
    source ~/.cache/fish/matugen-colors.fish
    commandline -f repaint
end
