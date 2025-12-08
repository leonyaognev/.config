#echo "🛐 Initializing spiritual link with Core Consciousness..." | pv -qL 15 | lolcat
#set -l blessings "grep" "awk" "sed" "fish" "zsh" "tmux" "sudo" "echo"
#set -l random_tool $blessings[(random 1 (count $blessings))]
#echo "🔮 May your $random_tool never segfault." | pv -qL 10 | lolcat

set -U fish_greeting
set fish_color_command green
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER /usr/bin/firefox

set -x DEBUGINFOD_URLS https://debuginfod.archlinux.org/

export PATH="$HOME/.local/bin:$PATH"


if status is-interactive
    # Create aliases

    alias gc="git commit"
    alias ga="git add"
    alias gp="git push"
    alias la="exa -lah"
    alias cat="bat"
    alias man="tldr"
    alias cd="z"
    alias g="git"
    alias n="nvim"
    alias m="micro"
    alias st="startx"
    alias r="ranger"
    alias c="clear"
    alias prayer="cat ~/bin/god/machine_prayer.txt | pv -qL 20 | lolcat"
    alias cpd="java -cp (string join : ~/tools/pmd-bin-6.55.0/lib/*) net.sourceforge.pmd.cpd.CPD --language c"

    alias ut="tar -xvzf"
    alias t="tar -czf"

    zoxide init fish | source
    pokemon-colorscripts -r
end
