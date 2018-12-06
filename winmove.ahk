SetWinDelay, 0

GetCurrentMonitor()
{
  SysGet, numberOfMonitors, MonitorCount
  WinGetPos, winX, winY, winWidth, winHeight, A
  winMidX := winX + winWidth / 2
  winMidY := winY + winHeight / 2
  Loop %numberOfMonitors%
  {
    SysGet, monArea, Monitor, %A_Index%
    if (winMidX > monAreaLeft && winMidX < monAreaRight && winMidY < monAreaBottom && winMidY > monAreaTop)
      return A_Index
  }
  SysGet, primaryMonitor, MonitorPrimary
  return "No Monitor Found"
}

GetAdjacentMonitor(Dir)
{
    SysGet, numberOfMonitors, MonitorCount
    CurrMon:=GetCurrentMonitor()
    SysGet, Mon, Monitor, %CurrMon%
    WinGetPos, winX, winY, winWidth, winHeight, A
    winMidX := winX + winWidth / 2
    winMidY := winY + winHeight / 2
    ret:=-1
    Loop %numberOfMonitors%
    {
        if (A_Index == CurrMon)
        {
            Continue
        }
        SysGet, Cand, Monitor, %A_Index%
        if (Dir == "up"){
           if (CandBottom == MonTop && winMidX > CandLeft && winMidX < CandRight){
               return A_Index
           }
        } else if (Dir == "down"){
           if (CandTop == MonBottom && winMidX > CandLeft && winMidX < CandRight){
               return A_Index
           }
        } else if (Dir == "left"){
           if (CandRight == MonLeft && winMidY > CandTop && winMidY < CandBottom){
               return A_Index
           }
        } else if (Dir == "right"){
           if (CandLeft == MonRight && winMidY > CandTop && winMidY < CandBottom){
               return A_Index
           }
        }
    }
    return -1
}

GetProportions(ByRef w, ByRef h, ByRef x, ByRef y, ByRef Max)
{
    CurrMon:=GetCurrentMonitor()
    SysGet, Mon, MonitorWorkArea, %CurrMon%
    WinGetActiveStats, Title, Width, Height, WinX, WinY
    MonWidth:=MonRight-MonLeft
    MonHeight:=MonBottom-MonTop
    w:=Width/MonWidth
    h:=Height/MonHeight
    x:=(WinX-MonLeft)/MonWidth
    y:=(WinY-MonTop)/MonHeight
    WinGet, Max, MinMax, %Title%
}

Move(NewMon)
{
    GetProportions(W, H, X, Y, Max)
    SysGet, Mon, MonitorWorkArea, %NewMon%
    WinGetActiveStats, Title, Width, Height, WinX, WinY
    MonWidth:=MonRight-MonLeft
    MonHeight:=MonBottom-MonTop
    NewWidth:=MonWidth*W
    NewHeight:=MonHeight*H
    NewX:=MonLeft+MonWidth*X
    NewY:=MonTop+MonHeight*Y
    if ( Max = 1 ) {
      WinRestore, %Title%
    }
    WinMove, %Title%, , %NewX%, %NewY%, %NewWidth%, %NewHeight%
    if ( Max = 1 ) {
      WinMaximize, %Title%
    }
}

SnapUp()
{
    CurrMon:=GetCurrentMonitor()
    GetProportions(W, H, X, Y, Max)
    if (W>.75){
        W:=1
    } else {
        W:=.5
    }
    if (X<.25){
        X:=0
    } else {
        X:=.5
    }
    SysGet, Mon, MonitorWorkArea, %CurrMon%
    WinGetActiveStats, Title, Width, Height, WinX, WinY
    MonWidth:=MonRight-MonLeft
    NewWidth:=MonWidth*W
    NewX:=MonLeft+MonWidth*X
    MonHeight:=MonBottom-MonTop
    NewHeight:=MonHeight/2
    WinRestore, %Title%
    WinMove, %Title%, , %NewX%, %MonTop%, %NewWidth%, %NewHeight%
}

SnapDown()
{
    CurrMon:=GetCurrentMonitor()
    GetProportions(W, H, X, Y, Max)
    if (W>.75){
        W:=1
    } else {
        W:=.5
    }
    if (X<.25){
        X:=0
    } else {
        X:=.5
    }
    SysGet, Mon, MonitorWorkArea, %CurrMon%
    WinGetActiveStats, Title, Width, Height, WinX, WinY
    MonWidth:=MonRight-MonLeft
    NewWidth:=MonWidth*W
    NewX:=MonLeft+MonWidth*X
    MonHeight:=MonBottom-MonTop
    NewHeight:=MonHeight/2
    NewY:=MonTop+NewHeight
    WinRestore, %Title%
    WinMove, %Title%, , %NewX%, %NewY%, %NewWidth%, %NewHeight%
}

MaxWide()
{
    CurrMon:=GetCurrentMonitor()
    SysGet, Mon, MonitorWorkArea, %CurrMon%
    WinGetActiveStats, Title, Width, Height, WinX, WinY
    MonWidth:=MonRight-MonLeft
    WinMove, %Title%, , %MonLeft%, %WinY%, %MonWidth%, %Height%
}

MoveDirection(Dir)
{
    NewMon:=GetAdjacentMonitor(Dir)
    if (NewMon != -1){
        Move(NewMon)
    }
}

^#1::Move(1)
^#2::Move(2)
^#3::Move(3)
^#4::Move(4)
^#5::Move(5)
^#6::Move(6)

^#Up::SnapUp()
^#Down::SnapDown()
^#Right::MaxWide()
^#Left::MaxWide()

!#Up::MoveDirection("up")
!#Down::MoveDirection("down")
!#Left::MoveDirection("left")
!#Right::MoveDirection("right")
