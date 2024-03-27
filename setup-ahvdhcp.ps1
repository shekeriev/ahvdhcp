# AHVDHCP Setup Script 
#
# Dimitar Zahariev, dimitar@zahariev.pro
#
# Used to create or remove an Alpine-based DHCP appliance for use in Hyper-V together with a NAT switch.
#
# 2022.03.05 - 2024.03.27+

function Create-HVDHCPSetup
{
    Write-Host ""
    Write-Host "AHVDHCP Setup Script"
    Write-Host ""
    Write-Host "Create the setup ..."
    Write-Host ""
    
    Write-Host "* Check if the NAT vSwitch exists" -NoNewline
    Get-VMSwitch "NAT vSwitch" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "* Nothing to do here. Exiting."
        break
    }
    else
    {
        Write-Host " ... not found."
    }
    
    Write-Host "* Check if the NAT Network exists" -NoNewline
    Get-NetNAT "NAT Network" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "* Nothing to do here. Exiting."
        break
    }
    else
    {
        Write-Host " ... not found."
    }
    
    Write-Host "* Check if the AHVDHCP virtual machine exists" -NoNewline
    Get-VM AHVDHCP -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "* Nothing to do here. Exiting."
        break
    }
    else
    {
        Write-Host " ... not found."
    }
    
    Write-Host ""
    Write-Host "* All prerequsites are met. Continue with the creation process ..."
    Write-Host ""
    
    Write-Host "* Create the NAT vSwitch" -NoNewline
    New-VMSwitch -SwitchName "NAT vSwitch" -SwitchType Internal | Out-Null
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Set IP address (192.168.99.1) on the virtual interface" -NoNewline
    New-NetIPAddress -IPAddress 192.168.99.1 -PrefixLength 24 -InterfaceAlias "vEthernet (NAT vSwitch)" | Out-Null
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Create the NAT Network (192.168.99.0/24)" -NoNewline
    New-NetNAT -Name "NAT Network" -InternalIPInterfaceAddressPrefix 192.168.99.0/24 | Out-Null
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Create the folder for the virtual machine at $Env:Programfiles\AHVDHCP" -NoNewline
    New-Item -Type Directory -Path "$Env:Programfiles\AHVDHCP" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Download the virtual machine template at $Env:Programfiles\AHVDHCP" -NoNewline
    Invoke-WebRequest -UseBasicParsing -Uri https://zahariev.pro/files/ahvdhcp.vhdx -OutFile "$Env:Programfiles\AHVDHCP\AHVDHCP.vhdx"
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Create the AHVDHCP virtual machine" -NoNewline
    New-VM -Name AHVDHCP -VHDPath "$Env:Programfiles\AHVDHCP\AHVDHCP.vhdx" -Generation 1 -SwitchName "NAT vSwitch" -MemoryStartupBytes 256MB | Set-VM -CheckpointType Production -AutomaticCheckpointsEnabled $false -PassThru | Set-VMMemory -DynamicMemoryEnabled $false | Out-Null
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host "* Start the AHVDHCP virtual machine" -NoNewline
    Start-VM -Name AHVDHCP
    if ($?)
    {
        Write-Host " ... done."
    }
    else
    {
        Write-Host " ... error. Exiting."
        break
    }
    
    Write-Host ""
    Write-Host "* All done. Do not forget to attach the virtual machines to the NAT vSwitch."
    
}

function Remove-HVDHCPSetup
{
    Write-Host ""
    Write-Host "AHVDHCP Setup Script"
    Write-Host ""
    Write-Host "Remove the setup ..."
    Write-Host ""
    
    Write-Host "* Check if the AHVDHCP VM exists" -NoNewline
    Get-VM "AHVDHCP" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "** Removing it" -NoNewline
        Stop-VM AHVDHCP -Force -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
        Remove-VM AHVDHCP -Force -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
        if ($?)
        {
            Write-Host " ... done."
        }
        else
        {
            Write-Host " ... error."
        }
    }
    else
    {
        Write-Host " ... not found."
        Write-Host "** Skipping it"
    }
    
    Write-Host "* Check if the AHVDHCP VM disk exists" -NoNewline
    Get-Item -Path "$Env:Programfiles\AHVDHCP\AHVDHCP.vhdx" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "** Removing it" -NoNewline
        Remove-Item -Path "$Env:Programfiles\AHVDHCP" -Recurse -Force -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
        if ($?)
        {
            Write-Host " ... done."
        }
        else
        {
            Write-Host " ... error."
        }
    }
    else
    {
        Write-Host " ... not found."
        Write-Host "** Skipping it"
    }
    
    Write-Host "* Check if the NAT Network exists" -NoNewline
    Get-NetNAT "NAT Network" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "** Removing it" -NoNewline
        Remove-NetNAT "NAT Network" -ErrorAction SilentlyContinue -Confirm:$false | Out-Null
        if ($?)
        {
            Write-Host " ... done."
        }
        else
        {
            Write-Host " ... error."
        }
    }
    else
    {
        Write-Host " ... not found."
        Write-Host "** Skipping it"
    }
    
    Write-Host "* Check if the NAT vSwitch exists" -NoNewline
    Get-VMSwitch "NAT vSwitch" -ErrorAction SilentlyContinue | Out-Null
    if ($?)
    {
        Write-Host " ... found."
        Write-Host "** Removing it" -NoNewline
        Remove-VMSwitch -SwitchName "NAT vSwitch" -ErrorAction SilentlyContinue -Force | Out-Null
        if ($?)
        {
            Write-Host " ... done."
        }
        else
        {
            Write-Host " ... error."
        }
    }
    else
    {
        Write-Host " ... not found."
        Write-Host "** Skipping it"
    }
}