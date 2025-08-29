# Phantom clock for the TRS-80 Model II (and others)

This **Private** (for the time being) repo is used for all information regarding the Dallas DS1315 chip.
Also here are the executables for the Model II that sets and reads the clock chip.
As most TRS-80 use a 24 pin socket, that is the slot selected. Changes to support a larger chip (28 pin) can be made when needed.

Important: When setting or reading the clock, the content of the ROM can **not** be accessed. This means that the code must run from another ROM in the system, or from RAM memory not masked by the ROM. When using BigTMon, the code must be copies to RAM. Note that when BigTMon is copied to RAM, the ROM of the Model II cannot be accessed.
When running TRS-DOS the setting and reading of the time is handled by a little utility program (written in assembler).

Pinning of the DS1315

<img width="368" height="286" alt="image" src="https://github.com/user-attachments/assets/37fd1c71-3e51-4567-8ecf-328b5c2be5e4" />         

<img width="421" height="387" alt="image" src="https://github.com/user-attachments/assets/fb987184-a35f-4b93-ae12-4404649a7b51" />


### Schematic for the little board

<img width="507" height="484" alt="image" src="https://github.com/user-attachments/assets/044b9230-0a7e-49fb-bd8d-86c81261e481" />

The datasheet of the DS1315 shows a design for a RAM and a ROM configuration. The latter is used. The design uses only 1 backup (type battery CR2032).\
Data line used (Q) connects to A0. This signal is used for writing data.\
Data line (D) is connected to D0. This signal is used while reading data.\
en verder ....

### PCB
The PCB uses two pin header rows to connect to the original 24 pin socket for the EPROM. The pins of these are slightly thinner to fir the socket and have a slightly broader base. In order to minimise height, I used larger hole for the pins which allow the base to fall inside of the PCB board. Within Kicad a modification to the footprint is made. Pad diameter 2.3mm, hole diameter 1.9mm.\
The crystal for the clock can be placed on the top side (inside of the clock chip socket), or on the backside. The first option is preferred, but pay attention to the socket bridges. So verify before soldering.\
An angled header is used for connection of the back-up battery. Direct soldering of two wires can be done as well.\
Jumper J4 adds the option of using a 4K Eprom (2732) in the Model II. By default the 2 pins of the jumper are connected by a bridge. When using a 2732 break the bridge and connect pin 1 to a wire running to the select (external A11 source) for the upper 16K address space of the Eprom.

<img width="550"  alt="Phantom 3D" src="https://github.com/user-attachments/assets/2a1b5b65-4790-4255-b56e-8ebb8b457758" />
<img width="550"  alt="Phantom Front Side" src="https://github.com/user-attachments/assets/e43e138a-83f8-4dc2-a2c7-56bdc72916e0" />
<img width="550"  alt="Phantom Back Side" src="https://github.com/user-attachments/assets/514450f6-2465-4959-bed1-836496d30079" />

### Software

The essence of the design is a 'magic' string that opens a hole in the memory map to access the chip.


<img width="836" alt="image" src="https://github.com/user-attachments/assets/e6079cd3-2ed4-4b55-bd4b-0e451379a583" />

cccc
