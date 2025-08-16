Phantom clock for the TRS-80 Model II (and others)

This Private (for the time being) repo is used for all information regarding the Dallas DS1315 chip.
Also here are the executables for the Model II that sets and reads the clock chip.
As most TRS-80 use a 24 pin socket, that is the slot selected. Changes to support a larger chip (28 pin) can be made when needed.

Important: When setting or reading the clock, the content of the ROM can **not** be accessed. This means that the code must run from another ROM in the system, or from RAM memory not masked by the ROM. When using BigTMon, the code must be copies to RAM.
When running TRS-DOS, the setting and reading of the time is handled by a little utility program (written in assembler).

Pinning of the DS1315

<img width="368" height="286" alt="image" src="https://github.com/user-attachments/assets/37fd1c71-3e51-4567-8ecf-328b5c2be5e4" />         

<img width="421" height="387" alt="image" src="https://github.com/user-attachments/assets/fb987184-a35f-4b93-ae12-4404649a7b51" />


Schematic for the little board

<img width="507" height="484" alt="image" src="https://github.com/user-attachments/assets/044b9230-0a7e-49fb-bd8d-86c81261e481" />


Data line used (Q) connects to D0 en verder ....

<img width="836" alt="image" src="https://github.com/user-attachments/assets/e6079cd3-2ed4-4b55-bd4b-0e451379a583" />

cccc
