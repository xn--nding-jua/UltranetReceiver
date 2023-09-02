/*************************************************************************************
Ultranet2SPDIF - Converter for Behringer Ultranet to SPDIF or other digital audio
v0.1.0 built on 02.09.2023
Dr.-Ing. Christian Nöding, christian@noeding-online.de
More infos at https://github.com/xn--nding-jua/UltranetReceiver
Destination-Hardware: Arduino MKR Vidor 4000, SAMD21 Cortex M0+ 32-Bit Microcontroller

Used arduino libraries:
- Ticker by Stefan Staub

Optional libraries based on preprocessor-switches:
- Ethernet by Various 2.0.1 (https://github.com/arduino-libraries/Ethernet)
- I2C_EEPROM Library by Rob Tillaart (https://github.com/RobTillaart/I2C_EEPROM) or Sparkfun External EEPROM-Library https://github.com/sparkfun/SparkFun_External_EEPROM_Arduino_Library
- 24LC256 EEPROM Library by wvmarle (https://github.com/wvmarle/24LC256) for 24AA/24LC Series
- PubSubClient by Nick OReily


 +------------+------------------+--------+------+-----------------+--------+-----------------------+---------+---------+--------+--------+----------+----------+-------------------------+
 | Pin number |  MKR  Board pin  |  PIN   | FPGA | Notes           | Peri.A |     Peripheral B      | Perip.C | Perip.D | Peri.E | Peri.F | Periph.G | Periph.H | Usage for KDEE_HiResPG  |
 |            |                  |        |      |                 |   EIC  | ADC |  AC | PTC | DAC | SERCOMx | SERCOMx |  TCCx  |  TCCx  |    COM   | AC/GLCK  |                         |
 |            |                  |        |      |                 |(EXTINT)|(AIN)|(AIN)|     |     | (x/PAD) | (x/PAD) | (x/WO) | (x/WO) |          |          |                         |
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 | 00         | D0               |  PA22  | G1   |                 |  *06   |     |     | X10 |     |   3/00  |   5/00  |* TC4/0 | TCC0/4 |          | GCLK_IO6 | Ultranet Ch 1-8
 | 01         | D1               |  PA23  | N3   |                 |  *07   |     |     | X11 |     |   3/01  |   5/01  |* TC4/1 | TCC0/5 | USB/SOF  | GCLK_IO7 | Ultranet Ch 9-16
 | 02         | D2               |  PA10  | P3   |                 |   10   | *18 |     | X02 |     |   0/02  |   2/02  |*TCC1/0 | TCC0/2 | I2S/SCK0 | GCLK_IO4 | 
 | 03         | D3               |  PA11  | R3   |                 |   11   | *19 |     | X03 |     |   0/03  |   2/03  |*TCC1/1 | TCC0/3 | I2S/FS0  | GCLK_IO5 | SPDIF out
 | 04         | D4               |  PB10  | T3   |                 |  *10   |     |     |     |     |         |   4/02  |* TC5/0 | TCC0/4 | I2S/MCK1 | GCLK_IO4 | MCLK
 | 05         | D5               |  PB11  | T2   |                 |  *11   |     |     |     |     |         |   4/03  |* TC5/1 | TCC0/5 | I2S/SCK1 | GCLK_IO5 | LRCLK
 | 06         | D6               |  PA20  | G16  |                 |  *04   |     |     | X08 |     |   5/02  |   3/02  |        |*TCC0/6 | I2S/SCK0 | GCLK_IO4 | SCLK
 | 07         | D7               |  PA21  | G15  |                 |  *05   |     |     | X09 |     |   5/03  |   3/03  |        |*TCC0/7 | I2S/FS0  | GCLK_IO5 | SDATA
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            |       SPI        |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 08         | MOSI             |  PA16  | F16  |                 |  *00   |     |     | X04 |     |  *1/00  |   3/00  |*TCC2/0 | TCC0/6 |          | GCLK_IO2 | 
 | 09         | SCK              |  PA17  | F15  |                 |  *01   |     |     | X05 |     |  *1/01  |   3/01  | TCC2/1 | TCC0/7 |          | GCLK_IO3 | 
 | 10         | MISO             |  PA19  | C16  |                 |   03   |     |     | X07 |     |  *1/03  |   3/03  |* TC3/1 | TCC0/3 | I2S/SD0  | AC/CMP1  | 
 +------------+------------------+--------+------+-----------------+--------------------+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            |       Wire       |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 11         | SDA              |  PA08  | C15  |                 |   NMI  | *16 |     | X00 |     |  *0/00  |   2/00  | TCC0/0 | TCC1/2 | I2S/SD1  |          | 
 | 12         | SCL              |  PA09  | B16  |                 |   09   | *17 |     | X01 |     |  *0/01  |   2/01  | TCC0/1 | TCC1/3 | I2S/MCK0 |          | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            |      Serial1     |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 13         | RX               |  PB23  | C11  |                 |   07   |     |     |     |     |         |  *5/03  |        |        |          | GCLK_IO1 | -> FPGA TxD
 | 14         | TX               |  PB22  | A13  |                 |   06   |     |     |     |     |         |  *5/02  |        |        |          | GCLK_IO0 | -> FPGA RxD
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 | 15         | A0 / DAC0        |  PA02  | C2   |                 |   02   | *00 |     | Y00 | OUT |         |         |        |        |          |          | 
 | 16         | A1               |  PB02  | C3   |                 |  *02   | *10 |     | Y08 |     |         |   5/00  |        |        |          |          | 
 | 17         | A2               |  PB03  | C6   |                 |  *03   | *11 |     | Y09 |     |         |   5/01  |        |        |          |          | 
 | 18         | A3               |  PA04  | D1   |                 |   04   | *04 |  00 | Y02 |     |         |   0/00  |*TCC0/0 |        |          |          | 
 | 19         | A4               |  PA05  | D3   |                 |   05   | *05 |  01 | Y03 |     |         |   0/01  |*TCC0/1 |        |          |          | 
 | 20         | A5               |  PA06  | F3   |                 |   06   | *06 |  02 | Y04 |     |         |   0/02  | TCC1/0 |        |          |          | 
 | 21         | A6               |  PA07  | G2   |                 |   07   | *07 |  03 | Y05 |     |         |   0/03  | TCC1/1 |        | I2S/SD0  |          | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            |       USB        |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 22         |                  |  PA24  |      | USB N           |   12   |     |     |     |     |   3/02  |   5/02  |  TC5/0 | TCC1/2 | USB/DM   |          | 
 | 23         |                  |  PA25  |      | USB P           |   13   |     |     |     |     |   3/03  |   5/03  |  TC5/1 | TCC1/3 | USB/DP   |          | 
 | 24         |                  |  PA18  |      | USB ID          |   02   |     |     | X06 |     |   1/02  |   3/02  |  TC3/0 | TCC0/2 |          | AC/CMP0  | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 | 25         | AREF             |  PA03  | B1   |                 |   03   |  01 |     | Y01 |     |         |         |        |        |          |          | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            | FPGA             |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 26         |                  |  PA12  |      | FPGA TDI        |   12   |     |     |     |     |  *2/00  |   4/00  | TCC2/0 | TCC0/6 |          | AC/CMP0  | 
 | 27         |                  |  PA13  |      | FPGA TCK        |   13   |     |     |     |     |  *2/01  |   4/01  | TCC2/1 | TCC0/7 |          | AC/CMP1  | 
 | 28         |                  |  PA14  |      | FPGA TMS        |   14   |     |     |     |     |   2/02  |   4/02  |  TC3/0 | TCC0/4 |          | GCLK_IO0 | 
 | 29         |                  |  PA15  |      | FPGA TDO        |   15   |     |     |     |     |  *2/03  |   4/03  |  TC3/1 | TCC0/5 |          | GCLK_IO1 | 
 | 30         |                  |  PA27  |      | FPGA CLK        |   15   |     |     |     |     |         |         |        |        |          | GCLK_IO0 | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 | 31         |                  |  PA28  | L16  | FPGA MB INT     |   08   |     |     |     |     |         |         |        |        |          | GCLK_IO0 | 
 | 32         |                  |  PB08  |      | LED_RED_BUILTIN |   08   |  02 |     | Y14 |     |         |   4/00  |  TC4/0 |        |          |          | -> LED
 | 33         |                  |  PB09  |      | SAM_INT_OUT     |  *09   |  03 |     | Y15 |     |         |   4/01  |  TC4/1 |        |          |          | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+
 |            | 32768Hz Crystal  |        |      |                 |        |     |     |     |     |         |         |        |        |          |          | 
 | 34         |                  |  PA00  |      | XIN32           |   00   |     |     |     |     |         |   1/00  | TCC2/0 |        |          |          | 
 | 35         |                  |  PA01  |      | XOUT32          |   01   |     |     |     |     |         |   1/01  | TCC2/1 |        |          |          | 
 +------------+------------------+--------+------+-----------------+--------+-----+-----+-----+-----+---------+---------+--------+--------+----------+----------+-------------------------+

EEPROM-Mapping
+-------------+------------------+
| Address     | Description      |
+-------------+------------------+
| 00h ... 01h | Version          |
+-------------+------------------+
| 02h ... 05h | IP-Address       |
+-------------+------------------+
| 06h ... ... | unused           |
+-------------+------------------+
| FAh ... FFh | MAC-Address      |
+-------------+------------------+

**************************************************************************************/

