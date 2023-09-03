#if UseEthernet == 1
  // includes for ethernet
  #include <Ethernet.h>

  struct{
    IPAddress ip = IPAddress(192, 168, 0, 42);
    uint8_t mac[6] = {0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
    uint8_t UseDHCP = 0;
  } config;

  EthernetServer server(80);
  EthernetServer cmdserver(23);

  #if UseMQTT == 1
    EthernetClient mqttnetworkclient;
    PubSubClient mqttclient(mqttnetworkclient);
  #endif

  void InitEthernet() {
    Ethernet.init(EthernetChipSelectPin);

    if (config.UseDHCP == 0) {
      // use static IP-address
      Ethernet.begin(config.mac, config.ip);
    }else{
      // use DHCP for gathering IP-address
      Ethernet.begin(config.mac);
    }
    
    if (Ethernet.hardwareStatus() == EthernetNoHardware) {
      #if ShowDebugOutput == 1
        Serial.println("Ethernet shield was not found.  Sorry, can't run without hardware. :(");
      #endif
      return;
    }

    if (Ethernet.linkStatus() == LinkOFF) {
      #if ShowDebugOutput == 1
        Serial.println("Ethernet cable is not connected.");
      #endif
    }

    // start the server
    server.begin();
    cmdserver.begin();
  }

  // Webserver
  void HandleHTTPClients() {
    // listen for incoming clients
    EthernetClient client = server.available();
    if (client) {
      // an HTTP request ends with a blank line
      bool currentLineIsBlank = true;
      if (client.available()) {
        char c = client.read();
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the HTTP request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
          // send a standard HTTP response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          client.println("Refresh: 5");  // refresh the page automatically every 5 sec
          client.println();
          client.println("<!DOCTYPE HTML>");
          client.println("<head><title>KDEE_HiResPG</title></head>");
          client.println("<html><center><font face=\"Arial\" size=\"6\">");
          client.println("<b>Ultranet Receiver " + String(versionstring) + "<br>built on " + String(compile_date) + "</b><br><br>");
          client.println("</font></center></html>");
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }

      // close the connection:
      client.stop();
    }
  }

  // Command-Server
  void HandleCMDClients() {
    // listen for incoming clients
    EthernetClient client = cmdserver.available();
    if (client) {
      // we have an active connection
      if (client.available()) {
        // we have unread data
        client.println(ExecuteCommand((client.readStringUntil('\n')))); // we are using both CR/LF but we have to read until LF
      }
    }
  }

  #if UseMQTT == 1
    void MQTT_init() {
      // configure MQTT-client
      mqttclient.setServer(mqtt_server, mqtt_serverport);
      mqttclient.setCallback(MQTT_callback);

      // wait for connection
      while (!mqttclient.connected()) {
        mqttclient.connect(mqtt_id);
        delay(500);
      }

      // subscribe to some topics
      uint8_t ch;
      for (ch=1; ch<=16; ch++) {
        mqttclient.subscribe((mqtt_topic_volume + String(ch)).c_str());
        mqttclient.subscribe((mqtt_topic_balance + String(ch)).c_str());
      }
      // here more topics can be subscribed
    }

    void HandleMQTT() {
      if (!mqttclient.connected()) {
        MQTT_init();
      }else{
        // connected to MQTT-server
        mqttclient.loop(); // process incoming messages
      }
    }

    void MQTT_callback(char* topic, byte* payload, unsigned int length) {
      // receive data
      payload[length] = '\0'; // null-terminate byte-array

      // process received message
      MQTT_processMSG(topic, String((char*)payload).toFloat());
    }

    void MQTT_processMSG(char* topic, float value) {
      // check if we have to react on this topic
      if (String(topic) == mqtt_topic_main_l) {
        audiomixer.mainVolumeLeft = (uint8_t)value;
        UpdateFPGAAudioEngine(0);
      }

      if (String(topic) == mqtt_topic_main_r) {
        audiomixer.mainVolumeRight = (uint8_t)value;
        UpdateFPGAAudioEngine(0);
      }

      uint8_t channel;
      for (channel=1; channel<=16; channel++) {
        if (String(topic) == (mqtt_topic_volume + String(channel))) {
          audiomixer.chVolume[channel-1] = (uint8_t)value;
          UpdateFPGAAudioEngine(channel);
          break;
        }
        
        if (String(topic) == (mqtt_topic_balance + String(channel))) {
          audiomixer.chBalance[channel-1] = (uint8_t)value;
          UpdateFPGAAudioEngine(channel);
          break;
        }
      }
      // TODO: here more topics can be created

      // send the received value back via MQTT
      //mqttclient.publish("ultranetreceiver/answer", String(value).c_str());
    }
  #endif
#endif

// USB-CMD-Receiver
void HandleUSBCommunication() {
  if (Serial.available() > 0) {
    Serial.println(ExecuteCommand(Serial.readStringUntil('\n'))); // we are using both CR/LF but we have to read until LF
  }
}

// FPGA-Receiver
void HandleFPGACommunication() {
  if (Serial1.available() > 0) {
    FPGA_Version = Serial1.read(); // at the moment only the FPGA-version will be transmitted every second
  }
}

// Command-Processor
String ExecuteCommand(String Command) {
  String Answer;

  if (Command.length()>2){
    // we got a new command. Lets find out what we have to do today...

    if (Command.indexOf("vol_main_l") > -1) {
      // received command "vol_main_l@yyy"
      audiomixer.mainVolumeLeft = Command.substring(Command.indexOf("@")+1).toInt();
      UpdateFPGAAudioEngine(0); // update main-channel
      Answer = "OK";
    }else if (Command.indexOf("vol_main_r") > -1) {
      // received command "vol_main_r@yyy"
      audiomixer.mainVolumeRight = Command.substring(Command.indexOf("@")+1).toInt();
      UpdateFPGAAudioEngine(0); // update main-channel
      Answer = "OK";
    }else if (Command.indexOf("vol_ch") > -1) {
      // received command "vol_chxx@yyy"
      uint8_t channel = Command.substring(6, Command.indexOf("@")).toInt();
      uint8_t value = Command.substring(Command.indexOf("@")+1).toInt();

      if ((channel>=1) && (channel<=16) && (value>=0) && (value<=100)) {
        audiomixer.chVolume[channel-1] = value;
        UpdateFPGAAudioEngine(channel);
        Answer = "OK";
      }else{
        Answer = "ERROR: Channel or value out of range!";
      }
    }else if (Command.indexOf("bal_ch") > -1) {
      // received command "bal_chxx@yyy"
      uint8_t channel = Command.substring(6, Command.indexOf("@")).toInt();
      uint8_t value = Command.substring(Command.indexOf("@")+1).toInt();

      if ((channel>=1) && (channel<=16) && (value>=0) && (value<=100)) {
        audiomixer.chBalance[channel-1] = value;
        UpdateFPGAAudioEngine(channel);
        Answer = "OK";
      }else{
        Answer = "ERROR: Channel or value out of range!";
      }
    #if UseEthernet == 1
    }else if (Command.indexOf("set_ip") > -1){
        // received command "set_ip@192.168.0.42"
        String ip_string = Command.substring(Command.indexOf("@")+1) + "."; // create ip_string = 192.168.0.42.
        uint8_t ip0 = split(ip_string, '.', 0).toInt();
        uint8_t ip1 = split(ip_string, '.', 1).toInt();
        uint8_t ip2 = split(ip_string, '.', 2).toInt();
        uint8_t ip3 = split(ip_string, '.', 3).toInt();

        config.ip = IPAddress(ip0, ip1, ip2, ip3);

        // reinitialize ethernet
        InitEthernet();

        Answer = "OK";
    }else if (Command.indexOf("set_dhcp") > -1){
      uint8_t value = Command.substring(Command.indexOf("@")+1).toInt();

      if ((value==0) || (value==1)) {
        config.UseDHCP = value;
        Answer = "OK";
      }else{
        Answer = "ERROR: Value out of range!";
      }
    #endif
    #if UseEEPROM == 1
    }else if (Command.indexOf("save_config") > -1){
      // received command "save_config"
      saveConfig();
      Answer = "OK";
    #endif
    }else if (Command.indexOf("info?") > -1){
      // send general information about this device
      #if UseEEPROM == 0
        Answer = "Ultranet Receiver " + String(versionstring) + "\nFPGA-Version v" + String(FPGA_Version) + "\nCompiled on " + String(compile_date) + "\nInfos: https://github.com/xn--nding-jua/UltranetReceiver";
      #else
        Answer = "Ultranet Receiver " + String(versionstring) + "\nFPGA-Version v" + String(FPGA_Version) + "\nCompiled on " + String(compile_date) + "\nInfos: https://github.com/xn--nding-jua/UltranetReceiver\nIP-Address = " + IpAddress2String(config.ip) + "\nMAC-Address = " + mac2String(config.mac);
      #endif
    }
  }else{
    // insufficient data -> ignore this
  }

  return Answer;
}

// FPGA-Transmitter
void SendDataToFPGA(uint8_t cmd, data_32b data) {
  byte SerialCommand[9];
  data_16b ErrorCheckWord;

  ErrorCheckWord.u16 = data.u8[0] + data.u8[1] + data.u8[2] + data.u8[3];

  SerialCommand[0] = 65;  // A = start of command
  SerialCommand[1] = cmd;
  SerialCommand[2] = data.u8[3]; // MSB of payload
  SerialCommand[3] = data.u8[2];
  SerialCommand[4] = data.u8[1];
  SerialCommand[5] = data.u8[0]; // LSB of payload
  SerialCommand[6] = ErrorCheckWord.u8[1]; // MSB
  SerialCommand[7] = ErrorCheckWord.u8[0]; // LSB
  SerialCommand[8] = 69;  // E =  end of command
  Serial1.write(SerialCommand, sizeof(SerialCommand));
}