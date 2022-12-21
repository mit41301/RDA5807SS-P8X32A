'' File: RDA5807SS_Driver.spin{{Notes:1) The RDA5807SS has two I2C Device Addresses,    I2CAddr_Continue = %00100000_0 --> Continue write/read data to/from device's registers without sending the Registers Name    I2CAddr_Standard = %00100001_0 --> Standard write/read data to/from device's registers 2) Initialize(pinSDA,pinSCL) Initialize the connection between the Radio and Propeller; reset,turn on the radio3 ) Methods explanation:   Initialize(pinSDA, pinSCL)                    ' Initilize the FM Radio Connected status                           passInfo(ConfigRegsAddr, StatusAddr)          ' Store the FM Radio Configure Register and Status information to @ConfigRegsAddr, @StatusAddr                            MuteSW                                        ' Turn the Mute On & Off                            MuteOff                                       ' Mute Off                            MuteOn                                        ' Mute On                            StereoSW                                      ' Turn Stereo On &  Off                          Stereo                                        ' Stereo On                            Mono                                          ' Mono On(Stereo Off)                            BassSW                                        ' Turn Bass On & Off                             BassOn                                        ' Turn Bass On                            BassOff                                       ' Turn Bass Off                            PowerSW                                       ' Power Switch, Turn Power On & Off                            PowerOn                                       ' Power On                            PowerOff                                      ' Power Off                            Reset                                         ' Reset the Radio                            SeekUp                                        ' Seek Up                            SeekDown                                      ' Seek Down                            FreqUp : Frequency                            ' Frequency + space(100kHz,200kHz,50kHz,25kHz)                            FreqDown : Frequency                          ' Frequency - space(100kHz,200kHz,50kHz,25kHz)                            FreqSet(Frequency) : Chan                     ' Set Frequency                            CheckFreq : Frequency                         ' Check the Frequency from the Radio                            Chnnl2Freq(Channel) : Frequency               ' Convert the Chnnl information to Frequency                            Freq2Chnnl(Frequency) : Channel               ' Convert the Frequency information to Chnnl                            BandSet(BandMode)                             ' Set the Band Mode:Europe_USA,Japan, Japan_wide                            SpaceSet(Spacing)                             ' space(100k Hz,   200k Hz,   50k Hz,   25k Hz)                          TuneEnable                                    ' Tune Enable                            TuneDisable : flagSTC                         ' Tune Disable                            CheckSTC : flagSTC                            ' Check Seek or Tune Complete Flag                            CheckSF : flagSF                              ' Check Seek Failed Flag                            CheckST : flagST                              ' Check Stereo Indicate Flag                            CheckChannel : ReadChannel                    ' Check the Chnnl Information read from the Radio                            CheckRSSI : RSSI                              ' Check the Received Signal Stength Indication                            CheckStationTrue : flagStationTrue            ' Check the Station True indication flag                           CheckReady : flagReady                        ' Check the Radio Ready flag                            VolumeUp : Volume                             ' Volume Up                            VolumeDown : Volume                           ' Volume Down                            VolumeSet(Level) : Volume                     ' Set the Volume Level                            CheckVolume : Volume                          ' Check Current Volume                            SeekThreshold(SeekTH) : result                ' Set the Seek Threhold                            STCIntEnable                                  ' Seek or Tune Complete Interrupt Enable                            STCIntDisable                                 ' Seek or Tune Complete Interrupt Enable   WrReg_Standard                                ' I2C Write Data to FM Radio Register in I2C Standard mode                           RdReg_Standard                                ' I2C Read Data from FM Radio Register in I2C Standard mode   WrRequest(DeviceAddr, RegAddr)                ' Set the Register Address to Write or Read       }}con' ----------------------------[ Band Mode ]------------------------------                                               US_Eu      = %00                              ' Band Select 87~108 MHzJapan      = %01                              ' Band Select 76~91  MHzJapanWide  = %10                              ' Band Select 76~108 MHz '----------------------------[ I2C Address ]------------------------------I2CAddr_Continue = %0010000_0                  ' I2C Addr %0010_000(R/W) Continue Read and WriteI2CAddr_Standard = %0010001_0                  ' I2C Addr %0010_001(R/W) I2C Standard Read and Writeobj   I2C : "MiniI2C"   varbyte Band                                      ' Band Select  US_Eu(87~108 MHz), Japan(76~91 MHz), JapanWide(76~108 MHz)      long Space                                     ' Channel Spacing 25k,50k,100k,200k Hzword ConfigRegs[5]                             ' Registers $02, $03, $04, $05, $06  // $06 reserve for future useword Status[4]                                 ' Registers $0A, $0B, $0C, $0D      //  $0C,$0D reserve for future use             ''--------------[ Application Programs ]----------------------pub Initialize(pinSDA,pinSCL) I2C.Initialize(PinSDA,PinSCL)                                     ' Initialize FM I2C connected  pins wordmove(@ConfigRegs,@Default,5)                                  ' Copy the Default set to ConfigRegs wordfill(@Status,0,4)  Reset                                                            ' Reset the Radio  PowerOn                                                          ' Power on  BandSet(US_Eu)                                                   ' Set the Band(87....108M Hz)  SpaceSet(100_000)                                                ' Set the space to 100k(0.1 MHz)  VolumeSet(2)                                                     ' Set the Volume Level to 2  CheckFreq                                                        ' Check current frequencypub passInfo(ConfigRegsAddr,StatusAddr)  '' copy the ConfigRegs and Status informations to the Addresses given by Caller  RdReg_Standard                                 ' Updated RAM  wordmove(ConfigRegsAddr,@ConfigRegs,5)  '             \_______________________________the RAM Address, does not need to add "@"   wordmove(StatusAddr,@Status,4)  '             \________________________________the RAM Address, does not need to add "@"  pub MuteSW'' Mute Switch, turn the Mute On or Off   if (ConfigRegs[0] & %0100_0000_0000_0000) == 1      MuteOff   else      MuteOn  pub MuteOff                                                           '' Disable Mute   ConfigRegs[0]:= ConfigRegs[0] | %0100_0000_0000_0000   WrReg_Standard   pub MuteOn                                                           '' Soft Mute         ConfigRegs[0]:= ConfigRegs[0] & %1011_1111_1111_1111      WrReg_StandardPub StereoSW'' Switch between Stereo and Mono   if ConfigRegs[0] & %0010_0000_0000_0000 == %0010_0000_0000_0000      Stereo   else      Mono                 pub Stereo                                                      '' Switch to Stereo     ConfigRegs[0]:= ConfigRegs[0] & %1101_1111_1111_1111   WrReg_Standard    pub Mono                                                             '' Switch to Mono    ConfigRegs[0]:= ConfigRegs[0] | %0010_0000_0000_0000      WrReg_Standardpub BassSW'' Bass Switch, turn Bass On or Off   if (ConfigRegs[0] & %0001_0000_0000_0000) == %0001_0000_0000_0000      BassOff   else      BassOn        pub BassOn                                                           '' Bass On    ConfigRegs[0]:= ConfigRegs[0] | %0001_0000_0000_0000          WrReg_Standard    pub BassOff                                                        '' Bass Off          ConfigRegs[0]:= ConfigRegs[0] & %1110_1111_1111_1111          WrReg_Standardpub PowerSW'' Power Switch, Power On or Off   if ConfigRegs[0] & %0000_0000_0000_0001 == %0000_0000_0000_0001       PowerOff   else       PowerOn      pub PowerOn                                                          '' Power On    ConfigRegs[0]:= ConfigRegs[0] | %0000_0000_0000_0001    WrReg_Standard    FreqSet(CheckFreq)           pub PowerOff                                                         '' Power Off     ConfigRegs[0]:= ConfigRegs[0] & %1111_1111_1111_1110    WrReg_Standard               pub Reset                                                            '' Soft Reset the FM Radio    ConfigRegs[0]:= ConfigRegs[0] | %0000_0010_0000_0000          ' Set the Reset bit    WrReg_Standard    ConfigRegs[0]:= ConfigRegs[0] & %1111_1101_1111_1111          ' Clear the Reset bitpub SeekUp                                                        '' Auto Seek station      ConfigRegs[0]:= ConfigRegs[0] | %0000_0011_0000_0000    WrReg_Standard     ConfigRegs[0]:= ConfigRegs[0] & %1111_1100_1111_1111   ' repeat until CheckSTC | CheckSF       pub SeekDown                                                         '' Auto Seek station   ConfigRegs[0]:= ConfigRegs[0] | %0000_0001_0000_0000    WrReg_Standard    ConfigRegs[0]:= ConfigRegs[0] & %1111_1110_1111_1111  ' repeat until CheckSTC | CheckSF    pub FreqUp : Frequency'' Freqency + Spacing Hz                                                                                           RdReg_Standard                                                  ' Get currence Frequence                                                     Frequency:= CheckFreq +  Space                                  ' Calculate the Frequency information   FreqSet(Frequency)                                              ' Set the Frequency   Frequency:= CheckFreq                                           ' Read the Frequency and update to ConfigRegspub FreqDown : Frequency'' Freqency - Spacing Hz                                                                                                     RdReg_Standard                                                  ' Get currence Frequence                                              Frequency:=  CheckFreq - Space                                  ' Calculate the Frequency information   FreqSet(Frequency)                                              ' Set the Frequency   Frequency:= CheckFreq                                           ' Read the Frequency and update to ConfigRegspub FreqSet(Frequency): Chan                                                '' Set the Frequency Hz   Chan := Freq2Chnnl(Frequency)     TuneEnable                                                       ' Enable Tune    ConfigRegs[1]:=(ConfigRegs[1] & %0000_0000_0011_1111)| (Chan << 6)  WrReg_Standard  TuneDisable                                                                                                                                                              pub CheckFreq : Frequency'' Return the Current Frequency Information '' And update the Channel Information to FM Regsister and Propeller RAM                                                           Frequency:= Chnnl2Freq(CheckChannel)                                 ' Read the Current channel information  pub Chnnl2Freq(Channel): Frequency'' Converte the Channel to Frequency  if (ConfigRegs[1] & %0000_0000_0000_1100)== 0   Frequency:= (Space * Channel) + 87_000_000  else   Frequency:= (Space * Channel) + 76_000_000pub Freq2Chnnl(Frequency): Channel'' Converte the Frequency to Channel  if (ConfigRegs[1] & %0000_0000_0000_1100)== 0    Frequency:= Frequency   #> 87_000_000 <# 108_000_000     Channel := (Frequency - 87_000_000)/Space  else    Frequency:= Frequency   #> 76_000_000 <# 108_000_000    Channel := (Frequency - 76_000_000)/Spacepub BandSet(BandMode)'' Select Band US_Eu, Japan, JapanWide   ConfigRegs[1] := (ConfigRegs[1] & %1111_1111_1111_0011) | ((BandMode & %0000_0000_0000_0011)<< 2)  pub SpaceSet(Spacing)| index'' Set Space  100k Hz, 200k Hz,  50k Hz, 25k Hz     index:=lookdownz(Spacing: 100_000,200_000,50_000,25_000)   space:= Spacing   ConfigRegs[1] := (ConfigRegs[1] & %1111_1111_1111_1100) | (index & %0000_0000_0000_0011)       pub TuneEnable'' Tune enable      ConfigRegs[1]:= ConfigRegs[1] | %0000_0000_0001_0000   Pub TuneDisable : flagSTC                                                      '' Check and return STC Flag     ConfigRegs[1]:= ConfigRegs[1] & %1111_1111_1110_1111   flagSTC:= CheckSTC                                      ' Check the Seek/Tune Complete flag      pub CheckSTC : flagSTC                                                       '' Check and return the Seek/Tune Complete flag                                       RdReg_Standard    flagSTC:= (Status[0] & %0100_0000_0000_0000)>> 14    pub CheckSF : flagSF                                                         '' Check and return the Seek Fail flag                         RdReg_Standard    flagSF:= (Status[0] & %0010_0000_0000_0000)>> 13pub CheckST : flagST                                                         '' Check and return the Stereo flag                                   RdReg_Standard    flagST:= (Status[0] & %0000_0100_0000_0000)>> 10    pub CheckChannel : ReadChannel                                                   '' Check and return the Channel information                                 RdReg_Standard       ReadChannel:= Status[0] & %0000_0011_1111_1111pub CheckRSSI : RSSI                                                       '' Check and return the Received Signal Strength Indication                  RdReg_Standard    RSSI:= (Status[1] & %1111_1110_0000_0000)>> 9     pub CheckStationTrue: flagStationTrue                                                  '' Check and return the Station True flag                                       RdReg_Standard     flagStationTrue := (Status[1] & %0000_0001_0000_0000)pub CheckReady : flagReady'' FM Ready Used for soft seek     RdReg_Standard     flagReady:=(Status[1] & %0000_000_1000_0000) >> 7 pub VolumeUp: Volume                                                                     '' Volume Up,  Max 15                  if (ConfigRegs[3] & %0000_0000_0000_1111) < %0000_0000_0000_1111           ConfigRegs[3]:= ConfigRegs[3] + 1       WrReg_Standard   Volume:= ConfigRegs[4] & %0000_0000_0000_1111                         ' Return current Volume level                                 pub VolumeDown: Volume                                                                 '' Volume Down, Min 0               if (ConfigRegs[3] & %0000_0000_0000_1111) > %0000_0000_0000_0000         ConfigRegs[3]:= ConfigRegs[3] - 1         WrReg_Standard         Volume:= ConfigRegs[4] & %0000_0000_0000_1111                       ' Return current Volume level            pub VolumeSet(Level): Volume                                                          '' Set the Volume 0 ~ 15                                    Level:=Level #>0 <#15                                                ' Limit the Volume to 0~15    ConfigRegs[3]:= (ConfigRegs[3] & %1111_1111_1111_0000) | (Level & %0000_0000_0000_1111)     WrReg_Standard        Volume:= ConfigRegs[3] & %0000_0000_0000_1111                         ' Return current Volume levelpub CheckVolume : Volume'' return Volume level    Volume:= ConfigRegs[3] & %0000_0000_0000_1111    pub SeekThreshold(SeekTH): result                                                          '' Set the Seek Threshold, SeekTH 0 ~ 127, return the SeekTH value                                             SeekTH:= SeekTH #>0 <# 127     ConfigRegs[3]:= (ConfigRegs[3] & %1000_0000_1111_1111) | (SeekTH << 8)     WrReg_Standard     result:=(ConfigRegs[3] & %0111_1111_0000_0000)>>8pub STCIntEnable  '' Seek/Tune Complete Interrupt Enable, will Generate a low pulse on GPIO2 when the interrupt occurs.     ConfigRegs[2]:= ConfigRegs[2] | %0100_0000_0000_0100pub STCIntDisable '' Seek/Tune Complete Interrupt Disable     ConfigRegs[2]:= ConfigRegs[2] & %1011_1111_1111_1011        {     pub WrReg_Standard | index                                                          '' Write ConfigRegs[0~5] to FM Register with Continue Mode                                                            I2C.DeviceStart                                       I2C.Tx(I2CAddr_Continue)    repeat index from 0 to 4                                                   ' FM Radio I2C Bus need Acknowledge, between R/W a byte           I2C.Tx(ConfigRegs[index]>>8)                                             ' Sendout High byte      I2C.Tx(ConfigRegs[index])                                                ' SendOut Low byte   I2C.DeviceStop pub RdReg_Standard'' Read FM Register with Continue Mode '' And Store the infromation to Status[0~3]                                                                    I2C.DeviceStart   I2C.Tx(I2CAddr_Continue | %1)                                                   '  Read command   Status[0]:= (I2C.Rx_Ack<<8) | I2C.Rx_Ack   Status[1]:= (I2C.Rx_Ack<<8) | I2C.Rx_Nack    I2C.DeviceStop }pub WrReg_Standard |index'' Write ConfigRegs[0~9] to FM Register with I2C Standard Mode   I2C.DeviceStart     WrRequest(I2CAddr_Standard,$02)      repeat index from 0 to 4                                               ' FM Radio I2C Bus need Acknowledge, between R/W a byte           I2C.Tx(ConfigRegs[index]>>8)                                         ' Sendout High byte      I2C.Tx(ConfigRegs[index])           I2C.DeviceStop                          Pub RdReg_Standard '' Read FM Register with I2C Standard Mode'' And Store the infromation to Status[0~3], Return the address of Status  I2C.DeviceStart  WrRequest(I2CAddr_Standard,$0A)  I2C.DeviceStart  I2C.Tx(I2CAddr_Standard| %1)                                            ' Send Out the Slave address, Write with standard mode  Status[0]:= (I2C.Rx_Ack<<8) | I2C.Rx_Ack  Status[1]:= (I2C.Rx_Ack<<8) | I2C.Rx_Nack   I2C.DeviceStopPub WrRequest(DeviceAddr,RegAddr)                                                                                            '' Write Request, Set Register Address                                                                                                                           I2C.Tx(DeviceAddr)                                                        ' Send out the Slave address, Read with Standard mode                                                                                                                            I2C.Tx(RegAddr)                                                                   dat  Default word  $D001,   $0000,   $0400,   $85D3,   $0000                                  '        \     H  L     H L      H  L     H  L     H  L  /  '         \____02H_______03H______04H______05H_____06H__/     {{┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐│                                                   TERMS OF USE: MIT License                                                  │                                                            ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ │files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    ││modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software││is furnished to do so, subject to the following conditions:                                                                   ││                                                                                                                              ││The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.││                                                                                                                              ││THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          ││WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         ││COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   ││ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘}}          