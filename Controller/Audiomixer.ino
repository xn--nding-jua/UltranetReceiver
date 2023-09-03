uint8_t Saturate(uint8_t value, uint8_t max) {
  if (value>max) {
    return max;
  }else{
    return value;
  }
}

void InitAudiomixer() {
  audiomixer.mainVolumeLeft = 100; // set to 100%
  audiomixer.mainVolumeRight = 100; // set to 100%
  UpdateFPGAAudioEngine(0); // send main to FPGA

  uint8_t i;
  for (i=1; i<=16; i++) {
    audiomixer.chVolume[i-1] = 0; // set to 0%
    audiomixer.chBalance[i-1] = 50; // bring to center
    UpdateFPGAAudioEngine(i); // send values to FPGA
  }
}

void UpdateFPGAAudioEngine(uint8_t channel) {
  // send volume for left and right for desired channel

  data_32b fpga_data;
  float volume_left;
  float volume_right;

  // value is between 0...100. We will change this value to meet 8bit = 0..256 to make calculation in FPGA a bit easier
  // within FPGA we will do an integer-calculation like: ((AudioSampleData * ReceivedValueFromMicrocontroller) >> 8) = DataForDAC

  if (channel == 0) {
    // main has only left or right, no balance
    volume_left = audiomixer.mainVolumeLeft;
    volume_right = audiomixer.mainVolumeRight;
  }else{
    // channel 1..16
    volume_left = audiomixer.chVolume[channel-1] * Saturate((100 - audiomixer.chBalance[channel-1]) * 2, 100) / 100.0f;
    volume_right = audiomixer.chVolume[channel-1] * Saturate(audiomixer.chBalance[channel-1] * 2, 100) / 100.0f;
  }

  // send data to FPGA
  fpga_data.u32 = trunc(volume_left * 2.56f);
  SendDataToFPGA(channel, fpga_data);
  fpga_data.u32 = trunc(volume_right * 2.56f);
  SendDataToFPGA(channel + 17, fpga_data); // offset of 17, because we have 16 channels + main
}