extends Control

var DEBUG_REQUESTS : bool = false
var DEBUG_UPDATES : bool = false

const URL_GRPCURL_LIN : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_x86_64.tar.gz"
const URL_GRPCURL_WIN : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_windows_x86_64.zip"
const URL_GRPCURL_OSX : String = "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_osx_x86_64.tar.gz"

const URL_300301_ENFORCER_LIN  : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-unknown-linux-gnu.zip"
const URL_300301_ENFORCER_WIN : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-pc-windows-gnu.zip"
const URL_300301_ENFORCER_OSX : String = "https://releases.drivechain.info/bip300301-enforcer-latest-x86_64-apple-darwin.zip"

const URL_BITCOIN_PATCHED_LIN : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu.zip"
const URL_BITCOIN_PATCHED_WIN : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-w64-msvc.zip"
const URL_BITCOIN_PATCHED_OSX : String = "https://releases.drivechain.info/L1-bitcoin-patched-latest-x86_64-apple-darwin.zip"

const URL_BITWINDOW_LIN : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-unknown-linux-gnu.zip"
const URL_BITWINDOW_WIN : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-pc-windows-msvc.zip"
const URL_BITWINDOW_OSX : String = "https://releases.drivechain.info/BitWindow-latest-x86_64-apple-darwin.zip"

const URL_THUNDER_LIN : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-unknown-linux-gnu.zip"
const URL_THUNDER_WIN : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-pc-windows-gnu.zip"
const URL_THUNDER_OSX : String = "https://releases.drivechain.info/L2-S9-Thunder-latest-x86_64-apple-darwin.zip"

# TODO Still a few places not using these const values that need updating
const BIN_NAME_ENFORCER_LIN : String = "enforcer-linux"
const BIN_NAME_ENFORCER_WIN : String = "enforcer-windows.exe"
const BIN_NAME_ENFORCER_OSX : String = "enforcer-osx"

const BIN_NAME_BITCOIN_LIN : String = "bitcoind"
const BIN_NAME_BITCOIN_WIN : String = "bitcoind.exe"
const BIN_NAME_BITCOIN_OSX : String = "bitcoind"

const BIN_NAME_THUNDER_LIN : String = "thunder-latest-x86_64-unknown-linux-gnu"
const BIN_NAME_THUNDER_WIN : String = "thunder-latest-x86_64-pc-windows-gnu.exe"
const BIN_NAME_THUNDER_OSX : String = "thunder-latest-x86_64-apple-darwin"

const BIN_NAME_BITWINDOW_LIN : String = "bitwindow"
const BIN_NAME_BITWINDOW_WIN : String = "bitwindow.exe"
const BIN_NAME_BITWINDOW_OSX : String = "bitwindow"

const URL_RELEASE_INFO: String = "https://releases.drivechain.info/"

# GRPCURL is released as a .zip for windows and .tar.gz for anything else:
const DOWNLOAD_PATH_GRPCURL_LIN_OSX = "user://downloads/l1/grpcurl.tar.gz"
const DOWNLOAD_PATH_GRPCURL_WIN = "user://downloads/l1/grpcurl.zip"

const DOWNLOAD_PROGRESS_UPDATE_DELAY : float = 0.1

@onready var http_download_grpcurl: HTTPRequest = $HTTPDownloadGRPCURL
@onready var http_download_enforcer: HTTPRequest = $HTTPDownloadEnforcer
@onready var http_download_bitcoin: HTTPRequest = $HTTPDownloadBitcoin
@onready var http_download_thunder: HTTPRequest = $HTTPDownloadThunder
@onready var http_download_bit_window: HTTPRequest = $HTTPDownloadBitWindow

var timer_l1_download_progress_update = null
# TODO this will be per L2 but for now just thunder
var timer_l2_download_progress_update = null

signal resource_grpcurl_ready
signal resource_bitcoin_ready
signal resource_bitwindow_ready
signal resource_enforcer_ready
signal resource_thunder_ready

signal resource_grpcurl_download_progress(percent : int)
signal resource_bitcoin_download_progress(percent : int)
signal resource_bitwindow_download_progress(percent : int)
signal resource_enforcer_download_progress(percent : int)
signal resource_thunder_download_progress(percent : int)

