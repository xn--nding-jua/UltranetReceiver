const char* versionstring = "v0.1.0";
const char compile_date[] = __DATE__ " " __TIME__;

// some compiler-switches for optional functions
#define ShowDebugOutput 0
#define UseEthernet 0
#define UseDHCP 1
#define UseEEPROM 0
#define UseMQTT 0

#if UseMQTT == 1
  // setup MQTT
  #define mqtt_id "UltranetReceiver"
  #define mqtt_server "192.168.0.xxx"
  #define mqtt_serverport 1883

  // at the end of this topic the channel-number will be added automatically
  const char* mqtt_topic_main_l = "ultranetreceiver/set/volume/main_l";
  const char* mqtt_topic_main_r = "ultranetreceiver/set/volume/main_r";
  const char* mqtt_topic_volume = "ultranetreceiver/set/volume/ch";
  const char* mqtt_topic_balance = "ultranetreceiver/set/balance/ch";
  // for more topics, you have to edit functions MQTT_init() to subscribe to
  // the topics and MQTT_processMSG() to do you things on receiving this topic
  // in Communication.ino
#endif

// general includes
#include <wiring_private.h>
#include "jtag.h"
#include "fpga.h"
#include "Ticker.h"

#if UseMQTT == 1
  #include <PubSubClient.h>
#endif

#if UseEthernet == 1
  // includes for ethernet
  #include <Ethernet.h>

  struct{
    IPAddress ip = IPAddress(192, 168, 0, 42);
    uint8_t mac[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
  } config;

  EthernetServer server(80);
  EthernetServer cmdserver(23);

  #if UseMQTT == 1
    EthernetClient mqttnetworkclient;
    PubSubClient mqttclient(mqttnetworkclient);
  #endif
#endif

#if UseEEPROM == 1
  // includes for I2C EEPROM with integrated MAC-address
  #include "Wire.h"
  #include "I2C_eeprom.h"
  #define EEPROM_Address 0x50
  I2C_eeprom eeprom(EEPROM_Address, I2C_DEVICESIZE_24LC16);

  struct{ // don't change order of struct! Just add variables or replace with same size!!!
    uint16_t Version = 0;
    IPAddress ip;
  } eeprom_config;
#endif

// defines for FPGA
uint8_t FPGA_Version = 0;

// variables
struct {
  uint8_t mainVolumeLeft;
  uint8_t mainVolumeRight;
  uint8_t chVolume[16];
  uint8_t chBalance[16];
}audiomixer;

// some helpful data-structures
typedef union 
{
    uint32_t u32;
    uint16_t u16[2];
    int16_t s16[2];
    uint8_t u8[4];
    float   f;
}data_32b;

typedef union 
{
    uint16_t u16;
    int16_t s16;
    uint8_t u8[2];
}data_16b;
