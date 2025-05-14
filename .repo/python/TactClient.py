import sys
import socket
import os

# Define server address (ensure this matches your actual configuration)
server_address = ("127.0.0.1", 12345)  # Update with actual IP and port if needed

# Create a socket to connect to the server
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

try:
    client_socket.connect(server_address)
except ConnectionRefusedError:
    print("Error: Could not connect to the server.")
    sys.exit(1)

# Check if a trigger message was provided as an argument
if len(sys.argv) > 1:
    trigger_message = sys.argv[1]  # Directly use the trigger message from VBS
    client_socket.sendall(trigger_message.encode('utf-8'))

# Close the connection
client_socket.close()
