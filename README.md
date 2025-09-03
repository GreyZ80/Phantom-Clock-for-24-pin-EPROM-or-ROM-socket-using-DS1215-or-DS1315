# Phantom clock for the TRS-80 Model II (and others)

This **Private** (for the time being) repo is used for all information regarding the Dallas DS1315 chip.
Also here are the executables for the Model II that sets and reads the clock chip.
As most TRS-80 use a 24 pin socket, that is the slot selected. Changes to support a larger chip (28 pin) can be made when needed.

The DS1315 is the chip that is used in the DS1216E Smart Watch DIP socket.

******************
This means that the software for the Smart Watch can also be used for this board. **Duane M. Saylor** wrote software for Model 1, 3 and 4(P).
- CLK1    -  For Model I under LDOS 5.x.x
- CLK3    -  For Model III, Model 4 and 4P under LDOS 5.x.x
- CLK4    -  For Model 4 and 4P under TRSDOS 6.x and LS-DOS 6.x

******************


Important: When setting or reading the clock, the content of the ROM can **not** be accessed. This means that the code must run from another ROM in the system, or from RAM memory not masked by the ROM. When using BigTMon, the code is copied to RAM and executed. A TSR is used to update the time in the status line (HH:MM) 
When running TRS-DOS the setting and reading of the time is handled by a little utility program (written in assembler).

Pinning of the DS1315

<img width="368" height="286" alt="image" src="https://github.com/user-attachments/assets/37fd1c71-3e51-4567-8ecf-328b5c2be5e4" />         

<img width="421" height="387" alt="image" src="https://github.com/user-attachments/assets/fb987184-a35f-4b93-ae12-4404649a7b51" />


### Schematic for the little board

<img width="507" height="484" alt="image" src="https://github.com/user-attachments/assets/044b9230-0a7e-49fb-bd8d-86c81261e481" />

The datasheet of the DS1315 shows a design for a RAM and a ROM configuration. The latter is used. The design uses only 1 backup battery (type CR2032).\
Data line used (Q) connects to A0. This signal is used for writing data.\
Data line (D) is connected to D0. This signal is used while reading data.\
The board is layed out for a 24 Pin (E)PROM.

Suported (E)PROMs:
- 2716  (2Kx8) default for standard Big Tandy with the original Boot ROM
- 2732  (4Kx8) used for custom software (like BigTMon)
- MCM76866  (8Kx8) can be used with modifications to the CPU board. (Not tested)

J4 in the schematic brings out A11 of the EPROM. This is only needed when a 4K EPROM is used in the Model II (because otherwise only the upper part of the 4K is accessable.)

### PCB
**New design: Use CAT28C16A and DS1315 in SOIC package, then all will fit in 24 pin socket footprint ??**

The PCB uses two pin header rows to connect to the original 24 pin socket for the EPROM. The pins of these are slightly thinner to fit the socket and have a slightly broader base. In order to minimise height, I used larger hole for the pins which allow the base to fall inside of the PCB board. Within Kicad a modification to the footprint is made. Pad diameter 2.3mm, hole diameter 1.9mm.\
The crystal for the clock can be placed on the top side (inside of the clock chip socket), or on the backside. The first option is preferred, but pay attention to the socket bridges. So verify before soldering.\
An angled header is used for connection of the back-up battery. Of course direct soldering of two wires to the board can be done as well.\
Jumper J4 adds the option of using a 4K Eprom (2732) in the Model II. By default the 2 pins of the jumper are connected by a bridge. When using a 2732 break the bridge and connect pin 1 to a wire running to the select (external A11 source) for the upper 16K address space of the Eprom.

<img width="550"  alt="Phantom 3D" src="https://github.com/user-attachments/assets/2a1b5b65-4790-4255-b56e-8ebb8b457758" />
<img width="550"  alt="Phantom Front Side" src="https://github.com/user-attachments/assets/e43e138a-83f8-4dc2-a2c7-56bdc72916e0" />
<img width="550"  alt="Phantom Back Side" src="https://github.com/user-attachments/assets/514450f6-2465-4959-bed1-836496d30079" />

### BOM (2K or 4K)
The board only supports a 24 pin (E)PROM or ROM.
Default ROM size for the Big Tandy machines is 2Kbyte. However, they do support 4Kbyte.
When you want to use the Phantom Clock in a standard machine with default content of the Boot ROM, best choice is a 2Kbyte EEPROM.
You can use a 24 pin socket for the EPROM/ROM when there is enough room above the board where the module will be inserted insted of the original ROM. If you cannot create free space above the board, you will have to solder the memory chip directly to the Clock board. Is is not advisable to solder the original ROM on the Clock board. Better is to replace it with an (E)PROM. That chip needs to be programmed with the content of the original ROM. 

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
First placed on the assembly are the two row headers. They are inserted from the **solder** side of the board. Before placing them cut of (almost) all of the thicker pin. This will result in a flat top surface.\
When height of the assembly is an issue (which it is in a model II), you have to solder the EPROM directly on the board. Note that the EPROM can stil be programmed when it is fixed to the board. For looks you can decide to use an EEPROM instead of a UV eraseable. Note that 32Kbit (4Kx8) EEPROMs do not exists. When testing the EPROM on the board without the DS1315 mounted, pins 10 (CEO*) and 11 (CEI*) of the DS1315 position need to be bridged.
When you decide to use a socket for the DS1315, the crystal can be mounted on the component side within the socket, under the chip./
When soldering the DS1315 directly to the board, the crystal has to be placed on the underside of the board **before** you solder the DS1315 in place. Use some hot glue to fixate the crystal.

### Software

The essence of the design is a 'magic' string that opens a hole in the memory map to access the chip.


<img width="836" alt="image" src="https://github.com/user-attachments/assets/e6079cd3-2ed4-4b55-bd4b-0e451379a583" />

This is implemented in the 