#include "FPGA_Loader.h"

void TimerSecondsFcn() {
  // toggle LED to show, that we are alive
  digitalWrite(LED_BUILTIN, !digitalRead(LED_BUILTIN));
}

Ticker TimerSeconds(TimerSecondsFcn, 1000, 0, MILLIS);

// ******************** SETUP FUNCTION ********************
void setup() {
  // general pin-defintions
  pinMode(LED_BUILTIN, OUTPUT);

  // load bitstream to FPGA and bring it up
	setup_fpga();

  // initialize UARTs
  Serial.begin(115200); // initialize USB-Serial
  Serial.setTimeout(1000); // Timeout for commands
  Serial1.begin(19200); // initialize Hardware-UART for communication with FPGA

  // initialize EEPROM
  #if UseEEPROM == 1
    eeprom.begin();
    if (!eeprom.isConnected())
    {
      Serial.println("Fatal Error: Can't find eeprom!!!");
      while(1);
    }

    #if ShowDebugOutput == 1
      // read installed EEPROM-size
      Serial.print("Found EEPROM of size ");
      Serial.print(eeprom.determineSize(false));
      Serial.println(" byte.");
    #endif

    // now load setup from eeprom
    eeprom.readBlock(0, (uint8_t *) &eeprom_config, sizeof(eeprom_config)); // read eeprom_config from EEPROM
    eeprom.readBlock(0xFA, (uint8_t *) &config.mac, sizeof(config.mac)); // copy MAC-address from EEPROM to config-struct

    // check if we have a valid IP-Address in eeprom_config
    if (!((eeprom_config.ip[0]==0) && (eeprom_config.ip[1]==0) && (eeprom_config.ip[2]==0) && (eeprom_config.ip[3]==0))) {
      // IP-Address seems to be OK, so copy IP-Address found in EEPROM to config-struct
      config.ip = eeprom_config.ip;
    }
  #endif

  #if UseEthernet == 1
    // initialize ethernet via W5500
    InitEthernet();

    #if UseMQTT == 1
      // connect to MQTT-server
      MQTT_init();
    #endif
  #endif

  // Start timers
  TimerSeconds.start();
}

// ******************** MAIN FUNCTION ********************
void loop() {
  #if UseEthernet == 1
    // handle ethernet clients
    HandleHTTPClients();
    HandleCMDClients();

    #if UseMQTT == 1
      HandleMQTT();
    #endif
  #endif

  // handle communication
  HandleUSBCommunication();
  HandleFPGACommunication();

  // update timer
  TimerSeconds.update();
}
