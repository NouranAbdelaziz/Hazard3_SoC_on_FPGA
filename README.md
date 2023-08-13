# Hazard3_SoC_on_FPGA
In this repo, I will use the hazard3 example SoC provided in the [hazard3 repo](https://github.com/Wren6991/Hazard3/tree/master) to validate it on CmodA7-35T FPGA and use the ARM-USB-Tiny-H JTAG FTDI along with GDB and OpenOCD to debug the program running on the hazard3 core. To make the validation easier and since the only peripherals there are UART and Timer and an SRAM, I added a dummy gpio which has only one register I can write to and I will use this to toggle a LED on the FPGA. 

### Hardware tools used:
* Cmod Artix 7-35T
* ARM-USB-Tiny-H JTAG FTDI
* Micro USB cable
* USB B cable 
* Analog Discovery kit (optional for debugging)
* Jumper wires for connecting

![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/fc6b6260-00cc-4e66-8760-9bb2c8144707)


### Software tools used :
* Xilinx Vivado for synthesizing, implementing, and generating the bit stream of the RTL design
* Digilent Adept for programming the FPGA with the bit file
* Digilent Waveforms for using the analog discovery kit logic analyzer

![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/2f208df8-6d40-4466-95ab-4bb3811922a2)


Here are the steps to debug program on hazard3 SoC implemented on FPGA:
### Step 1: Generate memory intialization file:
You can find all files related to firmware [here](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/tree/main/firmware)
You can run this command to generate the elf file for the gpio test [here](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/tree/main/firmware/gpio_test)
make sure you are in this direcoty ``firmware/gpio_test``
```
riscv32-unknown-elf-gcc -g -march=rv32imc -Os ../common/init.S gpio_test.c -T ../common/memmap.ld -I../common -o gpio_test.elf
```
Then to generate the hex file use this command
```
riscv32-unknown-elf-objcopy -O verilog gpio_test.elf gpio_test.hex
```
Then if you want list file use this command 
```
riscv32-unknown-elf-objdump -dS gpio_test.elf > gpio_test.lst
```
Since the program will be executed from sram not flash the file format needs to be updated for words (4 bytes) to be seperated by space or new line. You can use [this](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/blob/main/firmware/gpio_test/IntelHexToVHex.v) file to do so. It will generate mem file which is compatible with Vivado and the SRAM. 
To run the program use those commands
```
iverilog IntelHexToVHex.v
./a.out
```

### Step 2: Hazard3 SoC implementation on FPGA:
You will find the source files [here](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/tree/main/src). Note: use example_soc_gpio.v which has the added dummy gpio prephiral. You will also find the constraints file [here](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/tree/main/constr) and the testbench for simulation [here](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/tree/main/sim)
To load the mem file in the SRAM, I used the PRELOAD_FILE parameter and passed to it the generated mem file. This works fine until the post implementation functional simulation. You should see the gpio wire toggling in simulation. However it doesn't work in the post implementation timing simulation because of some timing violations in the SRAM. 
To solve this problem, I used a generated block memory sram from Vivado's IP catalog instead of the SRAM provided. 
To do this you need:
  1) Press on the IP catalog button you can find on the left under PROJECT MANAGEMENT
     
    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/1e9cdd1d-63d3-41df-8c56-1218f1165254)

  2) Choose "block memory generator"

    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/1b6b78cb-a7bf-4950-ad0c-4343300e2bbc)

  3) Configure the RAM as follows (Tick the byte write enable and change the byte size to 8 bits, change the write and read width to 32 and depth to 32768 untick 
      the primitives output register to make the read latency only one clock cycle ) :

    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/1e941ab9-8550-45b8-b4da-a2d45714ff63)
    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/d61730ed-7f3c-45fe-ad7e-b0e892bbcb55)

  4) Load the init file and it has to be in coe format. To go from mem to coe press on edit button and set the memory intilization radix to be 16 (hexadecimial) 
     and the memory intializaion vector to be the words seperated by space. Note: be careful do not include any comments or Xs in the memory vector because this 
     will invalidate the file. Then save and validate the file. 

    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/df169aa6-3c3a-4769-8532-de905aec45cd)

    ![image](https://github.com/NouranAbdelaziz/Hazard3_SoC_on_FPGA/assets/79912650/0d46b5b7-e380-4304-bd4b-9d3899edd092)

  5) Then generate the IP and instantiate it instead of the sync_sram module inside the ahb_sync_sram.v (you will find this part done you may want to change the instance name if different)

When you are done, make sure that the post implmentation timing simulation is working and that the gpio wire is toggling. 
To generate the bit file, click on "generate bitstream" you can find under "PROGRAM AND DEBUG" in the side bar. You can also use the ready bitstream you can find [here]()

To program the FPGA with the bit file. You can either do it through Vivado by clicking on "program device" under "Open Hardware Target Manager" or you can use Digilent Adept to program the FPGA and use this command:
```
djtgcfg prog -d CmodA7 -i 0 -f fpga_cmodA7.bit
```

### Step 3: Hardware Connections: 
The hardware connecetions will be as follows: 
* CmodA7 FPGA connected to PC using micro USB cable
* The JTAG FTDI is connected to the USB-B cable which is connected to the PC 
* FPGA pin 3 will be connected to pin 9 in JTAG FTDI (tck)
* FPGA pin 4 will be connected to pin 7 in JTAG FTDI (tms)
* FPGA pin 5 will be connected to pin 5 in JTAG FTDI (tdi)
* FPGA pin 6 will be connected to pin 13 in JTAG FTDI (tdo)
* FPGA PMOD VCC will be connected to pin 1 in JTAG FTDI (vref)
* FPGA PMOD GND will be connected to pin 4 in JTAG FTDI (vref)

### Step 4: Connect OpenOCD:




