'' File: RDA5807SS_Demo.spin

{{
   FM Radio RDA5807SS was connected to P0, P1. 
   EEPROM  24LC256 was connected to P28,P29.

}}

con
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000
 
obj

PST    : "Parallax Serial Terminal"
FM     : "RDA5807SS_Driver2"
EEPROM : "Store2Eeprom"

var

'' Call  FM.PassInfo(@ConfigRegs,@Status), the program will copy the data to RAM from RDA5807SS Driver Object
word ConfigRegs[5]                             ' Registers $02, $03, $04, $05, $06  // $06 reserve for future use
word Status[4]                                 ' Registers $0A, $0B, $0C, $0D      //  $0C,$0D reserve for future use
            
word Stations[32]                              ' Store the Stations to EEPROM(10-bit Channel information, need to coverte to Frequency)32 stations in total   

byte cog                                       ' Start a new cog to detect input
long Stack[12]                                 ' Stack for new cog, at least 11 long

long Frequency                                 ' Curren Frequency
byte ptrChnnl                                  ' Point to Current Channel
byte KeyIn

pub main 

   Initialize
   
   repeat
     display
     DisChnnlLst
     waitcnt(cnt + clkfreq/4)               

pub Initialize

   PST.start(57600)                              ' Start Parallax Serial Terminal 
   FM.Initialize(1,0)                            ' Start FM Radio SDA, SCL connect to Pin 1, Pin 0 
   StartCogInput                                 ' Start a new cog to detect the input  
   EEPROM.Initialize(29,28)                      ' Start EEPROM SDA,SCL connect to Pin 29, Pin 28
   EEPROM.getStations(@Stations)                 ' Initialize the RAM

   FM.SeekThreshold(6)                           ' Change the Seek Threshold
   
   ptrChnnl:= 0                                  ' Point to first Channel in RAM
   RdChannel(ptrChnnl)
   ChannelDown

pub ChannelUp

''  Select Next Channel

    ptrChnnl:= ptrChnnl + 1 <# 31                             ' point to Next Channel           
    FM.FreqSet(RdChannel(ptrChnnl))             

pub ChannelDown

'' Select Previous Channel
   
    ptrChnnl := ptrChnnl - 1 #>0                              ' point to Previous Channel
    FM.FreqSet(RdChannel(ptrChnnl))

pub RdChannel(ChannelNum): Freq                               ' Read the Current Channel from RAM

'' Get the Channel information from EEPROM

    EEPROM.getStations(@Stations)
    
    Freq:=Frequency:= FM.Chnnl2Freq(Stations[ChannelNum])
         
pub SvChannel(ChannelNum) | chan

'' Save the Channel to EEPROM
     
    Stations[ChannelNum]:= FM.Freq2Chnnl(Frequency)
     
    EEPROM.StoreStations(@Stations)  

