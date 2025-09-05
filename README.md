# Phantom clock for the TRS-80 Model II (and others)

************************************
**To be removed**\
This **Private** (for the time being) repo is used for all information regarding the Dallas DS1315 chip.\
When using BigTMon, the code is copied to RAM and executed. A TSR is used to update the time in the status line (HH:MM).\
When running TRS-DOS the setting and reading of the time is handled by a little utility program (written in assembler).\
New design: Use CAT28C16A and DS1315 in SOIC package, then all will fit in 24 pin socket footprint.
***
<img width="600" alt="Finished board" src="https://github.com/user-attachments/assets/abb936c1-b146-49c4-b076-ee6254830841" />

***

This is a description of the little 3x3 cm board that I designed for my Model II. Also here is the executable for the Model II that sets and reads the clock chip.
As most TRS-80 computer use at least one 24 pin socket I decided to use a 24 pin socket. A larger socket (28 pin) is beyond the scope of this project.\
The board creates the possibility to combine a DS1315 with the existing boot ROM.\
The DS1315 is the chip that is used in the DS1216 Smart Watch DIP sockets. Buy the DS1315 chip from a trusted source. Or accept the risk of a "no-good" chip. After testing 15 chips, I found 1 that did not work.\
The broken DS1315 resulted in a partially garbled boot screen, which is the same as when no chip is mounted on the little board.

***
This means that the software for the Smart Watch can also be used for this board. **Duane M. Saylor** wrote software for Model 1, 3 and 4(P).
- CLK1    -  For Model I under LDOS 5.x.x
- CLK3    -  For Model III, Model 4 and 4P under LDOS 5.x.x
- CLK4    -  For Model 4 and 4P under TRSDOS 6.x and LS-DOS 6.x

