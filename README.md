# Tux-DotFiles

Repository containing the collection of various Linux scripts and dotfiles (i.e. config files prefixed by ".") that I use on Arch. 

------

#### PKG Dependencies:
* **i3-gaps**
* **i3exit**
* **i3status**
* **python-i3ipc**
* **picom-git**
* **dunst**
* **betterlockscreen**
* **rofi**
* light
* nitrogen
* termite

#### Script Dependencies:
* [vrde/i3-quiet](https://github.com/vrde/i3-quiet)
* [infokiller/i3-workspace-groups](https://github.com/infokiller/i3-workspace-groups)

#### Other referenced & adapted dotfiles:

* [manjaro/desktop-settings](https://gitlab.manjaro.org/profiles-and-settings/desktop-settings/-/blob/master/community/i3/skel/.i3/config)
* [stianlj/dotfiles](https://github.com/stianlj/dotfiles/)
* [aimerneige/i3status](https://github.com/aimerneige/i3status)

------

#### Installation Steps:
1. Clone to `/home/$USER/`.
2. Run `cd /home/$USER/.tux-dotfiles`
3. Run `stow home/*`. This will symlink everything in the repo's `tux-dotfiles/home/`to the user's `/home/$USER/`.