pub Display | index, Temp

  '' Update the display information in the PST
    
     FM.PassInfo(@ConfigRegs,@Status)                         ' Read the configure Regsiters and status 
     PST.Home                                                 
     PST.str(@Title)
     PST.str(@CutLine)
     PST.char(PST#TB)
     PST.str(@StereoI + (8 * FM.CheckST))                     ' Display the Stereo Indicator

     PST.Position(38,2)
     PST.str(string("Volume: ",PST#CE))                       ' Display the Stereo Volume Level
     repeat FM.CheckVolume
         PST.char(")")
     PST.dec(FM.CheckVolume)

     PST.position(8,3)
     if ConfigRegs[0] & %0000_0000_0000_0001 == %0000_0000_0000_0001
        PST.str(String("Power On "))
     else
        PST.str(string("Power Off"))
        
     PST.position(58,3)   
     if ConfigRegs[0] & %0100_0000_0000_0000 == %0100_0000_0000_0000
       PST.str(string("    ")) 
     else        
       PST.str(string("Mute"))

       
     PST.position(8,4) 
     if ConfigRegs[0] & %0010_0000_0000_0000 == %0010_0000_0000_0000
        PST.str(string("Mono  "))
     else
        PST.str(string("Stereo")) 
      
                
     Frequency := FM.CheckFreq
     PST.str(string(PST#TB,PST#TB,"  FM  "))' Display the Frequency
     displayFreq(Frequency)


     PST.position(8,5) 
     if ConfigRegs[0] & %0001_0000_0000_0000 == %0001_0000_0000_0000
        PST.str(String("Bass On "))
     else
        PST.str(string("Bass Off"))

     PST.position(8,6)
     PST.str(String("RSSI: ",PST#CE))                               ' Display Received Signal Strength Indicator
     repeat FM.CheckRSSI/3
        PST.char("(")
     PST.dec(FM.CheckRSSI)
                                    
     PST.char(PST#NL)
     PST.str(@CutLine)
     PST.char(PST#NL)

     PST.Str(@InputStr)

     Menu1
     GetKey
                   
     
pub GetKey
     
     case KeyIn
         "." :  FM.PowerOn          
         "0" :  FM.PowerOff
          
         "1" :  FM.Mono          
         "3" :  FM.Stereo
                   
         "7" :  FM.MuteOn
         "9" :  FM.MuteOff
                 
         "5" :  FM.BassSW
         13  :  SvChannel(ptrChnnl)                                         ' Enter,Save Channel to current Address
                 
         "8" :  FM.FreqUp                           
         "2" :  FM.FreqDown
         
         "6" :  FM.SeekUp          
         "4" :  FM.SeekDown
         
         "+" :  FM.VolumeUp  
         "-" :  FM.VolumeDown
         
         "*" :  ChannelUp 
         "/" :  ChannelDown 

         other:  

    KeyIn~

pub DisplayFreq(DisFreq)

    ' PST.dec(DisFreq/1000_000)
     PST.dec(DisFreq//1_000_000_000/100_000_000)
     PST.dec(DisFreq//100_000_000/10_000_000)
     PST.dec(DisFreq//10_000_000/1_000_000)
     PST.str(string("."))
     PST.dec(DisFreq//1_000_000/100_000)
     PST.dec(DisFreq//100_000/10_000)
     PST.str(string(" MHz   "))
     
pub DisChnnlLst | index

     EEPROM.getStations(@Stations)                           ' Get the Latest Stations list

     PST.position(9,17) 
     PST.str(string("Channel List:",PST#NL))
     PST.str(@CutLine)  
     repeat index from 0 to 31
       PST.position(16*(index//4)+6, (index/4)+19)
       if index < 10                                         '
         PST.Hex(index,2)    
       else
          PST.dec(index)
       PST.char(")")
       DisplayFreq(FM.Chnnl2Freq(Stations[index]))           
      
     PST.position(16*(ptrChnnl//4)+20, (ptrChnnl/4)+19)
     PST.char("<")                                           ' Display the pointer
           
pub Menu1

   '' Display the Menu1

    PST.position(0,9)

    PST.str(@CutLine)    
    PST.str(@Menu_10)
    PST.str(@CutLine)
   
pub StartCogInput : Okay

   '' Start a new cog to detect the input 

   StopCogInput
   Okay:= cog:= cognew(GetInput,@Stack[0])+1                     ' Detect the Input in a new cog 

pub StopCogInput

  ''Stop input communication, frees a cog.

  if cog
    cogstop(cog~ - 1)

pub GetInput 

'' Detect the input information from PST.

 repeat  
   KeyIn:= PST.charIn

Dat

Title    byte  9,9,9,"   Parallax FM Radio",13,0
CutLine  byte  9,"-------------------------------------------------------",13,0
StereoI  byte  " ( M ) ",0,"(( S ))",0

InputStr byte   9,"Please press a key:",0

Menu_10  byte   9,9,            9,"/)Chnnl  -",9,"*)Chnnl   +",9,"-)Vol    -",13 
Menu_11  byte   9,"7)Mute On  ",9,"8)Freq   +",9,"9)Mute Off ",9,"+)Vol    +",13
Menu_12  byte   9,"4)Search  -",9,"5)Bass SW ",9,"6)Search  +",13
Menu_13  byte   9,"1)Mono     ",9,"2)Freq   -",9,"3)Stereo   ",9,"Enter)Save",13
Menu_14  byte   9,"0)Power Off",9,9,           9,".)Power On ",9,13,0


{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}   