signal update_available_l1
signal update_available_launcher
signal update_available_l2_thunder
signal update_available_none

# Check on L1 software download progress periodically
func track_l1_download_progress() -> void:
	# Don't create a new timer if we already started tracking progress
	if timer_l1_download_progress_update != null:
		return
		
	# Create timer to check on donwload progress of L1 software
	timer_l1_download_progress_update = Timer.new()
	add_child(timer_l1_download_progress_update)
	timer_l1_download_progress_update.connect("timeout", check_l1_download_progress)
	
	timer_l1_download_progress_update.start(DOWNLOAD_PROGRESS_UPDATE_DELAY)


func check_l1_download_progress() -> void:
	# Display the current download progress for all L1 software
	
	var bytesBody : int = 0
	var bytesHave : int = 0
	var percent : int = 0
	
	var downloads_complete : bool = true
	
	# TODO ignore and don't show progress for L1s that are already downloaded
	
	# GRPCURL download progress
	bytesBody = $HTTPDownloadGRPCURL.get_body_size()
	bytesHave = $HTTPDownloadGRPCURL.get_downloaded_bytes()
	percent = int(bytesHave * 100 / bytesBody)
	resource_grpcurl_download_progress.emit(percent)
	
	if percent != 100:
		downloads_complete = false
	
	# Enforcer download progress
	bytesBody = $HTTPDownloadEnforcer.get_body_size()
	bytesHave = $HTTPDownloadEnforcer.get_downloaded_bytes()
	percent = int(bytesHave * 100 / bytesBody)
	resource_enforcer_download_progress.emit(percent)

	if percent != 100:
		downloads_complete = false

	# Bitcoin download progress
	bytesBody = $HTTPDownloadBitcoin.get_body_size()
	bytesHave = $HTTPDownloadBitcoin.get_downloaded_bytes()
	percent = int(bytesHave * 100 / bytesBody)
	resource_bitcoin_download_progress.emit(percent)
	
	if percent != 100:
		downloads_complete = false
	
	# BitWindow download progress
	bytesBody = $HTTPDownloadBitWindow.get_body_size()
	bytesHave = $HTTPDownloadBitWindow.get_downloaded_bytes()
	percent = int(bytesHave * 100 / bytesBody)
	resource_bitwindow_download_progress.emit(percent)
	
	if percent != 100:
		downloads_complete = false
	
	# If everything is done, stop the timer
	if downloads_complete:
		timer_l1_download_progress_update.queue_free()
	
	# TODO If user deletes everything during download, main window will need
	# to tell the resource downloader to stop & free the timer


# Check on L2 software download progress periodically
func track_l2_download_progress() -> void:
	# Don't create a new timer if we already started tracking progress
	if timer_l2_download_progress_update != null:
		return
		
	# Create timer to check on donwload progress of L2 software
	timer_l2_download_progress_update = Timer.new()
	add_child(timer_l2_download_progress_update)
	timer_l2_download_progress_update.connect("timeout", check_l2_download_progress)
	
	timer_l2_download_progress_update.start(DOWNLOAD_PROGRESS_UPDATE_DELAY)


func check_l2_download_progress() -> void:
	# Display the current download progress for all L2 software

	var bytesBody : int = 0
	var bytesHave : int = 0
	var percent : int = 0
	
	var downloads_complete : bool = true
	
	# TODO ignore and don't show progress for L2s that are already downloaded

	# Thunder download progress
	bytesBody = $HTTPDownloadThunder.get_body_size()
	bytesHave = $HTTPDownloadThunder.get_downloaded_bytes()
	percent = int(bytesHave * 100 / bytesBody)
	resource_thunder_download_progress.emit(percent)
	
	if percent != 100:
		downloads_complete = false
	
	# If everything is done, stop the timer
	if downloads_complete:
		timer_l2_download_progress_update.queue_free()
	
	# TODO If user deletes everything during download, main window will need
	# to tell the resource downloader to stop & free the timer


