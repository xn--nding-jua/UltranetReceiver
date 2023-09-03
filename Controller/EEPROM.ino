#if UseEEPROM == 1

// includes for I2C EEPROM with integrated MAC-address
#include "Wire.h"
#include "I2C_eeprom.h"
#define EEPROM_Address 0x50
I2C_eeprom eeprom(EEPROM_Address, I2C_DEVICESIZE_24LC16);

struct{ // don't change order of struct! Just add variables or replace with same size!!!
  uint16_t Version = 0;
  IPAddress ip;
  uint8_t UseDHCP = 0;
} eeprom_config;

void InitEEPROM() {
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
}

void readConfig() {
  // load config from EEPROM
  eeprom.readBlock(0, (uint8_t *) &eeprom_config, sizeof(eeprom_config)); // read eeprom_config from EEPROM

  // check if we have a valid IP-Address in eeprom_config
  if (!((eeprom_config.ip[0]==0) && (eeprom_config.ip[1]==0) && (eeprom_config.ip[2]==0) && (eeprom_config.ip[3]==0))) {
    // IP-Address seems to be OK, so copy IP-Address found in EEPROM to config-struct
    config.ip = eeprom_config.ip;
  }
  config.UseDHCP = eeprom_config.UseDHCP;

  // load MAC-address from EEPROM
  eeprom.readBlock(0xFA, (uint8_t *) &config.mac, sizeof(config.mac)); // copy MAC-address from EEPROM to config-struct
}

void saveConfig() {
  eeprom_config.ip = config.ip;
  eeprom_config.UseDHCP = config.UseDHCP;
  eeprom.writeBlock(0, (uint8_t *) &eeprom_config, sizeof(eeprom_config));
}

#endif
