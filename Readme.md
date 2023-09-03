

# UltranetReceiver

## Overview
This repository contains a FPGA-based receiver for audio-data based on Behringers Ultranet used in X32, P16-I, P16-M, Wing and more devices. Using a Arduino Vidor 4000 MKR FPGA-board with an Intel Cyclone 10LP, 16 Ultranet-Channels can be decoded.

The FPGA allows volume-control and left/right-balancing of all 16 channels into a single L/R-Signal that will be converted to SP/DIF and then to analog audio. Using a Behringer P16-I or other Ultranet-devices, it is possible to create a digital 16-channel mixer controlled by the SAMD21-microcontroller on the Vidor 4000.

## What's done so far?
* [x] FPGA-bitstream is included in Arduino-Sketch and will be uploaded to FPGA on each start via integrated SAMD21-controller
* [x] receiving of 2 streams of each 8-Channel-Ultranet (192kHz AES3-EBU-like) is tested and working (so all 16 channels can be decoded)
* [x] 2x 8-channel AES/EBU signal is converted to 2x I2S in FPGA and these I2S-signals are then converted to 16 individual std_logic_vectors (these are the audio-samples)
* [x] via cheap commercial available coaxial-SPDIF-converters audio-output works via arduino-pin
* [x] communication between FPGA and on-board SAMD21-microcontroller is established and both devices can exchange data with each other (multiple 32-bit unsigned-integers in a command-based way)
* [x] microcontroller has several interfaces to the world: USB (a simple ASCII-command-system), via ethernet (ASCII-command on port 23 like USB, MQTT, webbrowser)
* [x] working audio-mixer-functions for all 16 channels with left/right-balancing

## What has still to be done?
* [ ] test network-functions and MQTT
* [ ] webbrowser has to be implemented
* [ ] add SD-card recording (depends on time...) maybe the I2S stream could be send to the SAMD21 and an Arduino-SD-Card-Shield could be used here? Ideas?

## Commands
Via USB with 19200 baud (or via ethernet, if you connect an W55xx-chip to the microcontroller via I2C) a pretty simple ASCII-based command-system can be used to talk to the microcontroller. The following commands are implemented, yet:
* "vol_main_l@Y\n" -> set main-left-volume to 0...100
* "vol_main_r@Y\n" -> set main-right-volume to 0...100
* "vol_chX@Y\n" -> will set the volume of channel X to Y percent. X has to be between 1..16 and Y between 0...100
* "bal_chX@Y\n" -> will adjust the balance of this channel between left (Y=0) and right (Y=100). A value of Y=50 will place this channel in the middle
* "set_ip@xxx.xxx.xxx.xxx\n" -> set static IP-address to desired value.
* "set_dhcp@x\n" -> enables (x=1) or disables (x=0) DHCP
* "save_config\n" -> stores static IP-address to EEPROM
* "info?\n" -> will return some status information

Ethernet- or EEPROM-related commands are available, when ethernet or EEPROM is enabled in preprocessor (see Controller.h).

## Hardware
Only a few components are necessary:
* MagJack SI-52008-F for interfacing with UltraNet
* AM26LV32CD RS-422-IC-Interface Quad Diff
* cheap TOSLINK/SPDIF audio-converter can be connected to Arduino directly
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
* open the subfolder "Controller" and run the batch-file "update_fpga_bitstream.bat". The FPGA-bitstream will be converted into bitstream.h to be uploaded with Arduino-sketch
* Within Arduino IDE Select "Arudino MKR Vidor 4000" as destination
* Click "Sketch" -> "Upload" to upload the FPGA-bitstream to the connected SAMD21-controller (MKR Vidor 4000)

Arduino 2.x and later will update the bitstream.h automatically. Older versions of Arduino has to be closed and reopened to get the changes on bitstream.h

### Optional:
* Click "Sketch" -> "Exort Compiled Binary"
* copy the file "build\arduino.samd.mkrvidor4000\Controller.ino.bin" into the folder "Uploader"
* run the file "Update_FPGA.bat" to upload the new firmware without an installed Arduino IDE
