import XMonad
import XMonad.Actions.CycleWS
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import XMonad.Hooks.ManageHelpers
import Graphics.X11.ExtraTypes

import XMonad.Layout.NoBorders (smartBorders, noBorders)
import XMonad.Layout.PerWorkspace (onWorkspace, onWorkspaces)
import XMonad.Layout.Reflect (reflectHoriz)
import XMonad.Layout.IM as IM
import XMonad.Layout.WindowNavigation
import XMonad.Layout.Minimize
import XMonad.Layout.ToggleLayouts
import XMonad.Layout.SimpleFloat
import XMonad.Layout.Spacing
import XMonad.Layout.ResizableTile
import XMonad.Layout.LayoutHints
import XMonad.Layout.LayoutModifier
import XMonad.Layout.Grid

import System.IO
import Data.Ratio ((%))
import qualified XMonad.StackSet as W
import qualified Data.Map as M


modMask' :: KeyMask
modMask' = mod4Mask

myTerminal = "xfce4-terminal"

myXmonadBar = "dzen2 -x '0' -w '400' -ta 'l'" ++ myDzenStyle
myStatusBar = "conky -c ~/.xmonad/conkyrc | dzen2 -x '400' -w '1000' -ta 'r' " ++ myDzenStyle
myDzenStyle = " -h '26' -y '0' -fg '#ff0' "

main = do
    -- xmobar
    -- xmproc <- spawnPipe "/home/jcchen/.cabal/bin/xmobar /home/jcchen/.xmobarrc"
    
    -- dzen2
    leftBar <- spawnPipe myXmonadBar
    rightBar <- spawnPipe myStatusBar
    
    xmonad $ defaultConfig
      { modMask = modMask'
      , terminal = myTerminal
      , borderWidth = 3
      , manageHook = manageDocks <+> myManageHook 
                     <+> manageHook defaultConfig
      , layoutHook = myLayoutHook
   -- , logHook = myXmobarLogHook xmproc
      , logHook = myDzenLogHook leftBar
      , keys = newKeys
      } 


myManageHook :: ManageHook
myManageHook = (composeAll . concat $ 
               [ [ className =? f --> doFloat | f <- myFloats ]
               , [ resource =? r --> doIgnore | r <- myIgnores ]
               , [isFullscreen --> myDoFullFloat ]
               ])
               where
                 myFloats = ["Gimp", "Gmixer", "Vncviewer"]
                 myIgnores = ["desktop", "desktop_window", "trayer","notify-osd","stalonetray"]



-- a trick for fullscreen but stil allow focusing of other WSs
myDoFullFloat :: ManageHook
myDoFullFloat = doF W.focusDown <+> doFullFloat


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



-- custom Layouts
myLayoutHook = avoidStruts  $  layoutHook defaultConfig

-- to be learn...
skypeLayout = IM.withIM (1%7) (IM.And (ClassName "Skype")  (Role "MainWindow")) Grid
normalLayout = windowNavigation $ minimize $ avoidStruts $ onWorkspace "4:skype" skypeLayout $ layoutHook defaultConfig
myLayout = toggleLayouts (Full) normalLayout


-- Add new keys
newKeys x = M.union (keys defaultConfig x) (M.fromList (keys' x))

keys' conf@(XConfig {XMonad.modMask = modMask}) = 
      [ ((controlMask .|. shiftMask, xK_Delete), spawn "xscreensaver-command -lock")
      , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
      , ((0, xK_Print), spawn "scrot")
        -- 
        -- restart
      , ((mod4Mask, xK_q), spawn "killall conky dzen2 && xmonad --recompile && xmonad --restart")

        -- volumn control
      , ((0 , xF86XK_AudioRaiseVolume),          spawn "pactl set-sink-volume 0 +1.5%")
      , ((0 , xF86XK_AudioLowerVolume),          spawn "pactl set-sink-volume 0 -- -1.5%")
      , ((0 , xF86XK_AudioMute),                 spawn "pactl set-sink-mute 0 toggle")        
        -- , ((0, xF86XK_AudioLowerVolume   ),        spawn "amixer set Master 2-")
        -- , ((0, xF86XK_AudioRaiseVolume   ),        spawn "amixer set Master 2+")
        -- , ((0, xF86XK_AudioMute          ),        spawn "amixer set Master toggle")

        -- workspace
      , ((modMask .|. controlMask, xK_Right), nextWS)
      , ((modMask .|. controlMask, xK_Left ), prevWS)
      , ((modMask .|. shiftMask, xK_Right), shiftToNext)
      , ((modMask .|. shiftMask, xK_Left), shiftToPrev)
        
        -- shiftToNext, then, nextWS
      -- , ((modMask .|. controlMask .|. shiftMask, xK_Right), )
        
      ]

