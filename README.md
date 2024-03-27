# AHVDHCP

This is a tiny Alpine-based Hyper-V DHCP appliance.

Created initially for internal (in my lab) use. Later, I decided to share it with the students in my courses. It could be helpful to any newcomers in Hyper-V who want to achieve a working state of their virtual network quickly and easily.

One of the older and publicly available versions is referred to here: <https://github.com/shekeriev/suse-tu/tree/main/virtual-machines#troubleshooting>

## Reasoning

TL;DR: An easy, automated, and complete solution that offers NAT and DHCP capabilities.

As part of the Hyper-V installation on Windows 10 and Windows 11, a Default Switch is created. While it provides DHCP functionalities to virtual machines and allows easier access to the Internet, it has its drawbacks. A few of those are:

 - the absence of control over its behavior - address range, address assignments, etc.

 - no option for port forwarding

In addition, in case something happens with it (got missing), it is not that easy to recreate it.

As a generic solution to the above, we can create a basic NAT switch that will get us covered. The only drawback is that it won't have any DHCP functionalities. So, we should manually configure the network settings of our virtual machines. To address this, in addition to the switch, we can create a small virtual machine that will act as a DHCP server.

If you do not need DHCP, you can create just the switch and take care of the rest by yourself (for example, manual setup of IP addresses on the virtual machines). Check this link <https://zahariev.pro/files/hyper-v-nat-switch.html> and follow the instructions there.

Of course, we can go with the complete solution - switch + DHCP virtual machine. We can do it either manually or use an automated solution.

## What is included

This is a complete solution with automated installation and removal procedures. You get:
 - a NAT switch

 - a DHCP appliance

## Installation

The installation procedure is quite simple. You must follow these steps:

- open a PowerShell session with **Run as administrator** option (right click on the icon and select the option)

- navigate to the root folder

```powershell        
cd c:\
```

- change temporary the execution policy (you must confirm when asked)

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

- download the setup script

```powershell
Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/shekeriev/ahvdhcp/main/setup-ahvdhcp.ps1 -OutFile setup-ahvdhcp.ps1
```

- source the script (this will make all the functions there available)

```powershell
. .\setup-ahvdhcp.ps1
```

- now, to create the switch and the special VM that will act as a DHCP server, execute

```powershell
Create-AHVDHCPSetup
```

As a result of the above, we will end up with a new switch (NAT vSwitch) and a tiny virtual machine (AHVDHCP) that will act as DHCP server to the virtual machines that are connected to the switch. The default network settings are:

- network - 192.168.99.0/24
- default gateway - 192.168.99.1
- DHCP server - 192.168.99.2
- address range - 192.168.99.100 - 192.168.99.199

The credentials for the tiny virtual machine are **root** / **Parolka1!**.

Don't forget to link the virtual machines (either existing or new) to the newly created switch (NAT vSwitch).

## Removal

The removal procedure is even simpler. You must follow these steps:

- open a PowerShell session with **Run as administrator** option (right click on the icon and select the option)

- navigate to the root folder

```powershell        
cd c:\
```

- change temporary the execution policy (you must confirm when asked)

```powershell
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

- source the script (this will make all the functions there available)

```powershell
. .\setup-ahvdhcp.ps1
```

- now, to delete the artefacts, execute this

```powershell
Remove-AHVDHCPSetup
```
