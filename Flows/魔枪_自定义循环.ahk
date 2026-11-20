; ============================== 魔枪_自定义循环.ahk ==============================
; 可编辑的通用顺序循环。格式示例：4 R X Tab R*5 T*10
; 仅当 BNSR.exe 为前台窗口时发送按键。
; ================================================================================

global FlowInfo_MagicSpearCustom := {
    name: "魔枪-自定义循环",
    flowId: "魔枪_自定义循环",
    job: "魔枪",
    description: "在界面中输入按键顺序，支持 R*5 形式的重复次数"
}

InitFlowConfig_MagicSpearCustom() {
    global skillConfig, startMainLoopButton, triggerMode
    local configPath := GetFlowConfigPath("魔枪_自定义循环")

    if !FileExist(configPath)
        CreateDefaultFlowConfig_MagicSpearCustom(configPath)

    skillConfig.startButton := ReadConfigStr(configPath, "Global", "startButton", "F1")
    skillConfig.sequence := ReadConfigStr(configPath, "Global", "sequence", "E T*4 4 Tab 4 R*4 X V Z T*4 R*4")
    skillConfig.pressHold := ReadConfigInt(configPath, "Global", "pressHold", 35)
    skillConfig.pressDelay := ReadConfigInt(configPath, "Global", "pressDelay", 120)
    skillConfig.mainLoopDelay := ReadConfigInt(configPath, "Global", "mainLoopDelay", 180)
    triggerMode := ReadConfigInt(configPath, "Global", "triggerMode", 1)
    startMainLoopButton := skillConfig.startButton
}

CreateDefaultFlowConfig_MagicSpearCustom(configPath) {
    local configDir := A_ScriptDir "\Config"
    if !DirExist(configDir)
        DirCreate(configDir)

    local defaultConfig := "
    (LTrim
[Global]
startButton = F1
; 整条连续循环：E → T×4 → 4 → Tab → 4 → R×4 → X → V → Z → T×4 → R×4
sequence = E T*4 4 Tab 4 R*4 X V Z T*4 R*4
pressHold = 35
pressDelay = 120
mainLoopDelay = 180
; 0=按住运行，1=按一下开始、再按一下停止
triggerMode = 1
    )"
    FileAppend(defaultConfig, configPath, "UTF-8")
}

NormalizeSequence_MagicSpearCustom(sequenceText) {
    local normalized := StrReplace(sequenceText, "→", " ")
    normalized := StrReplace(normalized, ",", " ")
    normalized := StrReplace(normalized, "，", " ")
    normalized := StrReplace(normalized, "×", "*")
    while InStr(normalized, "  ")
        normalized := StrReplace(normalized, "  ", " ")
    return Trim(normalized)
}

ParseSequence_MagicSpearCustom(sequenceText) {
    local allowedKeys := Map(
        "R", "r", "T", "t", "F", "f", "Q", "q", "E", "e",
        "X", "x", "C", "c", "V", "v", "Z", "z",
        "1", "1", "2", "2", "3", "3", "4", "4",
        "TAB", "Tab", "LBUTTON", "LButton", "RBUTTON", "RButton"
    )
    local actions := []
    local normalized := NormalizeSequence_MagicSpearCustom(sequenceText)
    if (normalized = "")
        throw Error("循环不能为空")

    for token in StrSplit(normalized, " ") {
        if (token = "")
            continue

        local parts := StrSplit(token, "*")
        if (parts.Length > 2 || parts[1] = "")
            throw Error("无法识别的按键格式: " token)

        local keyName := StrUpper(parts[1])
        if !allowedKeys.Has(keyName)
            throw Error("暂不支持按键: " parts[1])

        local repeatCount := 1
        if (parts.Length = 2) {
            if !IsInteger(parts[2])
                throw Error("重复次数必须是整数: " token)
            repeatCount := Integer(parts[2])
            if (repeatCount < 1 || repeatCount > 50)
                throw Error("单个按键重复次数必须在 1 到 50 之间")
        }

        actions.Push({key: allowedKeys[keyName], count: repeatCount})
    }

    if (actions.Length = 0)
        throw Error("循环不能为空")
    return actions
}

ShouldContinueLoop_MagicSpearCustom(ThisHotkey) {
    global triggerMode, isToggleLoopActive
    if !WinActive("ahk_exe BNSR.exe")
        return false
    return triggerMode = 0 ? GetKeyState(ThisHotkey, "P") : isToggleLoopActive
}

