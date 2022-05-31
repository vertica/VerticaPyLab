# Vertica-demo on Windows

To set up vertica-demo, install Windows Subsystem for Linux (WSL) and Docker Desktop.

## Windows Subsystem for Linux (WSL)

The Windows Subsystem for Linux lets developers run a GNU/Linux environment on Windows. This guide and vertica-demo use WSL 2, which allows you to use Linux on top of Windows natively using a lightweight virtual machine.

### Prerequisites

You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11. If you are running an older build, follow the instructions here https://docs.microsoft.com/en-us/windows/wsl/install-manual

### Install WSL 2

1. To install WSL 2, open the command prompt or Windows PowerShell as <b>Administrator</b> and run the following command. This command enables the required components, downloads the latest Linux kernel, sets WSL 2 as your default, and installs a Linux distribution (Ubuntu by default):

    ```
    wsl --install
    ```
    
> **_NOTE:_** The above command only works if WSL is not installed. If you run wsl --install and see the WSL help text, try running wsl --list --online to see a list of available Linux distributions and run wsl --install -d \<DistroName\> to install one. To uninstall WSL, see [unregister or uninstall a Linux distribution](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#unregister-or-uninstall-a-linux-distribution).

2. Reboot your machine.

3. If it does not start by itself, start Ubuntu from the Start menu. The first time you start it, a console window will open asking you to wait for files to decompress and be stored on your machine. All future launches should take less than a second.

4. Set your username and password.

## Docker Desktop

### Prerequisites

Install WSL 2.

### Install and Configure Docker Desktop

1. Download and run the [Docker Desktop installer](https://docs.docker.com/desktop/windows/install/).
2. Start Docker Desktop from the Windows Start menu.
3. Click the gear icon on the top right and navigate to the <b>General</b> tab.
4. Verify that the <b>Use WSL 2 based engine</b> option is checked. If not, check it and click <b>Apply & Restart.</b>

## Import vertica-demo

1. Start Ubuntu from the Start menu.
2. Install <b>make</b>:
    ```
    sudo apt install make
    ```
3. Clone the vertica-demo repository:
    ```
    git clone https://github.com/vertica/vertica-demo.git
    ```
4. Navigate to the cloned directory:
    ```
    cd vertica-demo
    ```
5. Run vertica-demo. For instructions, see the [README](https://github.com/vertica/vertica-demo#readme).
