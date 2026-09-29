# ~/.config/fish/functions/term.fish
function term
    set monitor (hyprctl monitors -j | jq -r '.[] | select(.focused==true) | .name')
    if test $monitor = "HDMI-A-1"
        fish --override font_size=12
    else
        fish
    end
end
