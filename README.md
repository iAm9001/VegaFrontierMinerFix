# VegaFrontierMinerFix
This is a Powershell script that automates the process of fixing the Vega Frontier hashrate drop issue; namely the process of having to uninstall the drivers via DDU, install the Adrenaline drivers, disabling Crossfire, disabling the display adapters, installing the Blockchain drivdrs, disabling crossfire, etc.

## Requirements

### WDK for WIndows 10

<https://docs.microsoft.com/en-us/windows-hardware/drivers/download-the-wdk>

### Display Driver Uninstaller

<https://www.wagnardsoft.com>

### AMD Adrenaline Drivers

<https://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-Adrenalin-Edition-18.1.1-Release-Notes.aspx>

### AMD Blockchain Drivers
<https://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-Crimson-ReLive-Edition-Beta-for-Blockchain-Compute-Release-Notes.aspx>

### Vega Frontier Edition Graphics Cards
This script is intended for usage to fix the dreaded hash rate drop with the Vega Frontier Edition cards from AMD.  They are the most powerful (as far as affordability goes) graphics cards for mining Cryptonight, but if you need to restart your computer or it crashes.... you may spend countless hours fiddling around with reinstallation of drivers.

## Instructions
Please take note that this script is functional, but it requies a little bit of special care (and patience).  I have created it for my own personal use but am more than happy to share it (obviously; because here you are).

1. Download the WDK for Windows 10,it will be required for the automatic installation of the drivers.
2. Download both the Adrenaline and Blockchain drivers, and run the executables.  **DO NOT INSTALL THEM** using the AMD provided GUI; simple extract them to the **DEFAULT** location, and move on to step three.
3. Download the Display Driver Uninstaller setup and extract it to the folder of your choosing.
4. Download the Powershell script in this repo, and place it in the folder of your choosing.
5. Modify the script at approximately line 182 and replace the path with the full path of the DDU executable that you extracted in step # 3.
`
    cleanVegaDrivers -ddu 'C:\crypto\ddu\Display Driver Uninstaller.exe'`
6. Run the script, you will be required to run it as administrator.
7. You will be prompted to enter your local Windows credentials.  You can examine the script to ensure that it is safe; you will be required to enter them in NTAccountName format (domain\username).  I have taken the liberty of having this pre-populate for you.
8. Once you press enter, DDU will uninstall all of your AMD graphcis drivers, and initiate a restart.
9. Upon restarting, you will need to log back into WIndows, and start a new Powershell instance as Administrator.  *Note:  This step will be automated in the future, but for now it must be done manually*
10. Once the Powershell instance has loaded, type `get-job`.  Take note of the *suspended* job called **VegaFixWorkflow**, and type `resume-job -Id <Job Id>*`
11. Go grab a coffee, the process of installing the Adrenaline drivers, Blockchain drivers, disabling of Crossfire and Ulps, disabling and enabling the display adapters in the appropriate sequence will begin.  *Note:*  There is no indicator to the status of the completion level of the scripts operation.  I am once again working on this, and just happy to have the process nearly completely automated.

## Notes
There is no need to unplug your graphics cards to perform these steps.  Once everything is finished, you should be able to hash all of your Vegas at 2K/hs again.

## Shameless donation plug
If you are feeling generous and this has stopped you from pulling out your hair, accidentally knocking over your mining rig by pulling the cords in and out of your Vegas countless times trying to figure out what is wrong, saved you from carpal tunnel from right clicking and tirelessly disabling and enabling your GPUs in vain, or from constantly having to jump into your registry to disable Crossfire on your ultra 13 strong Vega mining rig.... please feel free to send some love over to one of the addresses below :)

**Monero**: 41uW1Pk2bz7Bb2a6BN26RPGn6dZ7FtRxRT5sDJHcCiAnGfwNXNFhw9QNmV5RcbH6ryJPB6QWgdEiVLxzN7xhTN4wSufUprw

**Sumo**:
Sumoo1z1k84T5JsHeqizUF4ArCaZ1zLQGRUxQSAbzcFACs28TicFv4h8AVkjwiFm6QJvHekZW6oKFSdfpy6E6boXXbNZ7PXzFzt

**Electroneum**:
etnkNvVn1h1GHDaNAAR8DyeseuXjWnZR6CUSvFodvjcSCQWG3VM5GcFY93ni9k8a4MFEaV2ttNtgeeQPZwosJcvS4Fe6Uzx9Rp

**Intense**: iz6193iYrJf2ezNhsHVN5dcNdHH4ZcuChQJggkH2cm9y813qb4p5wYxKKYjgQjgpSt9vJZYFAqgFEDfnrCfUmmBz2RPqCe9Ft
