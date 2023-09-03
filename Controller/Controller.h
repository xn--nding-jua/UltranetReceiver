const char* versionstring = "v0.4.0";
const char compile_date[] = __DATE__ " " __TIME__;

// some compiler-switches for optional functions
#define ShowDebugOutput 0 // some additional string-output on serial (USB)
#define UseEthernet 0
#define UseEEPROM 0 // enable, if you want to use an EEPROM with integrated MAC-Address
#define UseMQTT 0
#define EthernetChipSelectPin 7 // enter correct CS-pin for connected ethernet-hardware

#if UseMQTT == 1
  // setup MQTT
  #define mqtt_id "UltranetReceiver" // name can be changed to fit your MQTT-environment
  #define mqtt_server "192.168.0.xxx" // enter the IP-address of your MQTT-server here
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

// defines for FPGA
uint8_t FPGA_Version = 0; // will be read from FPGA directly

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
