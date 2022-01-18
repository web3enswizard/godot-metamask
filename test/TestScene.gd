extends Control

onready var installed_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/InstalledCheckBox
onready var connected_check_box: CheckBox = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectedCheckBox
onready var connect_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/ConnectButton
onready var chain_id_line_edit: LineEdit = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/SwitchChainContainer/ChainIdLineEdit
onready var switch_chain_button: Button = $PanelSplitContainer/UserPanelContainer/MarginContainer/UserContainer/SwitchChainContainer/SwitchChainButton
onready var output_text_edit: TextEdit = $PanelSplitContainer/OutputPanelContainer/MarginContainer/VBoxContainer/OutputTextEdit

func _ready():
    # First check if Metamask is installed
    var installed = Metamask.has_metamask()
    installed_check_box.pressed = installed
    if not installed:
        _print("Metamask is not installed...")
        _fail_init()
        return
    _print("Metamask is installed...")
    # Check if Metamask is connected
    var connected = Metamask.is_network_connected()
    connected_check_box.pressed = connected
    if not connected:
        _print("Metamask is not connected...")
        _fail_init()
        return
    _print("Metamask is connected...")
    # Get information on Metamask connection
    _print("Current Chain: " + Metamask.current_chain())
    _print("Connected Account: " + str(Metamask.selected_account()))
    get_client_version()
    # Connect signals
# warning-ignore:return_value_discarded
    Metamask.connect("request_accounts_finished", self, "_on_Metamask_request_accounts_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("accounts_changed", self, "_on_Metamask_accounts_changed")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_changed", self, "_on_Metamask_chain_changed")
# warning-ignore:return_value_discarded
    Metamask.connect("switch_chain_finished", self, "_on_Metamask_switch_chain_finished")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_connected", self, "_on_Metamask_chain_connected")
# warning-ignore:return_value_discarded
    Metamask.connect("chain_disconnected", self, "_on_Metamask_chain_disconnected")
# warning-ignore:return_value_discarded
    Metamask.connect("message_received", self, "_on_Metamask_message_received")

func _print(text: String):
    output_text_edit.text += text + "\n"

func _fail_init():
    _print("Aborting remaining checks")
    connect_button.disabled = true

func get_client_version():
    Metamask.client_version()
    var result = yield(Metamask, "client_version_finished")
    # Explicitly break out the variables for clarity
    var version = result[0]
    var error = result[1]
    if error != null:
        # The call failed
        _print("Client Version Request Failed...")
        _print("Reason: " + error.message)
        return
    # The call succeeded
    _print("Client Version: " + version)

func _on_ConnectButton_pressed():
    _print("Attempting Request Accounts")
    connect_button.disabled = true
    Metamask.request_accounts()

func _on_Metamask_request_accounts_finished(success, error):
    connect_button.disabled = false
    if error != null:
        # The call failed
        _print("Accounts Request Failed...")
        _print("Reason: " + error.message)
        return
    # The call succeeded
    _print("Accounts Request Succeeded...")
    _print("Addresses:")
    for addr in success:
        _print("\t" + addr)

func _on_Metamask_accounts_changed(new_accounts):
    _print("User Accounts changed to " + new_accounts[0])

func _on_Metamask_chain_changed(new_chain_id):
    _print("User Connected Chain changed to " + new_chain_id)

func _on_Metamask_chain_connected(chain_id):
    _print("Metamask connected to chain: " + chain_id)

func _on_Metamask_chain_disconnected(error):
    _print("Metamask was disconnected from current chain")
    _print("Reason: " + error.message)

func _on_Metamask_message_received(message):
    _print("Metamask received message of type " + message.type)
    _print("Message : " + str(message.data))

func _on_SwitchChainButton_pressed():
    var new_chain_id = chain_id_line_edit.text
    _print("Attempting to Switch Chain to " + new_chain_id)
    switch_chain_button.disabled = true
    Metamask.switch_to_chain(new_chain_id)

func _on_Metamask_switch_chain_finished(error):
    switch_chain_button.disabled = false
    if error == null:
        _print("Chain Switch Succeeded...")
        return
    _print("Chain Switch Failed...")
    _print("Reason: " + error.message)
