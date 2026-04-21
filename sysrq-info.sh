sudo tee /usr/local/bin/sysrq-info > /dev/null << 'EOF'
#!/usr/bin/env bash
# sysrq-info — Print your kernel's SysRq key table with hex values
# Usage: sysrq-info [--hex-only | --enabled-only | --help]
# Run `sudo install -m 755 sysrq-info /usr/local/bin/sysrq-info` to install 

set -euo pipefail

if [[ -t 1 ]]; then
    BOLD='\033[1m'; DIM='\033[2m'; RED='\033[0;31m'; GREEN='\033[0;32m'
    YELLOW='\033[1;33m'; CYAN='\033[0;36m'; RESET='\033[0m'
else
    BOLD=''; DIM=''; RED=''; GREEN=''; YELLOW=''; CYAN=''; RESET=''
fi

HEX_ONLY=0
ENABLED_ONLY=0

for arg in "$@"; do
    case "$arg" in
        --hex-only)     HEX_ONLY=1 ;;
        --enabled-only) ENABLED_ONLY=1 ;;
        --help|-h)
            echo "Usage: sysrq-info [--hex-only] [--enabled-only]"
            echo ""
            echo "  --hex-only      Print only the key and its hex value (no description)"
            echo "  --enabled-only  Only show keys that are currently enabled on this kernel"
            echo ""
            echo "SysRq bitmask flags (from /proc/sys/kernel/sysrq):"
            echo "  0  = disabled entirely"
            echo "  1  = all functions enabled"
            echo "  2  = enable control of console logging level"
            echo "  4  = enable control of keyboard (SAK, unraw)"
            echo "  8  = enable debugging dumps of processes etc."
            echo "  16 = enable sync command"
            echo "  32 = enable remount read-only"
            echo "  64 = enable signalling of processes (term, kill, oom-kill)"
            echo " 128 = allow reboot/poweroff"
            echo " 256 = allow nicing of all RT tasks"
            exit 0 ;;
        *)
            echo "Unknown option: $arg  (try --help)" >&2
            exit 1 ;;
    esac
done

SYSRQ_VAL=0
if [[ -r /proc/sys/kernel/sysrq ]]; then
    SYSRQ_VAL=$(cat /proc/sys/kernel/sysrq 2>/dev/null || echo 0)
fi

declare -a TABLE=(
    "0  0x30  2   Set console log level to 0 (only KERN_EMERG messages)"
    "1  0x31  2   Set console log level to 1"
    "2  0x32  2   Set console log level to 2"
    "3  0x33  2   Set console log level to 3"
    "4  0x34  2   Set console log level to 4"
    "5  0x35  2   Set console log level to 5"
    "6  0x36  2   Set console log level to 6"
    "7  0x37  2   Set console log level to 7"
    "8  0x38  2   Set console log level to 8"
    "9  0x39  2   Set console log level to 9 (all messages)"
    "b  0x62  128 Immediately reboot without syncing or unmounting"
    "c  0x63  8   Trigger a system crash / kdump (kexec)"
    "d  0x64  8   Show all locks held (lockdep)"
    "e  0x65  64  Send SIGTERM to all processes except init"
    "f  0x66  64  Call the OOM killer — kill the memory-hogging process"
    "g  0x67  8   kgdb: hand off to the kernel debugger"
    "h  0x68  0   Display SysRq help message to the kernel log"
    "i  0x69  64  Send SIGKILL to all processes except init"
    "j  0x6A  64  Forcibly thaw filesystems frozen by FIFREEZE ioctl"
    "k  0x6B  4   SAK — Secure Access Key: kill all programs on current console"
    "l  0x6C  8   Show a stack backtrace for all active CPUs"
    "m  0x6D  8   Dump current memory info to the console"
    "n  0x6E  256 Make all RT tasks nice-able (lower priority)"
    "o  0x6F  128 Shut off the system (poweroff)"
    "p  0x70  8   Dump current registers and flags to the console"
    "q  0x71  8   Dump per-CPU hrtimer queues and all clockevent devices"
    "r  0x72  4   Turn off keyboard raw mode (unraw) — recover from X crash"
    "s  0x73  16  Emergency sync all mounted filesystems"
    "t  0x74  8   Dump a list of current tasks and their info to the console"
    "u  0x75  32  Remount all mounted filesystems read-only"
    "v  0x76  8   Forcibly restore framebuffer console (vesafb/fbcon)"
    "w  0x77  8   Dump uninterruptible (blocked) tasks"
    "x  0x78  8   Used by xmon on PPC / dump global PMU registers on ARM"
    "y  0x79  8   Show global CPU registers (SPARC-64 specific)"
    "z  0x7A  8   Dump the ftrace buffer to the console"
)

is_enabled() {
    local flag=$1
    [[ $flag -eq 0 ]] && return 0
    [[ $SYSRQ_VAL -eq 1 ]] && return 0
    [[ $SYSRQ_VAL -eq 0 ]] && return 1
    (( SYSRQ_VAL & flag )) && return 0
    return 1
}

if [[ $HEX_ONLY -eq 0 ]]; then
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║          Linux Kernel SysRq Magic Number Reference               ║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    KVER=$(uname -r 2>/dev/null || echo "unknown")
    echo -e "  ${BOLD}Kernel :${RESET} $KVER"
    echo -ne "  ${BOLD}SysRq  :${RESET} /proc/sys/kernel/sysrq = ${YELLOW}${SYSRQ_VAL}${RESET}"
    if [[ $SYSRQ_VAL -eq 0 ]]; then
        echo -e "  ${RED}(disabled)${RESET}"
    elif [[ $SYSRQ_VAL -eq 1 ]]; then
        echo -e "  ${GREEN}(all enabled)${RESET}"
    else
        echo -e "  ${GREEN}(partial — bitmask)${RESET}"
    fi
    echo ""
    echo -e "  ${DIM}Trigger manually : echo <key> > /proc/sysrq-trigger  (as root)${RESET}"
    echo -e "  ${DIM}Keyboard shortcut: Alt+SysRq+<key>   or   Alt+PrtSc+<key>${RESET}"
    echo ""
    printf "  ${BOLD}%-6s  %-8s  %-9s  %s${RESET}\n" "KEY" "HEX" "STATUS" "DESCRIPTION"
    printf "  %s\n" "──────────────────────────────────────────────────────────────────"
fi

for entry in "${TABLE[@]}"; do
    read -r key hex flag desc <<< "$entry"
    if is_enabled "$flag"; then
        status="${GREEN}enabled ${RESET}"
        enabled=1
    else
        status="${RED}disabled${RESET}"
        enabled=0
    fi
    [[ $ENABLED_ONLY -eq 1 && $enabled -eq 0 ]] && continue
    if [[ $HEX_ONLY -eq 1 ]]; then
        printf "%-4s  %s\n" "$key" "$hex"
    else
        printf "  ${BOLD}%-4s${RESET}  %-8s  " "$key" "$hex"
        echo -ne "$status"
        printf "  %s\n" "$desc"
    fi
done

if [[ $HEX_ONLY -eq 0 ]]; then
    printf "  %s\n" "──────────────────────────────────────────────────────────────────"
    echo ""
    echo -e "  ${DIM}REISUB safe-reboot sequence: r → e → i → s → u → b${RESET}"
    echo -e "  ${DIM}(unRaw, tErminate, kIll, Sync, Unmount, reBoot)${RESET}"
    echo ""
fi
EOF
sudo chmod +x /usr/local/bin/sysrq-info
