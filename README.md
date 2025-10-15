i have no idea who would benefit from this but i had spent a ridicilous amount of time to reverse-engineer this game to understand the mechanics
and eventually created a save file editor (.ipynb) 

the principle is the local storage has base64 encoded SO(sharedObject) in AMF format. 
if you point your browser to: https://www.minigames.pro/swords-and-sandals-2-emperors-reign-full-version/#
and check the local storage of your browser you will find the base64 string that represents the save file. 
you may have to create a character and then kill the first prisioner to get a proper save file.

i have included amf spec and some of my work including a kaitai struct parser (.ksy)


Donate
======
## Multisig Etherium
0xC92397C5ec0e892C63aEA7e980652E5F11040B96
## SOLANA (best!)
6Bi6c7cpgAV6bdBp2c2VjrMLADsBWmb8zDHAKaDm41dS
## Other
<a href="https://www.buymeacoffee.com/risitas" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a> \
![QR code](bmc_qr.png)
