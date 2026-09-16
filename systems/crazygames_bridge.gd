extends Node
var gameplay_active := false

func gameplay_start() -> void:
	if gameplay_active: return
	gameplay_active = true
	call_sdk("game.gameplayStart()")

func gameplay_stop() -> void:
	if not gameplay_active: return
	gameplay_active = false
	call_sdk("game.gameplayStop()")

func happy_time() -> void:
	call_sdk("game.happytime()")

func call_sdk(expression: String) -> void:
	if not OS.has_feature("web"): return
	var code := "if(window.cgReady){window.cgReady.then(()=>window.CrazyGames.SDK.%s).catch(()=>{});}" % expression
	JavaScriptBridge.eval(code, true)

