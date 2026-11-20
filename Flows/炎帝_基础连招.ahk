; ============================== 炎帝_基础连招.ahk ==============================
; 怀旧服新职业炎帝：适用于低等级教学阶段的基础连招。
; 当前循环：4 → R → X → C → V → Z → Tab → 4 → R → Z → R → R×5 → T×10。
; 仅当 BNSR.exe 为前台窗口时发送按键。
; ============================================================================

global FlowInfo_YandiBasic := {
    name: "炎帝-基础连招（低等级）",
    flowId: "炎帝_基础连招",
    job: "炎帝",
    description: "循环: 4→R→X→C→V→Z→Tab→4→R→Z→R→R×5→T×10"
}

InitFlowConfig_YandiBasic() {
    global skillConfig, startMainLoopButton, triggerMode
    local configPath := GetFlowConfigPath("炎帝_基础连招")

    if !FileExist(configPath)
        CreateDefaultFlowConfig_YandiBasic(configPath)

    skillConfig.startButton := ReadConfigStr(configPath, "Global", "startButton", "F1")
    skillConfig.pressHold := ReadConfigInt(configPath, "Global", "pressHold", 35)
    skillConfig.pressDelay := ReadConfigInt(configPath, "Global", "pressDelay", 90)
    skillConfig.spamDelay := ReadConfigInt(configPath, "Global", "spamDelay", 75)
    skillConfig.rRepeatCount := ReadConfigInt(configPath, "Global", "rRepeatCount", 5)
    skillConfig.tRepeatCount := ReadConfigInt(configPath, "Global", "tRepeatCount", 10)
    skillConfig.mainLoopDelay := ReadConfigInt(configPath, "Global", "mainLoopDelay", 80)
    triggerMode := ReadConfigInt(configPath, "Global", "triggerMode", 1)
    startMainLoopButton := skillConfig.startButton
}

CreateDefaultFlowConfig_YandiBasic(configPath) {
    local configDir := A_ScriptDir "\Config"
    if !DirExist(configDir)
        DirCreate(configDir)

    local defaultConfig := "
    (LTrim
[Global]
; 默认 F1；可在界面中修改
startButton = F1
; 每个技能之间的等待时间（毫秒）
pressHold = 35
pressDelay = 90
; T/R连续按键之间的等待时间（毫秒）
spamDelay = 75
; 每段连续按 R 的次数
rRepeatCount = 5
tRepeatCount = 10
; 完整连招后等待时间（毫秒）
mainLoopDelay = 80
; 0=按住运行，1=按一下开始、再按一下停止
triggerMode = 1
    )"
    FileAppend(defaultConfig, configPath, "UTF-8")
}

ShouldContinueLoop_YandiBasic(ThisHotkey) {
    global triggerMode, isToggleLoopActive
    if !WinActive("ahk_exe BNSR.exe")
        return false
    return triggerMode = 0 ? GetKeyState(ThisHotkey, "P") : isToggleLoopActive
}

StartSkillLoop_YandiBasic(ThisHotkey) {
    global isMainLoopPaused, skillConfig, isMacroRunning, triggerMode, isToggleLoopActive, toggleLock

    if isMainLoopPaused || !WinActive("ahk_exe BNSR.exe")
        return

    if triggerMode = 1 {
        if isToggleLoopActive {
            isToggleLoopActive := false
            isMacroRunning := false
            return
        }
        if toggleLock
            return
        toggleLock := true
        isToggleLoopActive := true
        KeyWait(ThisHotkey, "T0.08")
        toggleLock := false
        if !isToggleLoopActive
            return
    }

    isMacroRunning := true
    ToolTip "炎帝基础连招运行中"

    Loop {
        if !ShouldContinueLoop_YandiBasic(ThisHotkey)
            break

        ; 固定技能段
        for keyName in ["4", "r", "x", "c", "v", "z", "Tab", "4", "r", "z", "r"] {
            if !ShouldContinueLoop_YandiBasic(ThisHotkey)
                break
            SendEvent "{" keyName " down}"
            DllCall("Sleep", "UInt", skillConfig.pressHold)
            SendEvent "{" keyName " up}"
            DllCall("Sleep", "UInt", skillConfig.pressDelay)
        }

        ; 连续 R 5次
        Loop skillConfig.rRepeatCount {
            if !ShouldContinueLoop_YandiBasic(ThisHotkey)
                break
            SendEvent "{r down}"
            DllCall("Sleep", "UInt", skillConfig.pressHold)
            SendEvent "{r up}"
            DllCall("Sleep", "UInt", skillConfig.spamDelay)
        }

        ; 连续 T 10次
        Loop skillConfig.tRepeatCount {
            if !ShouldContinueLoop_YandiBasic(ThisHotkey)
                break
            SendEvent "{t down}"
            DllCall("Sleep", "UInt", skillConfig.pressHold)
            SendEvent "{t up}"
            DllCall("Sleep", "UInt", skillConfig.spamDelay)
        }

        local delayRemaining := skillConfig.mainLoopDelay
        while delayRemaining > 0 && ShouldContinueLoop_YandiBasic(ThisHotkey) {
            DllCall("Sleep", "UInt", 1)
            delayRemaining -= 1
        }
    }

    ToolTip
    isMacroRunning := false
    if triggerMode = 0
        isToggleLoopActive := false
}

