#!/bin/sh
    zenity --info --text="
======================================================================================================
Welcome to the Douglas Neuroinformatics Platform!

Documentation: https://docs.douglasneuroinformatics.ca
Support:       support@douglasneuroinformatics.ca

General Rules for system Use:
1. Ensure data integrity by not sharing your login credentials.
2. Choose a low-use machine. The command 'who' lists users, and 'htop' shows system usage.
3. For bulk data transfers, connect directly to cicss05 to bypass any round-trip data transfers.
4. Avoid using your '\$HOME' folder for data storage. Utilize your project's '/data' folder instead.
5. Refrain from using 'sudo'. If you're following instructions that need it, its time to ask for help.
======================================================================================================
" &
