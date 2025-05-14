import subprocess

def close_process_by_name(process_name):
    try:
        # Run taskkill command to forcefully terminate the process
        subprocess.run(["taskkill", "/F", "/IM", process_name], check=True)
        print(f"Process {process_name} terminated successfully.")
    except subprocess.CalledProcessError as e:
        print(f"Error terminating process {process_name}: {e}")

if __name__ == "__main__":
    # Specify the name of the process you want to close
    target_process_name = "tactserver.exe"
    
    # Close the specified process
    close_process_by_name(target_process_name)
