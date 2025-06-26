extends Node
## Manages API endpoint URLs for the game.

var hostname: String = ""


func get_base_ws_url() -> String:
	if OS.has_feature("web"):
		if not hostname:
			hostname = JavaScriptBridge.eval("window.location.hostname")
			print("Setting base ws url hostname: ", hostname)
		return "wss://" + hostname + "/gameserver"
		
	if ("--local" in OS.get_cmdline_args() 
			or OS.is_debug_build()
			or OS.get_environment("PR_ENV") == "local" 
			or OS.has_feature("editor")):
		#return "ws://localhost:8081/gameserver"
		return "wss://dev.platformracing.com/gameserver"
	elif "--dev" in OS.get_cmdline_args() or OS.get_environment("PR_ENV") == "dev":
		return "wss://dev.platformracing.com/gameserver"
	else:
		return "wss://platformracing.com/gameserver"
		

func get_base_url() -> String:
	if OS.has_feature("web"):
		if not hostname:
			hostname = JavaScriptBridge.eval("window.location.hostname")
			print("Setting base url hostname: ", hostname)
		return "https://" + hostname + "/api"
		
	if ("--local" in OS.get_cmdline_args()
			or OS.is_debug_build() 
			or OS.get_environment("PR_ENV") == "local" 
			or OS.has_feature("editor")):
		#return "http://localhost:8080"
		return "https://dev.platformracing.com/api"
	elif "--dev" in OS.get_cmdline_args() or OS.get_environment("PR_ENV") == "dev":
		return "https://dev.platformracing.com/api"
	else:
		return "https://platformracing.com/api"
