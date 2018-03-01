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

### Demonstration Video Available on YouTube!
You view a demonstration video of this script in action here: [VegaFrontierMinerFix](https://www.youtube.com/watch?v=j9AGUGSHTs8 "Vega Frontier Miner Fix!")

## Instructions
Please take note that this script is functional, but it requies a little bit of special care (and patience).  I have created it for my own personal use but am more than happy to share it (obviously; because here you are).

1. Download the WDK for Windows 10,it will be required for the automatic installation of the drivers.
2. Download both the Adrenaline and Blockchain drivers, and run the executables.  **DO NOT INSTALL THEM** using the AMD provided GUI; simple extract them to the **DEFAULT** location, and move on to step three.
3. Download the Display Driver Uninstaller setup and extract it to the folder of your choosing.
4. Download the entire repo, and extract it to any folder you like (all files must remain grouped together though)
5. Modify the script at approximately line 241 and replace with the full path of the DDU executable that you extracted in step # 3.
6. Run the script, you will be required to run it as administrator (you can also pass in the -MinerPath parameter to tell the script to execute your mining software executable or batch file upon completion).
7. You will be prompted to enter your local Windows credentials.  You can examine the script to ensure that it is safe; you will be required to enter them in NTAccountName format (domain\username).  I have taken the liberty of having this pre-populate for you.
8. Once you press enter, the process of optimizing your VEGA setup will begin.
9. Expect your system to reboot once.
10.  A process window will display in the background showing you how long the process has taken thus far (in increments of 10 seconds).  The script window will count down from 20 once the process has completed.  All scheduled tasks and jobs should have already been removed from your system at this point.
11.  Your miner should have also began by now, if you specified the path to it when you initially launched the script with -Minerpath parameter.

## Usage
**Scenario 1 (*just fix the adapters, no further action - this is the default behaviour of the script if you right click + Run With Powershell*)**
`.\fix_vega.ps1`

**Scenario 2 (*launch your miner upon the completion of the entire operation; you may want to create a batch / CMD file to initiate the script with this option*)**
`.\fix_vega.ps1 -MinerPath <path_to_miner_executable>`


## Notes
1. There is no need to unplug your graphics cards to perform these steps.  Once everything is finished, you should be able to hash all of your Vegas at 2K/hs again.
2. You may need to loosen your Execution policy when executing the script.  If you get an error stating *cannot be loaded because running scripts
is disabled on this system*.... try running the following commands as Administrator. 

 **WARNING** *-- this will leave your machine able to execute any Powershell script without any additional security.  Do so at your own risk!*  

 `Set-ExecutionPolicy Unrestricted -Confirm:$false -Force`

 3. If you run into any problems or have any feedback, feel free to drop me an email at [iAm9001@outlook.com](mailto:iAm9001@outlook.com "iAm9001@outlook.com").
 

## Shameless donation plug
If you are feeling generous and this has stopped you from pulling out your hair, accidentally knocking over your mining rig by pulling the cords in and out of your Vegas countless times trying to figure out what is wrong, saved you from carpal tunnel from right clicking and tirelessly disabling and enabling your GPUs in vain, or from constantly having to jump into your registry to disable Crossfire on your ultra 13 strong Vega mining rig.... please feel free to send some love over to one of the addresses below :)

**Monero**: 41uW1Pk2bz7Bb2a6BN26RPGn6dZ7FtRxRT5sDJHcCiAnGfwNXNFhw9QNmV5RcbH6ryJPB6QWgdEiVLxzN7xhTN4wSufUprw

**Sumo**:
Sumoo1z1k84T5JsHeqizUF4ArCaZ1zLQGRUxQSAbzcFACs28TicFv4h8AVkjwiFm6QJvHekZW6oKFSdfpy6E6boXXbNZ7PXzFzt

**Electroneum**:
etnkNvVn1h1GHDaNAAR8DyeseuXjWnZR6CUSvFodvjcSCQWG3VM5GcFY93ni9k8a4MFEaV2ttNtgeeQPZwosJcvS4Fe6Uzx9Rp

**Intense**: iz6193iYrJf2ezNhsHVN5dcNdHH4ZcuChQJggkH2cm9y813qb4p5wYxKKYjgQjgpSt9vJZYFAqgFEDfnrCfUmmBz2RPqCe9Ft

**Turtle**:
TRTLuzuCx6QDXufeZXcPBH7USNUk2S3HKBNibjuyfRNufZ7v2qp2y3cR2Ww1Vyu2HoDtfLVY5EMh8JNahYgnMqYiFqcxcyhJRuB

**IPBC**:
bxciKVtwbzi1wcybdJtfseNd5GMGiLAa1JUtuxy3sDEoNbDbjwGf2Yv9K2xRNWGJVKcUJ2WFtWTukhqaBEboHaUy1P6abKCfV