SetTriggerMode_YandiBasic(mode) {
    global triggerMode, isToggleLoopActive
    triggerMode := mode
    if mode = 0
        isToggleLoopActive := false
    WriteConfig(GetFlowConfigPath("炎帝_基础连招"), "Global", "triggerMode", mode)
}

PickColors_YandiBasic() {
    MsgBox("炎帝低等级基础连招不需要取色。`n技能全部解锁后需要重新制作识别配置。", "卡刀鸡")
}

GetFlowUI_YandiBasic(guiObj) {
    global skillConfig, startMainLoopButton, triggerMode

    guiObj.AddText("xm y+10", "流派: 炎帝 - 基础连招（低等级）")
    guiObj.AddText("xm y+5", "启动按键:")
    local hotkeyList := ["XButton1", "XButton2", "F1", "F2", "F3", "F4", "F5", "F6"]
    local cboHotkey := guiObj.AddComboBox("x+5 yp w90 vSelectedHotkey_YandiBasic", hotkeyList)
    cboHotkey.Text := startMainLoopButton

    local rbHold := guiObj.AddRadio("xm y+5 vTriggerModeHold_YandiBasic checked" . (triggerMode = 0 ? 1 : 0), "长按模式")
    local rbToggle := guiObj.AddRadio("x+10 yp vTriggerModeToggle_YandiBasic checked" . (triggerMode = 1 ? 1 : 0), "开关模式")
    rbHold.OnEvent("Click", (*) => SetTriggerMode_YandiBasic(0))
    rbToggle.OnEvent("Click", (*) => SetTriggerMode_YandiBasic(1))

    guiObj.AddText("xm y+8", "按键间隔(ms):")
    guiObj.AddEdit("x+5 yp w55 Number vPressDelay_YandiBasic", skillConfig.pressDelay)
    guiObj.AddText("xm y+5", "循环间隔(ms):")
    guiObj.AddEdit("x+5 yp w55 Number vMainLoopDelay_YandiBasic", skillConfig.mainLoopDelay)
    guiObj.AddText("xm y+5", "T/R连按间隔(ms):")
    guiObj.AddEdit("x+5 yp w55 Number vSpamDelay_YandiBasic", skillConfig.spamDelay)

    local btnSave := guiObj.AddButton("xm y+12 w190 Default", "保存设置")
    btnSave.OnEvent("Click", SaveFlowSettings_YandiBasic)

    guiObj.AddText("xm y+12 w245", "4→R→X→C→V→Z→Tab→4→R→Z→R→R×5→T×10")
    guiObj.AddText("xm y+4 w245 cRed", "仅适合当前低等级教学阶段；升级后需重做")
}

SaveFlowSettings_YandiBasic(*) {
    global myGui, skillConfig, startMainLoopButton
    local configPath := GetFlowConfigPath("炎帝_基础连招")
    local saved := myGui.Submit(false)
    local oldHotkey := startMainLoopButton

    IniWrite(saved.SelectedHotkey_YandiBasic, configPath, "Global", "startButton")
    IniWrite(35, configPath, "Global", "pressHold")
    IniWrite(saved.PressDelay_YandiBasic, configPath, "Global", "pressDelay")
    IniWrite(saved.MainLoopDelay_YandiBasic, configPath, "Global", "mainLoopDelay")
    IniWrite(saved.SpamDelay_YandiBasic, configPath, "Global", "spamDelay")
    IniWrite(5, configPath, "Global", "rRepeatCount")
    IniWrite(10, configPath, "Global", "tRepeatCount")

    InitFlowConfig_YandiBasic()
    SwitchHotkey(startMainLoopButton, oldHotkey, StartSkillLoop_YandiBasic)
    MsgBox("炎帝低等级配置已保存。", "卡刀鸡")
}

GetFlowModule_YandiBasic() {
    return {
        name: "炎帝-基础连招（低等级）",
        flowId: "炎帝_基础连招",
        job: "炎帝",
        InitConfig: InitFlowConfig_YandiBasic,
        GetUI: GetFlowUI_YandiBasic,
        StartLoop: StartSkillLoop_YandiBasic,
        PickColors: PickColors_YandiBasic,
        SaveSettings: SaveFlowSettings_YandiBasic
    }
}
