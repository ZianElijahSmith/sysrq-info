# sysrq-info
<img width="1026" height="693" alt="image" src="https://github.com/user-attachments/assets/9047b5b7-7ec4-4576-bb2e-84c34624cbe4" />
<br>
sysrq-info reads the kernel’s SysRq configuration from /proc/sys/kernel/sysrq and displays a colorized table of SysRq trigger keys, including their ASCII hex values and whether they are currently enabled or disabled. Also evaluates (( SYSRQ_VAL &amp; flag )) to determine whether each capability is enabled based on the kernel’s bitmask.

You can then use these values in your C code, or choose to disable/enable codes.

# How to install
1. download sysrq-info.sh on your GNU/Linux Machine. 
   (Won't work on Windows or Mac)
2. Run `sudo install -m 755 sysrq-info.sh /usr/local/bin/sysrq-info` **WHILE IN THE DIRECTORY YOU DOWNLOADED THE FILE TOO**
3. Run `bash /usr/local/bin/sysrq-info`
4. If it works (and it should), congrats, you now have sysrq-info.
5. You can add aliases to your ~/.bashrc file to make `sysrq-info` a command in your terminal
   Open ~/.bashrc: `nano ~/.bashrc`
   Go down to aliases and add
   `echo "alias sysrq-info='bash /usr/local/bin/sysrq-info'" >> ~/.bashrc`
6. Now run `source ~/.bashrc` in your terminal and it should be permanent.
