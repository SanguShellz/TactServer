import socket
import os
from tendo import singleton
import better_haptic_player as bhaptics_player
import pystray
from PIL import Image
import threading
import psutil
import sys
import time
import configparser

# Redirect stderr to suppress unwanted console errors
sys.stderr = open(os.devnull, 'w')

# Ensure only a single instance runs
me = singleton.SingleInstance()

dname = os.path.dirname(sys.executable) if getattr(sys, 'frozen', False) else os.path.dirname(os.path.realpath(__file__))

# Initialize bHaptics Player
bhaptics_player.initialize()

# Load haptic patterns
tactlist_path = os.path.join(dname, '..', '..', 'Triggers', 'TriggerList.ini')
tactlist = configparser.ConfigParser()
tactlist.read(tactlist_path)

patterns = {}
pattern_groups = set()

for key, value in tactlist['TactPatterns'].items():
    pattern_name, location = value.split('_')
    patterns[f"{pattern_name}_{location}"] = os.path.join(dname, '../../Tact_Patterns', location, f'{pattern_name}.tact')
    pattern_groups.add(location)

def register_and_submit(pattern_name, pattern_group, intensity_scale, duration):
    """Registers and submits a haptic pattern with adjustable intensity and duration."""
    print(f"Registering and submitting {pattern_name} for {pattern_group} with intensity {intensity_scale} and duration {duration}")
    bhaptics_player.register(pattern_name, patterns[f"{pattern_name}_{pattern_group}"])
    bhaptics_player.submit_registered_with_option(
        pattern_name,
        "alt",
        scale_option={"intensity": intensity_scale, "duration": duration},
        rotation_option={"offsetAngleX": 0, "offsetY": 0}
    )

# Load server configuration
server_config_path = os.path.join(dname, 'ServerConfig.txt')

try:
    with open(server_config_path, 'r') as server_config:
        line = server_config.readline().strip()
        if not line:
            raise ValueError("Empty configuration file.")
        server_address, port_str = line.split()
        port = int(port_str)
except (FileNotFoundError, ValueError) as e:
    print(f"Error loading server configuration: {e}")
    sys.exit(1)

# Set up socket server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_socket.bind((server_address, port))
server_socket.listen(1)
print("Server is listening for connections...")

def handle_connections():
    """Handles incoming socket connections and triggers haptic feedback."""
    while True:
        try:
            client_socket, client_address = server_socket.accept()
            print(f"Connection from {client_address}")

            data = client_socket.recv(1024).decode('utf-8').strip()

            if data.count('_') >= 2:
                parts = data.rsplit('_', 2)
                pattern_info, intensity_str, duration_str = parts

                try:
                    intensity_scale = float(intensity_str)
                    duration = float(duration_str)
                except ValueError:
                    print(f"Error: Invalid intensity or duration value in message: {data}")
                    client_socket.close()
                    continue

                if pattern_info in patterns:
                    pattern_name, pattern_group = pattern_info.split('_', 1)
                    threading.Thread(target=register_and_submit, args=(pattern_name, pattern_group, intensity_scale, duration)).start()
                else:
                    print(f"Invalid pattern name or group: {data}")
            
            elif data == "Icon" or data == "Exit":
                Exit_App()

            client_socket.close()
        except Exception as e:
            print(f"Socket error: {e}")

# Start the socket server in a background thread
socket_thread = threading.Thread(target=handle_connections, daemon=True)
socket_thread.start()

def on_tray_click(icon, item):
    """Handles system tray menu interactions."""
    if item.text == 'Exit':
        Exit_App()

def Exit_App():
    """Forcefully kills all processes and exits the application."""
    print("Forcefully shutting down everything...")
    
    try:
        icon.stop()
    except Exception as e:
        print(f"Error stopping icon: {e}")

    try:
        server_socket.close()
    except Exception as e:
        print(f"Error closing server socket: {e}")

    os._exit(0)

def monitor_process(process_name):
    """Monitors if a given process stops running and exits the application."""
    for proc in psutil.process_iter(attrs=['name']):
        if proc.info['name'] == process_name:
            try:
                proc.wait()
                print(f"{process_name} has stopped. Exiting...")
                Exit_App()
            except psutil.NoSuchProcess:
                continue
    print(f"{process_name} not found at startup. Exiting...")
    Exit_App()

# Start process monitoring in a separate thread
monitor_thread = threading.Thread(target=monitor_process, args=("BhapticsPlayer.exe",), daemon=True)
monitor_thread.start()

# Set up system tray icon
image_path = os.path.join(dname, '..', 'images', 'bhaptics.png')
image = Image.open(image_path)
menu = pystray.Menu(pystray.MenuItem('Exit', on_tray_click))
icon = pystray.Icon("bhaptics_listener", image, menu=menu)

# Run system tray icon
icon.run()
