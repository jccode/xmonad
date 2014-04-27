import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO

main = do
    xmproc <- spawnPipe "/home/jcchen/.cabal/bin/xmobar /home/jcchen/.xmobarrc"
    xmonad $ defaultConfig
      { manageHook = manageDocks <+> myManageHook 
                     <+> manageHook defaultConfig
      , layoutHook = avoidStruts  $  layoutHook defaultConfig
      , logHook = dynamicLogWithPP xmobarPP
                  { ppOutput = hPutStrLn xmproc
                  , ppTitle = xmobarColor "green" "" . shorten 50
                  }
      , modMask = mod4Mask
      , terminal = "xfce4-terminal"
      , borderWidth = 3
      } `additionalKeys`
      [ ((controlMask .|. shiftMask, xK_Delete), spawn "xscreensaver-command -lock")
      , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
      , ((0, xK_Print), spawn "scrot")
      ]


myManageHook = composeAll
               [ className =? "Gimp" --> doFloat
               , className =? "Vncviewer" --> doFloat
               ]
