

# UltranetReceiver

## Overview
This repository contains a FPGA-based receiver for audio-data based on Behringers Ultranet used in X32, P16-I, P16-M, Wing and more devices. Using a Arduino Vidor 4000 MKR FPGA-board with an Intel Cyclone 10LP, 16 Ultranet-Channels can be decoded.

It is planned to use the FPGA to mix all 16 channels into a single L/R-Signal that will be converted to SP/DIF and then to analog audio. Using a cheap Behringer P16-I it will be possible to create a digital 16-channel mixer controlled by the SAMD21-microcontroller on the Vidor 4000.

**This project is right at the beginning (Alpha State) and is still under development. Feel free to support me!**

## What's done so far?
* FPGA-bitstream can be programmed via SAMD21-controller using Arduino IDE
* Receiver for stereo AES/EBU-signals seems to work
* 16-channel AES/EBU signal is converted to I2S
* I2S-signal is converted to 16 individual std_logic_vectors (samples)
* for testing two samples are converted to I2S for a CS4344-DAC and into stereo SP/DIF

## What has to be done?
* testing of ultranet-receiver
* implementing multiplicator for volume-control of each channel
* implement audio-routing functions
* add SD-card recording(?)
* add controlling via network and USB (Arduino-code for SAMD21-controller)

## Hardware
Only a few components are necessary:
* MagJack SI-52008-F for interfacing with UltraNet
* AM26LV32CD RS-422-IC-Interface Quad Diff
* Optional: CS4344 Audio-DAC with I2S-Interface

UltraNet-Channel 1-8 and 9-16 are connected to the SI-52008-F via Ethernet-Cable. TD+ and TD- of each pair is then connected to the AM26LV32CD-quad-diff-line-driver-IC that is connected via two wires to the Arduino MKR Vidor 4000.

Optional a CS4344 Audio DAC can be attached to the Vidor 4000 using four wires:
* MCLK (Masterclock)
* LRCLK (Word-Clock or LR-Clock)
* SCLK (Bitclock or Serial-Clock)
* DATA (Serial-Data)

An SP/DIF or TOSLINK-Adapter can be attached to the Vidor as well to test the outputs without a DAC. That's it for now.

Connectors at the Vidor 4000:
* D0 = UltraNet Ch1-8 (from AM26LV32CD)
* D1 = UltraNet Ch9-16 (from AM26LV32CD)
* D3 = SP/DIF output (to TOSLINK adapter)
* D4 = MCLK (I2S to CS4344)
* D5 = LRCLK (I2S to CS4344)
* D6 = SCLK (I2S to CS4344)
* D7 = SDATA (I2S to CS4344)


## How to compile?
### FPGA
* Open Intel Quartus Prime Lite Edition (no license required)
* Open UltranetReceiver-project
* Click "Processing" -> "Start Compilation..."

### Arduino
* close Arduino IDE, if still opened. Otherwise the bitstream.h will no update correctly!
* go into the subfolder "FPGA_Loader" and run the batch-file "update_fpga_bitstream.bat"
* Open Arduino IDE 2.x
* Select "Arudino MKR Vidor 4000" as destination
* Click "Sketch" -> "Upload" to upload the FPGA-bitstream to the SAMD21-controller

### Optional:
* Click "Sketch" -> "Exort Compiled Binary"
* copy the file "build\arduino.samd.mkrvidor4000\FPGA_Loader.ino.bin" into the folder "Uploader"
* run the file "Update_FPGA.bat"
