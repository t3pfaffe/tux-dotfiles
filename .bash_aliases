##Bash Aliases
##############

#Default command aliases
alias cp="cp -i"                          # confirm before overwriting something
alias df='df -h'                          # human-readable sizes
alias free='free -m'                      # show sizes in MB
alias np='nano -w PKGBUILD'
alias more=less

#clear bash history
alias clrbashhistory='rm ~/.bash_history*; history -c && exit'

#ChangeDirectory shortcuts
alias cdhome='cd ~'
alias cddownloads='cd ~/Downloads'
alias cdprojects='cd ~/Projects'
alias cdtemplates='cd ~/Templates'

#pacman
alias pac='sudo pacman'

#micro
alias mi='micro'

#i3
alias i3edit='micro ~/.config/i3/config'
alias i3statusedit='micro ~/.config/i3status/config'

#fix-wallpaper with nitrogen
alias fixwalls="nitrogen --restore"

#Countdown
alias countdownto="~/Templates/Scripts/countdownto.sh"

#xClip
alias setclip="xclip -selection c"
alias getclip="xclip -selection c -o"
