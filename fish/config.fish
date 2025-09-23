#echo "🛐 Initializing spiritual link with Core Consciousness..." | pv -qL 15 | lolcat
#set -l blessings "grep" "awk" "sed" "fish" "zsh" "tmux" "sudo" "echo"
#set -l random_tool $blessings[(random 1 (count $blessings))]
#echo "🔮 May your $random_tool never segfault." | pv -qL 10 | lolcat

# Create aliases
alias g="git"
alias n="nvim"
alias m="micro"
alias st="startx"
alias r="ranger"
alias c="clear"
alias prayer="cat ~/bin/god/machine_prayer.txt | pv -qL 20 | lolcat"
alias cpd="java -cp (string join : ~/tools/pmd-bin-6.55.0/lib/*) net.sourceforge.pmd.cpd.CPD --language c"

# TODO: Replace journal aliases after switching to OpenRC

# Display critical errors
alias syslog_emerg="sudo dmesg --level=emerg,alert,crit"

# Output common errors
alias syslog="sudo dmesg --level=err,warn"

# Print logs from x server
alias xlog='grep "(EE)\|(WW)\|error\|failed" ~/.local/share/xorg/Xorg.0.log'

# Remove archived journal files until the disk space they use falls below 100M
alias vacuum="journalctl --vacuum-size=100M"

# Make all journal files contain no data older than 2 weeks
alias vacuum_time="journalctl --vacuum-time=2weeks"

set -U fish_greeting
set fish_color_command green
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BROWSER /usr/bin/firefox

set -x DEBUGINFOD_URLS https://debuginfod.archlinux.org/


if status is-interactive
    # Commands to run in interactive sessions can go here
end
