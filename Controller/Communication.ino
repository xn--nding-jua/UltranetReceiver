#if UseEthernet == 1
  void InitEthernet() {
    Ethernet.init(7);

    #if UseDHCP == 0
      Ethernet.begin(config.mac, config.ip);
    #else
      Ethernet.begin(config.mac);
    #endif
    
    if (Ethernet.hardwareStatus() == EthernetNoHardware) {
      #if ShowDebugOutput == 1
        Serial.println("Ethernet shield was not found.  Sorry, can't run without hardware. :(");
      #endif
      while (true) {
        delay(1); // do nothing, no point running without Ethernet hardware
      }
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
        client.println(ExecuteCommand((client.readStringUntil('\n') + ","))); // add leading "," to the command
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
      uint8_t ch;

      // check if we have to react on this topic
      for (ch=0; ch<=16; ch++) { // ch==0==main
        if ((String(topic) == (mqtt_topic_volume + String(ch))) || (String(topic) == (mqtt_topic_balance + String(ch)))) {
          // obviously we have to do something

          // send the received value to the FPGA
          data_32b fpga_data;
          fpga_data.u32 = trunc(value*2.56f);

          if (String(topic) == (mqtt_topic_volume + String(ch))) {
            SendDataToFPGA(ch, fpga_data);
          }else if (String(topic) == (mqtt_topic_balance + String(ch))) {
            SendDataToFPGA(ch + 17, fpga_data);
          }

          // send the received value back via MQTT
          //mqttclient.publish("ultranetreceiver/answer", String(value).c_str());
          break;
        }
      }
      // TODO: here more topics can be created
    }
  #endif
#endif


// USB-CMD-Receiver
void HandleUSBCommunication() {
  if (Serial.available() > 0) {
    Serial.println(ExecuteCommand(Serial.readStringUntil('\n') + ",")); // we are using both CR/LF but we have to read until LF
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

    if ((Command.indexOf("vol_ch") > -1) || (Command.indexOf("bal_ch") > -1)) {
      // received command "vol_chxx@yyy"
      uint8_t channel = Command.substring(6, Command.indexOf("@")).toInt();
      uint8_t value = Command.substring(Command.indexOf("@")+1).toInt();

      if ((channel>=0) && (channel<=16)) // ch==0==main
      {
        data_32b fpga_data;

        // value is between 0...100. We will change this value to meet 8bit = 0..256 to make calculation in FPGA a bit easier
        // within FPGA we will do an integer-calculation like: ((AudioSampleData * ReceivedValueFromMicrocontroller) >> 8) = DataForDAC
        fpga_data.u32 = trunc(value*2.56f); // this value will be transmitted to FPGA and is available std_logic_vector(31 downto 0).

        if (Command.indexOf("vol_ch") > -1) {

          // TODO: at the moment we are sending values for left-channel. This has to be changed to general volume
          SendDataToFPGA(channel, fpga_data);
        }else if (Command.indexOf("bal_ch") > -1) {
          // TODO: at the moment we are sending values for right-channel. This has to be changed to balance
          SendDataToFPGA(channel + 17, fpga_data); // we have to take main in account, so +17
        }

        Answer = "OK";
      }else{
        Answer = "ERROR: Channel out of range!";
      }
    }else if (Command.indexOf("info?") > -1){
      // send general information about this device
      Answer = "Ultranet Receiver " + String(versionstring) + "\nCompiled on " + String(compile_date) + "\nInfos: https://github.com/xn--nding-jua/UltranetReceiver";
    }
  }
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