For model 1 see here:
[Smartwatch sw for model 1](https://www.planetemu.net/rom/tandy-radio-shack-trs-80-model-1/smart-watch-1987-dwayne-saylor-cmd)\
For model 3 see here:
[Smartwatch sw for model 3](https://www.planetemu.net/rom/tandy-radio-shack-trs-80-model-1/smart-watch-1987-dwayne-saylor-cmd)\
For model 4(P) see here: 
[Smartwatch sw for model 4(P)](https://www.planetemu.net/index.php?section=roms&action=showrom&datSlug=tandy-radio-shack-trs-80-model-4&romSlug=smart-watch-19xx-dwayne-saylor-cmd&)

***

For general info look here: [Smart Watch for TRS-80](http://www.trs-80.org/the-smartwatch.html)


>[!important]
>When setting or reading the clock, the content of the ROM can **not** be accessed. This means that the code must run from another ROM in the system, or from RAM memory not masked by the ROM or just execute as a CMD file. The program added for the Model II is intended to be used under LS-DOS 6.3.


<img width="368" height="286" alt="image" src="https://github.com/user-attachments/assets/37fd1c71-3e51-4567-8ecf-328b5c2be5e4" />         

<img width="421" height="387" alt="image" src="https://github.com/user-attachments/assets/fb987184-a35f-4b93-ae12-4404649a7b51" />


### Schematic for the ROM configuration

<img width="507" height="484" alt="image" src="https://github.com/user-attachments/assets/044b9230-0a7e-49fb-bd8d-86c81261e481" />

The datasheet of the DS1315 shows a design for a RAM and a ROM configuration. The latter is used. The design uses only 1 backup battery (type CR2032).\
Data line used (Q) connects to A0. This signal is used for writing data.\
Data line (D) is connected to D0. This signal is used while reading data.\
The board is layed out for a 24 Pin (E)PROM.

Supported (E)PROMs:
- 2316  (2Kx8) ROM, default for standard Big Tandy with the original Boot ROM
- 2716  (2Kx8) EPROM for copies of Boot ROM
- 28C16 (2Kx8) EEPROM for copies of Boot ROM
- 2732  (4Kx8) used for custom software (like BigTMon) that needs more space
- MCM76866  (8Kx8) can be used with modifications to the CPU board. (Not tested)

J4 in the schematic brings out A11 of the EPROM. This is only needed when a 4K EPROM is used in the Model II (because otherwise only the upper part of the 4K is accessable.)

### PCB

The PCB uses two pin header rows to connect to the original 24 pin socket for the EPROM. The pins of these are slightly thinner to fit the socket and have a slightly broader base. In order to minimise height, I used larger hole for the pins which allow the base to fall inside of the PCB board. Within Kicad a modification to the footprint is made. Pad diameter 2.3mm, hole diameter 1.9mm.\
When soldering the header, fixate them using a 24 pin machined socket.

<img width="100"  alt="Pin modification" src="https://github.com/user-attachments/assets/30f198d3-6715-4644-84d4-9cf801729044" />
<img width="175"  alt="Pin fixation" src="https://github.com/user-attachments/assets/b7c87914-1e98-40cb-a534-51978a20e64f" />
<img width="93"  alt="Pin fixation" src="https://github.com/user-attachments/assets/463aeb7d-7145-4c7a-88f9-c80884135d60" />

The crystal for the clock can be placed on the top side (inside of the clock chip socket), or on the backside. This is preferred, but pay attention to the socket bridges. Verify before soldering.

An angled header is used for connection of the back-up battery. Of course direct soldering of two wires to the board can be done as well. Two wires (red and black) are soldered to the battery, after which it is encapsuled in a hear shrink.\
Jumper J4 adds the option of using a 4K Eprom (2732) in the Model II. By default the 2 pins of the jumper are connected by a bridge. When using a 2732 break the bridge and connect pin 1 to a wire running to the select (external A11 source) for the upper 16K address space of the Eprom.

<img width="300"  alt="Phantom 3D" src="https://github.com/user-attachments/assets/2a1b5b65-4790-4255-b56e-8ebb8b457758" />
<img width="300" src="https://github.com/user-attachments/assets/534c5de8-7063-4cd5-b5f0-20063a6e1d45" />

<img width="263"  alt="Phantom Front Side" src="https://github.com/user-attachments/assets/e43e138a-83f8-4dc2-a2c7-56bdc72916e0" />
<img width="263"  alt="Phantom Back Side" src="https://github.com/user-attachments/assets/514450f6-2465-4959-bed1-836496d30079" />

### BOM (2K or 4K)
The board only supports a 24 pin (E)PROM or ROM.
Default ROM size for the Big Tandy machines is 2Kbyte. However, they do support 4Kbyte.
When you want to use the Phantom Clock in a standard machine with default content of the Boot ROM, best option is a 2Kbyte EEPROM.
You can use a 24 pin socket for the EPROM/ROM when there is enough room above the board where the module will be inserted insted of the original ROM. If you cannot create free space above the board, you will have to solder the memory chip directly to the Clock board. Is is not advisable to solder the original ROM on the Clock board. Preferred is to replace it with an (E)PROM. That chip then needs to be programmed with the content of the original ROM. 

Parts needed:
- 1x  16Kb EEPROM (24 pin). e.g. CAT28C16A in PDIP 24 package)
- 1x  DS1315 Clock IC
- 1x  32.768 MHz crystal (small footprint)
- 1x  CR2032 battery cell (3.2V) with 2 wires
- 2x  12 pin male row header with thin (0.4 mm) pins

Optional parts:
- 1x  24 pin machined or low profile socket for (E)EPROM or (original) ROM
- 1x  16 pin machined or low profile socket for DS13125
- 1x  2 pin angled row header for connection of the battery
- 1x  2 pin short pin row header for J4, to enable A11 manipulation when using a 32Kb EPROM.
  
### PCB Assembly
First placed on the assembly are the two row headers. They are inserted from the **solder** side of the board. Before placing them cut of (almost) all of the thicker pin. This will result in a flat top surface. Solder them from the top side of the board.\
When height of the assembly is an issue (which it is in a model II), you have to solder the EPROM directly on the board. Note that the EPROM can stil be programmed when it is fixed to the board. For looks you can decide to use an EEPROM instead of a UV eraseable. Note that 32Kbit (4Kx8) EEPROMs do not exists. When testing the EPROM on the board without the DS1315 mounted, pins 10 (CEO*) and 11 (CEI*) of the DS1315 position need to be bridged.
If you decide to use a socket for the DS1315, the crystal can be mounted on the component side within the socket, under the chip./
When soldering the DS1315 directly to the board, the crystal has to be placed on the underside of the board **before** you solder the DS1315 in place. Use some hot glue to fixate the crystal.\
Mount the parts in the following order:
- 2x row headers
- 24 pin socket (or 24 pin EEPROM)
- Crystal
- 16 pin socket
  - Now the board can be tested for correct operation of the ROM.
  - Place wire between pin 10 and pin 11 of the 16 pin socket
  - Place the board in the Model II
  - Power on the machine
  - It should boot normally.
  - If not check for proper orientation and seating. Check for solder problems.
- When this work continue by placing the connector for the battery
- Place the DS1315
- Connect the battery
- Test the complete assembly

### Software

The essence of the design is a 'magic' string that opens a hole in the memory map to access the chip. This is done by reading the memory location where the chip is "hidden" 64 times.
Doing this gives access to the 8 data registes for ready and writing the time/date parameters. Register 4 also contains the reset and Oscillator on/off functions.

<img width="533" height="743" alt="image" src="https://github.com/user-attachments/assets/a76a7050-919c-47e3-b37d-2e4ab82cce89" />
<img width="450" height="883" alt="image" src="https://github.com/user-attachments/assets/a02c45de-2d7b-4350-a423-e0fda4b3dabc" />

All this is implemented in the CLK4/CMD program. CLK4/CMD can check for existance of the clock. It can set time, date and day of the clock. And it can copy time and date from the clock to the sytem.
Furthermore the oscillator of the clock can be stopped, which saves battery power consumption.

### Copy file to image file for use with Gotek

Using the TRS80GP emulator, the CLK4/CMD faile can be copied to an .hfe image file.
- Copy the CLK4.CMD file the folder where trs80gp is stored
- create a USB stick with LS-DOS system image file in .hfe format.
- Start the emulator in Model II model with frehd and hx options: trs80gp -m2 -frehd -hx
- load the LS-DOS system disk image in drive :0.
- Load the LS-DOS util disk image in drive :1. This disk contains the IMPORT2/CMD program
- Type: Import2 clk4.cmd clk4/cmd
- The file will be copied to the LS-DOS system disk.
- Type DIR to verify
- Close the emulator. This will update the LS-DOS system disk image file.
- Now take the USB stick and insert it in the Gotek.
- Boot your M2 and check the directory of 0: for CLK4/CMD
- Type CLK4 S 1234000901251 to set the time and date of the clock to 12:34:00 09/01/25 Sunday
- type CLK4 to verify.
- turn power off for the Model II. The clock will now keep its time using the battery
- After 5 minutes, power on the computer
- Check time in the chip by typing CLK4. The time should be valid and have advanced by 5 minutes
