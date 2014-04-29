#!/bin/sh

user=`whoami`

cp -f /home/$user/.xmonad/session session
cp -f /home/$user/.xmonad/xmonad.hs xmonad.hs
cp -f /usr/share/xsessions/xmonad.desktop xmonad.desktop
cp -f /usr/bin/xmonad-start xmonad-start
cp -f /home/$user/.xmobarrc _xmobarrc
cp -f /home/$user/.xmonad/conkyrc conkyrc

