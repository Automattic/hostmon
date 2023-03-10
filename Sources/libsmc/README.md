Warning
-------
This tool will allow you to write values to the SMC which could irreversably damage your
computer.  Manipulating the fans could cause overheating and permanent damange.  
*USE THIS PROGRAM AT YOUR OWN RISK!*

Background
----------
I created this program because I was unhappy with my MacBook Pro running so hot and it
annoyed me that Apple didn't make any way for end users to set fan preferences.

This program will allow you to read and write values to the SMC using the AppleSMC kernel
extension.  The purpose of this is to show how to talk to the controller.  I've made no
effort to make it user friendly, however I'm releasing this in hopes that someone will
take the next logical step and make a nice *free* GUI. I think it's absurd that some
people are trying to charge for simple programs to manipulate this type of data.

In my testing I've been able to lower the average system temperature by 15C just
by running the fans at a low speed like 3500 RPM, which you can barely hear.

Usage 
------
`smc -h`


```bash
Apple System Management Control (SMC) tool 0.01

Usage:
./smc [options]
    -f         : fan info decoded
    -h         : help
    -k <key>   : key to manipulate
    -l         : list all keys and values
    -r         : read the value of a key
    -w <value> : write the specified value to a key
    -v         : version
```

Fan control 
-----------
To decode:  
`smc -f`

To manually query and control:  
`FNum` - tells you how many fans are in the system

To read data from each fan:
```F0Ac - Fan current speed
F0Mn - Fan minimum speed
F0Mx - Fan maximum speed
F0Sf - Fan safe speed
F0Tg - Fan target speed
FS!  - See if fans are in automatic or forced mode
```

[Replace `0` with fan #.  In the MacBook Pro there two fans so this applies for `0` (left)
 and `1` (right).]

To set a fan to a specific speed:

`FS!`  Sets "force mode" to fan.  
    - Bit 0 (right to left) is fan 0, bit 1 is fan 1, etc.  
`F0Tg` - Sets target speed, make sure you fp78 encode it (left shift by 2)


For example, to force both fans to 3500 RPM:  
`python -c "print hex(3500 << 2)"`
0x36b0

`smc -k "FS! " -w 0003`    
`smc -k F0Tg -w 36b0`    
`smc -k F1Tg -w 36b0`

..to force fan 0 to 4000 RPM and leave fan 1 in automatic mode:  
`smc -k "FS! " -w 0001`  
`smc -k F0Tg -w 3e80` 

..to return both fans to automatic mode:  
`smc -k "FS! " -w 0000`

Temperature sensors
-------------------
TB0T   
TC0D  
TC0P  
TM0P  
TN0P  
Th0H  
Ts0P  
TN1P  
Th1H

Light sensors
-------------
ALV0 - Left   
ALV1 - Right 

Motion sensors
--------------
MO_X  
MO_Y  
MO_Z