func have_grpcurl() -> bool:
	match OS.get_name():
		"Linux":
			if !FileAccess.file_exists("user://downloads/l1/grpcurl"):
				return false
		"Windows":
			if !FileAccess.file_exists("user://downloads/l1/grpcurl.exe"):
				return false
		"macOS":
			if !FileAccess.file_exists("user://downloads/l1/grpcurl"):
				return false
				
	resource_grpcurl_ready.emit()
	
	return true


func have_enforcer() -> bool:
	match OS.get_name():
		"Linux":
			if !FileAccess.file_exists(str("user://downloads/l1/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/", BIN_NAME_ENFORCER_LIN)):
				return false
		"Windows":
			if !FileAccess.file_exists(str("user://downloads/l1/bip300301-enforcer-latest-x86_64-pc-windows-gnu/", BIN_NAME_ENFORCER_WIN)):
				return false
		"macOS":
			if !FileAccess.file_exists(str("user://downloads/l1/bip300301-enforcer-latest-x86_64-apple-darwin/", BIN_NAME_ENFORCER_OSX)):
				return false
	
	resource_enforcer_ready.emit()
	
	return true


func have_bitcoin() -> bool:
	match OS.get_name():
		"Linux":
			if !FileAccess.file_exists(str("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu/", BIN_NAME_BITCOIN_LIN)):
				return false
		"Windows":
			if !FileAccess.file_exists(str("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-w64-msvc/Release/", BIN_NAME_BITCOIN_WIN)):
				return false
		"macOS":
			if !FileAccess.file_exists(str("user://downloads/l1/L1-bitcoin-patched-latest-x86_64-apple-darwin/", BIN_NAME_BITCOIN_OSX)):
				return false

	resource_bitcoin_ready.emit()
	
	return true


func have_bitwindow() -> bool:
	match OS.get_name():
		"Linux":
			if !FileAccess.file_exists(str("user://downloads/l1/bitwindow/", BIN_NAME_BITWINDOW_LIN)):
				return false
		"Windows":
			if !FileAccess.file_exists(str("user://downloads/l1/", BIN_NAME_BITWINDOW_WIN)):
				return false
		"macOS":
			if !FileAccess.file_exists(str("user://downloads/l1/bitwindow/bitwindow.app/Contents/MacOS/", BIN_NAME_BITWINDOW_OSX)):
				return false

	resource_bitwindow_ready.emit()
	return true


func have_thunder() -> bool:
	match OS.get_name():
		"Linux":
			if !FileAccess.file_exists(str("user://downloads/l2/", BIN_NAME_THUNDER_LIN)):
				return false
		"Windows":
			if !FileAccess.file_exists(str("user://downloads/l2/", BIN_NAME_THUNDER_WIN)):
				return false
		"macOS":
			if !FileAccess.file_exists(str("user://downloads/l2/", BIN_NAME_BITCOIN_OSX)):
				return false

	return true


func download_grpcurl() -> void:
	if have_grpcurl():
		return
		
	track_l1_download_progress()
		
	DirAccess.make_dir_absolute("user://downloads/")
	DirAccess.make_dir_absolute("user://downloads/l1")
		
	match OS.get_name():
		"Linux":
			$HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_LIN_OSX
			$HTTPDownloadGRPCURL.request(URL_GRPCURL_LIN)
		"Windows":
			$HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_WIN
			$HTTPDownloadGRPCURL.request(URL_GRPCURL_WIN)
		"macOS":
			$HTTPDownloadGRPCURL.download_file = DOWNLOAD_PATH_GRPCURL_LIN_OSX
			$HTTPDownloadGRPCURL.request(URL_GRPCURL_OSX)


func download_enforcer() -> void:
	if have_enforcer():
		return
	
	track_l1_download_progress()
	
	DirAccess.make_dir_absolute("user://downloads/")
	DirAccess.make_dir_absolute("user://downloads/l1")
	
	match OS.get_name():
		"Linux":
			$HTTPDownloadEnforcer.request(URL_300301_ENFORCER_LIN)
		"Windows":
			$HTTPDownloadEnforcer.request(URL_300301_ENFORCER_WIN)
		"macOS":
			$HTTPDownloadEnforcer.request(URL_300301_ENFORCER_OSX)