StartSkillLoop_MagicSpearCustom(ThisHotkey) {
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

    local actions := ""
    try actions := ParseSequence_MagicSpearCustom(skillConfig.sequence)
    catch as e {
        isToggleLoopActive := false
        MsgBox("魔枪循环配置错误：`n" e.Message, "卡刀鸡")
        return
    }

    isMacroRunning := true
    ToolTip "魔枪自定义循环运行中"

    while ShouldContinueLoop_MagicSpearCustom(ThisHotkey) {
        for action in actions {
            Loop action.count {
                if !ShouldContinueLoop_MagicSpearCustom(ThisHotkey)
                    break
                SendEvent "{" action.key " down}"
                DllCall("Sleep", "UInt", skillConfig.pressHold)
                SendEvent "{" action.key " up}"
                DllCall("Sleep", "UInt", skillConfig.pressDelay)
            }
            if !ShouldContinueLoop_MagicSpearCustom(ThisHotkey)
                break
        }

        local delayRemaining := skillConfig.mainLoopDelay
        while delayRemaining > 0 && ShouldContinueLoop_MagicSpearCustom(ThisHotkey) {
            DllCall("Sleep", "UInt", 1)
            delayRemaining -= 1
        }
    }

    ToolTip
    isMacroRunning := false
    if triggerMode = 0
        isToggleLoopActive := false
}

SetTriggerMode_MagicSpearCustom(mode) {
    global triggerMode, isToggleLoopActive
    triggerMode := mode
    isToggleLoopActive := false
    WriteConfig(GetFlowConfigPath("魔枪_自定义循环"), "Global", "triggerMode", mode)
}

PickColors_MagicSpearCustom() {
    MsgBox("魔枪自定义顺序循环不需要取色。", "卡刀鸡")
}

GetFlowUI_MagicSpearCustom(guiObj) {
    global skillConfig, startMainLoopButton, triggerMode

    guiObj.AddText("xm y+10", "流派: 魔枪 - 自定义循环")
    guiObj.AddText("xm y+5", "启动按键:")
    local hotkeyList := ["F1", "F2", "F3", "F4", "F5", "F6", "XButton1", "XButton2"]
    local cboHotkey := guiObj.AddComboBox("x+5 yp w90 vSelectedHotkey_MagicSpear", hotkeyList)
    cboHotkey.Text := startMainLoopButton

    local rbHold := guiObj.AddRadio("xm y+5 vTriggerModeHold_MagicSpear checked" . (triggerMode = 0 ? 1 : 0), "长按模式")
    local rbToggle := guiObj.AddRadio("x+10 yp vTriggerModeToggle_MagicSpear checked" . (triggerMode = 1 ? 1 : 0), "开关模式")
    rbHold.OnEvent("Click", (*) => SetTriggerMode_MagicSpearCustom(0))
    rbToggle.OnEvent("Click", (*) => SetTriggerMode_MagicSpearCustom(1))

    guiObj.AddText("xm y+8", "循环（空格分隔）:")
    guiObj.AddEdit("xm y+3 w190 vSequence_MagicSpear", skillConfig.sequence)
    guiObj.AddText("xm y+3 w190 cGray", "示例: 4 R Tab R*5 T*10")
    guiObj.AddText("xm y+7", "按键间隔(ms):")
    guiObj.AddEdit("x+5 yp w55 Number vPressDelay_MagicSpear", skillConfig.pressDelay)
    guiObj.AddText("xm y+5", "循环间隔(ms):")
    guiObj.AddEdit("x+5 yp w55 Number vMainLoopDelay_MagicSpear", skillConfig.mainLoopDelay)

    local btnSave := guiObj.AddButton("xm y+12 w190 Default", "保存魔枪设置")
    btnSave.OnEvent("Click", SaveFlowSettings_MagicSpearCustom)
}

SaveFlowSettings_MagicSpearCustom(*) {
    global myGui, skillConfig, startMainLoopButton
    local configPath := GetFlowConfigPath("魔枪_自定义循环")
    local saved := myGui.Submit(false)
    local normalized := NormalizeSequence_MagicSpearCustom(saved.Sequence_MagicSpear)

    try ParseSequence_MagicSpearCustom(normalized)
    catch as e {
        MsgBox("循环没有保存：`n" e.Message, "卡刀鸡")
        return
    }

    local oldHotkey := startMainLoopButton
    WriteConfig(configPath, "Global", "startButton", saved.SelectedHotkey_MagicSpear)
    WriteConfig(configPath, "Global", "sequence", normalized)
    WriteConfig(configPath, "Global", "pressHold", 35)
    WriteConfig(configPath, "Global", "pressDelay", saved.PressDelay_MagicSpear)
    WriteConfig(configPath, "Global", "mainLoopDelay", saved.MainLoopDelay_MagicSpear)

    InitFlowConfig_MagicSpearCustom()
    SwitchHotkey(startMainLoopButton, oldHotkey, StartSkillLoop_MagicSpearCustom)
    MsgBox("魔枪循环已保存。", "卡刀鸡")
}

GetFlowModule_MagicSpearCustom() {
    return {
        name: "魔枪-自定义循环",
        flowId: "魔枪_自定义循环",
        job: "魔枪",
        InitConfig: InitFlowConfig_MagicSpearCustom,
        GetUI: GetFlowUI_MagicSpearCustom,
        StartLoop: StartSkillLoop_MagicSpearCustom,
        PickColors: PickColors_MagicSpearCustom,
        SaveSettings: SaveFlowSettings_MagicSpearCustom
    }
}
