import sys
sys.path.append('../')
import socket

# Define the server address and port
server_address = ('localhost', 12345)

# Create a socket
client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

# Connect to the server
client_socket.connect(server_address)

# Send the trigger message
trigger_message = "Icon"
client_socket.sendall(trigger_message.encode('utf-8'))

trigger_message2 = "Exit"
client_socket.sendall(trigger_message2.encode('utf-8'))



# Close the client socket
client_socket.close()
