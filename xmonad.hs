import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes
import System.IO

main = do
    -- xmobar
    -- xmproc <- spawnPipe "/home/jcchen/.cabal/bin/xmobar /home/jcchen/.xmobarrc"
    
    -- dzen2
    leftBar <- spawnPipe myXmonadBar
    rightBar <- spawnPipe myStatusBar
    
    xmonad $ defaultConfig
      { manageHook = manageDocks <+> myManageHook 
                     <+> manageHook defaultConfig
      , layoutHook = avoidStruts  $  layoutHook defaultConfig
      -- , logHook = myXmobarLogHook xmproc
      , logHook = myDzenLogHook leftBar
      , modMask = mod4Mask
      , terminal = "xfce4-terminal"
      , borderWidth = 3
      } `additionalKeys`
      [ ((controlMask .|. shiftMask, xK_Delete), spawn "xscreensaver-command -lock")
      , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
      , ((0, xK_Print), spawn "scrot")

        -- volumn control
      , ((0 , xF86XK_AudioRaiseVolume),          spawn "pactl set-sink-volume 0 +1.5%")
      , ((0 , xF86XK_AudioLowerVolume),          spawn "pactl set-sink-volume 0 -- -1.5%")
      , ((0 , xF86XK_AudioMute),                 spawn "pactl set-sink-mute 0 toggle")        
        -- , ((0, xF86XK_AudioLowerVolume   ),        spawn "amixer set Master 2-")
        -- , ((0, xF86XK_AudioRaiseVolume   ),        spawn "amixer set Master 2+")
        -- , ((0, xF86XK_AudioMute          ),        spawn "amixer set Master toggle")        
      ]


myManageHook :: ManageHook
myManageHook = composeAll
               [ className =? "Gimp" --> doFloat
               , className =? "Gmixer" --> doFloat
               , className =? "Vncviewer" --> doFloat
               ]


myXmobarLogHook :: Handle -> X ()
myXmobarLogHook xmproc = dynamicLogWithPP xmobarPP
                         { ppOutput = hPutStrLn xmproc
                         , ppTitle = xmobarColor "green" "" . shorten 50
                         }


myDzenLogHook :: Handle -> X ()
myDzenLogHook h = dynamicLogWithPP $ defaultPP
                  { ppCurrent = dzenColor "#3399ff" "" . wrap " " " "
                  , ppHidden  = dzenColor "#dddddd" "" . wrap " " " "
                  , ppHiddenNoWindows = dzenColor "#777777" "" . wrap " " " "
                  , ppUrgent  = dzenColor "#ff0000" "" . wrap " " " "
                  , ppSep     = "  "
                  , ppLayout  = \y -> ""
                  , ppTitle   = dzenColor "#ffffff" "" . wrap " " " "

                  , ppOutput = hPutStrLn h
                  -- , ppTitle = (" " ++) . dzenColor "white" "#1B1D1E" . dzenEscape
                  }


myXmonadBar = "dzen2 -x '0' -w '400' -ta 'l'" ++ myDzenStyle
myStatusBar = "conky -c ~/.xmonad/conkyrc | dzen2 -x '400' -w '800' -ta 'r' " ++ myDzenStyle
myDzenStyle = " -h '26' -y '0' -fg '#ff0' "
