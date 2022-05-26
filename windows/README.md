# Vertica-demo on Windows

It is very simple to set up vertica demo on windows. You just need to install both Windows Subsystem for Linux (WSL) and Docker Desktop.

## Windows Subsystem for Linux (WSL)

The Windows Subsystem for Linux lets developers run a GNU/Linux environment -- including most command-line tools, utilities, and applications -- directly on Windows, unmodified, without the overhead of a traditional virtual machine or dualboot setup.

We are more interested in WSL2 (Windows Subsystem for Linux version 2) which is a new version of the architecture that allows you to use Linux on top of Windows 10 natively (using a lightweight virtual machine) and replaces WSL.

### Prerequisites

You must be running Windows 10 version 2004 and higher (Build 19041 and higher) or Windows 11. If you are running an older build, follow the instructions here https://docs.microsoft.com/en-us/windows/wsl/install-manual

### Install WSL2

1. Open the command prompt or windows powershell as <b>administrator</b> and run the following command:

    ```
    wsl --install
    ```

    This command will enable the required optional components, download the latest Linux kernel, set WSL 2 as your default, and install a Linux distribution for you (Ubuntu by default, see below to change this).

    The first time you launch a newly installed Linux distribution, a console window will open and you'll be asked to wait for files to de-compress and be stored on your machine. All future launches should take less than a second.

2. Restart your machine to finish the WSL installation on Windows 10.

3. Wait for the ubuntu windows to open (if after 1 minute it does not open itself, you can doing yourself by typing ubuntu on the serch bar and then clicking on ubuntu icon). Set your username and password as required. Do not forget your password as you will need it to run admin privileged commands.


> **_NOTE:_** The above command only works if WSL is not installed at all, if you run wsl --install and see the WSL help text, please try running wsl --list --online to see a list of available distros and run wsl --install -d \<DistroName\> to install a distro. To uninstall WSL, see [unregister or uninstall a Linux distribution](https://docs.microsoft.com/en-us/windows/wsl/basic-commands#unregister-or-uninstall-a-linux-distribution).

the wsl cli has a lot of subcommands but exploring them is beyond the scope of this documentation. If you want to know more about any subcommands, visit [Basic commands for WSL](https://docs.microsoft.com/en-us/windows/wsl/basic-commands). The have more details about wsl install, go to [wsl install](https://docs.microsoft.com/en-us/windows/wsl/install)


## Docker Desktop

### Prerequisites

1. You should complete the wsl section first.
2. You need some free disk space to install and run Docker Desktop.

### Install Docker Desktop on Windows

1. Download Docker Desktop at [Docker Desktop Install](https://docs.docker.com/desktop/windows/install/).  It typically downloads to your Downloads folder.
2. Double-click Docker Desktop Installer.exe to run the installer.
3. Follow the instructions on the installation wizard to authorize the installer and proceed with the installation. You may be asked to sign out once the installation is done.
4. Start Docker Desktop from the Windows Start menu. From the Docker menu, select <b>Settings</b> > <b>General</b> and verify that the <b>Use WSL 2 based engine</b> is checked. If it is not the case, check it and click <b>Apply & Restart.</b>
5. That’s it! Now docker commands will work. You can use it form you ubuntu distribution.

## Import vertica-demo

Now you have everything you need to run vertica-demo. To try it:
1. Run the following comand to install <b>make</b>:
    ```
    sudo apt install make
    ```
2. Clone the vertica-demo repository:
    ```
    git clone https://github.com/vertica/vertica-demo.git
    ```
    go to the source directory with:
    ```
    cd vertica-demo
    ```
3. Now you can test vertica-demo by following the instruction at [README](https://github.com/vertica/vertica-demo#readme)