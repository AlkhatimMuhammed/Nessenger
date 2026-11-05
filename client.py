import socket
import sys
import threading

SERVER_IP = "tosdto.servebeer.com"  # Replace with your server IP if remote
PORT = 4444

def receive_messages(sock):
    while True:
        try:
            data = sock.recv(1024)
            if not data:
                print("\n[-] Connection closed by server.")
                break
            print(f"\rServer: {data.decode('utf-8', errors='ignore').strip()}\nClient > ", end="", flush=True)
        except:
            break

def main():
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    try:
        sock.connect((SERVER_IP, PORT))
        print(f"[+] Connected to server {SERVER_IP}:{PORT}")
        print("[*] Type your message and press Enter. Press Ctrl+C to exit.\n")

        recv_thread = threading.Thread(target=receive_messages, args=(sock,), daemon=True)
        recv_thread.start()

        while True:
            msg = input("Client > ")
            if not msg:
                continue
            sock.sendall((msg + "\n").encode('utf-8'))

    except KeyboardInterrupt:
        print("\n[!] Disconnecting from server...")
    finally:
        sock.close()
        sys.exit(0)

if __name__ == '__main__':
    main()