func download_bitcoin() -> void:
	if have_bitcoin():
		return
		
	track_l1_download_progress()
	
	DirAccess.make_dir_absolute("user://downloads/")
	DirAccess.make_dir_absolute("user://downloads/l1")

	match OS.get_name():
		"Linux":
			$HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_LIN)
		"Windows":
			$HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_WIN)
		"macOS":
			$HTTPDownloadBitcoin.request(URL_BITCOIN_PATCHED_OSX)


func download_bitwindow() -> void:
	if have_bitwindow():
		return

	track_l1_download_progress()
	
	DirAccess.make_dir_absolute("user://downloads/")
	DirAccess.make_dir_absolute("user://downloads/l1")

	match OS.get_name():
		"Linux":
			$HTTPDownloadBitWindow.request(URL_BITWINDOW_LIN)
		"Windows":
			$HTTPDownloadBitWindow.request(URL_BITWINDOW_WIN)
		"macOS":
			$HTTPDownloadBitWindow.request(URL_BITWINDOW_OSX)


func download_thunder() -> void:
	if have_thunder():
		return

	track_l2_download_progress()

	DirAccess.make_dir_absolute("user://downloads/")
	DirAccess.make_dir_absolute("user://downloads/l2")

	match OS.get_name():
		"Linux":
			$HTTPDownloadThunder.request(URL_THUNDER_LIN)
		"Windows":
			$HTTPDownloadThunder.request(URL_THUNDER_WIN)
		"macOS":
			$HTTPDownloadThunder.request(URL_THUNDER_OSX)


func extract_grpcurl() -> void:
	var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")
	
	var ret : int = -1 
	match OS.get_name():
		"Linux":
			ret = OS.execute("tar", ["-xzf", str(downloads_dir, "/grpcurl.tar.gz"), "-C", downloads_dir])
		"Windows":
			ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/grpcurl.zip")])
		"macOS":
			ret = OS.execute("tar", ["-xzf", str(downloads_dir, "/grpcurl.tar.gz"), "-C", downloads_dir])

	if ret != OK:
		printerr("Failed to extract grpcurl")
		return
		
	resource_grpcurl_ready.emit()


func extract_enforcer() -> void:
	var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

	var ret : int = -1
	match OS.get_name():
		"Linux":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/300301enforcer.zip")])
		"Windows":
			ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/300301enforcer.zip")])
		"macOS":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/300301enforcer.zip")])

	if ret != OK:
		printerr("Failed to extract enforcer")
		return

	# Rename extracted bin to remove version number
	if OS.get_name() == "Linux":
		var dir_files = DirAccess.get_files_at(str(downloads_dir, "/bip300301-enforcer-latest-x86_64-unknown-linux-gnu"))
		
		if dir_files.size() != 1:
			printerr("Failed to locate enforcer binary")
			return
		
		var rename_error = DirAccess.rename_absolute(str(downloads_dir, 
			"/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/", 
			dir_files[0]), str(downloads_dir, "/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/",
			BIN_NAME_ENFORCER_LIN))
			
		if rename_error != OK:
			printerr("Failed to rename enforcer")
			return
	elif OS.get_name() == "macOS":
		var dir_files = DirAccess.get_files_at(str(downloads_dir, "/bip300301-enforcer-latest-x86_64-apple-darwin"))
		
		if dir_files.size() != 1:
			printerr("Failed to locate enforcer binary")
			return
		
		var rename_error = DirAccess.rename_absolute(str(downloads_dir, 
			"/bip300301-enforcer-latest-x86_64-apple-darwin/", 
			dir_files[0]), str(downloads_dir, "/bip300301-enforcer-latest-x86_64-apple-darwin/",
			BIN_NAME_ENFORCER_OSX))
			
		if rename_error != OK:
			printerr("Failed to rename enforcer")
			return
	elif OS.get_name() == "Windows":
		var dir_files = DirAccess.get_files_at(str(downloads_dir, "/bip300301-enforcer-latest-x86_64-pc-windows-gnu"))
		
		if dir_files.size() != 1:
			printerr("Failed to locate enforcer binary")
			return
		
		var rename_error = DirAccess.rename_absolute(str(downloads_dir, 
			"/bip300301-enforcer-latest-x86_64-pc-windows-gnu/", 
			dir_files[0]), str(downloads_dir, "/bip300301-enforcer-latest-x86_64-pc-windows-gnu/",
			BIN_NAME_ENFORCER_WIN))
			
		if rename_error != OK:
			printerr("Failed to rename enforcer")
			return

	# Make executable for linux and mac
	if OS.get_name() == "Linux":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bip300301-enforcer-latest-x86_64-unknown-linux-gnu/", BIN_NAME_ENFORCER_LIN)])
		if ret != OK:
			printerr("Failed to mark enforcer executable")
			return
	elif OS.get_name() == "macOS":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bip300301-enforcer-latest-x86_64-apple-darwin/", BIN_NAME_ENFORCER_OSX)])
		if ret != OK:
			printerr("Failed to mark enforcer executable")
			return

	resource_enforcer_ready.emit()


