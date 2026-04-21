# sysrq-info
sysrq-info reads the kernel’s SysRq configuration from /proc/sys/kernel/sysrq and displays a colorized table of SysRq trigger keys, including their ASCII hex values and whether they are currently enabled or disabled. Also evaluates (( SYSRQ_VAL &amp; flag )) to determine whether each capability is enabled based on the kernel’s bitmask.
