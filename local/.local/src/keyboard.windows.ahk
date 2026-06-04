#Requires AutoHotkey v2.0
#SingleInstance Force

SetCapsLockState "AlwaysOff"
capsLockOn := false

$Escape:: {}
$Escape up:: {
    global capsLockOn

    capsLockOn := !capsLockOn
    if capsLockOn {
        SetCapsLockState "AlwaysOn"
    } else {
        SetCapsLockState "AlwaysOff"
    }
}

isComboTriggered := false
firstCapsLockUpTime := 0

$CapsLock:: {}
$CapsLock up:: {
    global isComboTriggered, firstCapsLockUpTime

    f := isComboTriggered
    isComboTriggered := false
    if f {
        return
    }

    currentTime := A_TickCount
    if (currentTime - firstCapsLockUpTime > 500) {
        firstCapsLockUpTime := currentTime
        return
    }

    firstCapsLockUpTime := 0
    Send "{Esc}"
}

$Enter:: {}
$Enter up:: {
    global isComboTriggered

    f := isComboTriggered
    isComboTriggered := false
    if f {
        return
    }

    Send "{Enter}"
}

#HotIf GetKeyState("CapsLock", "P") || GetKeyState("Enter", "P")

$*a::SendCombo("a")
$*b::SendCombo("b")
$*c::SendCombo("c")
$*d::SendCombo("d")
$*e::SendCombo("e")
$*f::SendCombo("f")
$*g::SendCombo("g")
$*h::SendCombo("h")
$*i::SendCombo("i")
$*j::SendCombo("j")
$*k::SendCombo("k")
$*l::SendCombo("l")
$*m::SendCombo("m")
$*n::SendCombo("n")
$*o::SendCombo("o")
$*p::SendCombo("p")
$*q::SendCombo("q")
$*r::SendCombo("r")
$*s::SendCombo("s")
$*t::SendCombo("t")
$*u::SendCombo("u")
$*v::SendCombo("v")
$*w::SendCombo("w")
$*x::SendCombo("x")
$*y::SendCombo("y")
$*z::SendCombo("z")

$*0::SendCombo("0")
$*1::SendCombo("1")
$*2::SendCombo("2")
$*3::SendCombo("3")
$*4::SendCombo("4")
$*5::SendCombo("5")
$*6::SendCombo("6")
$*7::SendCombo("7")
$*8::SendCombo("8")
$*9::SendCombo("9")

$*`::SendCombo("``")
$*-::SendCombo("-")
$*=::SendCombo("=")
$*[::SendCombo("[")
$*]::SendCombo("]")
$*\::SendCombo("\")
$*;::SendCombo(";")
$*'::SendCombo("'")
$*,::SendCombo(",")
$*.::SendCombo(".")
$*/::SendCombo("/")

$*F1::SendCombo("F1")
$*F2::SendCombo("F2")
$*F3::SendCombo("F3")
$*F4::SendCombo("F4")
$*F5::SendCombo("F5")
$*F6::SendCombo("F6")
$*F7::SendCombo("F7")
$*F8::SendCombo("F8")
$*F9::SendCombo("F9")
$*F10::SendCombo("F10")
$*F11::SendCombo("F11")
$*F12::SendCombo("F12")

$*Tab::SendCombo("Tab")
$*Space::SendCombo("Space")
$*Backspace::SendCombo("Backspace")
$*Delete::SendCombo("Delete")
$*Insert::SendCombo("Insert")
$*Home::SendCombo("Home")
$*End::SendCombo("End")
$*PgUp::SendCombo("PgUp")
$*PgDn::SendCombo("PgDn")
$*Up::SendCombo("Up")
$*Down::SendCombo("Down")
$*Left::SendCombo("Left")
$*Right::SendCombo("Right")

#HotIf

SendCombo(key) {
    global isComboTriggered

    isComboTriggered := true
    modifiers := "!"
    if GetKeyState("Ctrl", "P") {
        modifiers .= "^"
    }
    if GetKeyState("Shift", "P") {
        modifiers .= "+"
    }
    Send modifiers "{" key "}"
}

IsInTerminal() {
    return WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe alacritty.exe")
}

ctrlIsDown := false
altIsDown := false

#HotIf IsInTerminal()

Alt & Tab::AltTab
Ctrl & Tab::Send "^{Tab}"

*Alt:: {
    global ctrlIsDown

    Send "{Blind}{Ctrl DownR}"
    ctrlIsDown := true
}

*Ctrl:: {
    global altIsDown

    Send "{Blind}{Alt DownR}"
    altIsDown := true
}

#HotIf !IsInTerminal()

Alt & Space::Send "^{Space}"
Ctrl & Space::Send "!{Space}"

#HotIf

*Alt up:: {
    global ctrlIsDown

    if ctrlIsDown {
        ctrlIsDown := false
        Send "{Blind}{Ctrl Up}"
    } else {
        Send "{Blind}{Alt Up}"
    }
}

*Ctrl up:: {
    global altIsDown

    if altIsDown {
        altIsDown := false
        Send "{Blind}{Alt Up}"
    } else {
        Send "{Blind}{Ctrl Up}"
    }
}