func extract_bitcoin() -> void:
	var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

	var ret : int = -1
	match OS.get_name():
		"Linux":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/bitcoinpatched.zip")])
		"Windows":
			ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/bitcoinpatched.zip")])
		"macOS":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/bitcoinpatched.zip")])

	if ret != OK:
		printerr("Failed to extract bitcoin")
		return
		
	if OS.get_name() == "Linux":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/L1-bitcoin-patched-latest-x86_64-unknown-linux-gnu/bitcoind")])
		if ret != OK:
			printerr("Failed to mark bitcoin executable")
			return
			
	if OS.get_name() == "macOS":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/L1-bitcoin-patched-latest-x86_64-apple-darwin/bitcoind")])
		if ret != OK:
			printerr("Failed to mark bitcoin executable")
			return
			
	resource_bitcoin_ready.emit()


func extract_bitwindow() -> void:
	var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l1")

	var ret : int = -1
	match OS.get_name():
		"Linux":
			ret = OS.execute("unzip", ["-o", "-d", str(downloads_dir, "/bitwindow"), str(downloads_dir, "/bitwindow.zip")])
		"Windows":
			ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/bitwindow.zip")])
		"macOS":
			DirAccess.make_dir_absolute(str(downloads_dir, "/bitwindow"))
			ret = OS.execute("unzip", ["-o", "-d", str(downloads_dir, "/bitwindow"), str(downloads_dir, "/bitwindow.zip")])
			if ret == OK:
				ret = OS.execute("chmod", ["+x", str(downloads_dir, "/bitwindow/bitwindow.app/Contents/MacOS/bitwindow")])

	if ret != OK:
		printerr("Failed to extract bitwindow with return code: ", ret)
		return
		
	resource_bitwindow_ready.emit()


func extract_thunder() -> void:
	var downloads_dir = str(OS.get_user_data_dir(), "/downloads/l2")
	
	var ret : int = -1
	match OS.get_name():
		"Linux":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/thunder.zip")])
		"Windows":
			ret = OS.execute("tar", ["-C", downloads_dir, "-xf", str(downloads_dir, "/thunder.zip")])
		"macOS":
			ret = OS.execute("unzip", ["-o", "-d", downloads_dir, str(downloads_dir, "/thunder.zip")])

	if ret != OK:
		printerr("Failed to extract thunder")
		return

	if OS.get_name() == "Linux":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-cli-latest-x86_64-unknown-linux-gnu")])
		if ret != OK:
			printerr("Failed to mark thunder-cli executable")
			return
			
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-latest-x86_64-unknown-linux-gnu")])
		if ret != OK:
			printerr("Failed to mark thunder executable")
			return
	elif OS.get_name() == "macOS":
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-cli-latest-x86_64-apple-darwin")])
		if ret != OK:
			printerr("Failed to mark thunder-cli executable")
			return
		ret = OS.execute("chmod", ["+x", str(downloads_dir, "/thunder-latest-x86_64-apple-darwin")])
		if ret != OK:
			printerr("Failed to mark thunder executable")
			return
	resource_thunder_ready.emit()


func _on_http_download_grpcurl_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download grpcurl")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded grpcurl tarball")
	
	extract_grpcurl()


func _on_http_download_enforcer_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download enforcer")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded enforcer zip")
	
	extract_enforcer()


func _on_http_download_bitcoin_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download bitcoin")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded bitcoin zip")
	
	# TODO extract in thread so window doesn't freeze
	extract_bitcoin()


func _on_http_download_thunder_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download thunder")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded thunder zip")
	
	extract_thunder()


func _on_http_download_bit_window_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download bitwindow")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded bitwindow zip")
	
	# TODO extract in thread so window doesn't freeze
	extract_bitwindow()


func check_for_updates() -> void:
	DirAccess.make_dir_absolute("user://downloads/")
	$HTTPRequestDownloadReleasePage.request(URL_RELEASE_INFO)


func _on_http_download_release_page_request_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray) -> void:
	if result != OK:
		printerr("Failed to download release info")
		return 
	
	if DEBUG_REQUESTS:
		print("res ", result)
		print("code ", response_code)
		print("Downloaded release info")

	var parser = XMLParser.new()
	parser.open("user://downloads/releases.html")
	
	# TODO we are parsing but then ignoring the zip file download size. We 
	# could use the download size to make the progress bars more accurate
	
	# Set true if the release server has a more recently modified version
	var found_update_l1 : bool = false
	var found_update_l2_thunder : bool = false
	var found_update_launcher : bool = false
	# Set true if this is the first time checking release versions on server
	var first_version_check : bool = false
	
	# Loop through the parsed nodes of the release server's download page
	# Look for the lines with the software title, modified date, file size
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_TEXT:
			var node_data : String = parser.get_node_data()

			# Is this node the title of software we know? 
			if $"/root/GlobalSettings".settings_installed_software_info.has(node_data):
				var software_title : String = node_data
				if DEBUG_UPDATES:
					print("Found info for ", node_data, " from release page")
				
				# The next text node should be the modified date
				while parser.read() != ERR_FILE_EOF && parser.get_node_type() != XMLParser.NODE_TEXT:
					pass

				var software_modified_date : String = ""
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					software_modified_date = parser.get_node_data()
					if DEBUG_UPDATES:
						print("modified date: ", software_modified_date)

				if $"/root/GlobalSettings".settings_installed_software_info[software_title] == "":
					# If the modified date we have locally is empty then set it
					$"/root/GlobalSettings".settings_installed_software_info[software_title] = software_modified_date
					if DEBUG_UPDATES:
						print("Set modified date of ", software_title, " to ", software_modified_date)
					# If version info was empty, this is probably the first time checking
					first_version_check = true
				elif $"/root/GlobalSettings".settings_installed_software_info[software_title] != software_modified_date:
					# If the modified date we have locally is different than
					# on the server, send a signal that an update is ready
					if DEBUG_UPDATES:
						print("Found new version of ", software_title, " local: ", $"/root/GlobalSettings".settings_installed_software_info[software_title], " server: ", software_modified_date)
					
					# Emit signal depending on which software is outdated
					if software_title.contains("BitWindow") || software_title.contains("L1") || software_title.contains("enforcer"):
						found_update_l1 = true
					if software_title.contains("Thunder"):
						found_update_l2_thunder = true
					if software_title.contains("launcher"):
						found_update_launcher = true

				# TODO not using file size yet
				# The next text node should be the zip file size
				while parser.read() != ERR_FILE_EOF && parser.get_node_type() != XMLParser.NODE_TEXT:
					pass
				if parser.get_node_type() == XMLParser.NODE_TEXT:
					pass
					#print("Download size: ", parser.get_node_data())
	
	# If there are no updates available and this isn't the initial version
	# info sync, signal that
	if !first_version_check && !found_update_l1 && !found_update_l2_thunder && !found_update_launcher:
		update_available_none.emit()
	
	# If there are updates available signal them
	if found_update_l1:
		update_available_l1.emit()
	if found_update_l2_thunder:
		update_available_l2_thunder.emit()
	if found_update_launcher:
		update_available_launcher.emit()