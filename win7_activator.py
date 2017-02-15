# ----------------------------------
#    Windows 7 240-days activator
# ----------------------------------
#  Written by zc00l

import time
import subprocess
import sys
try:
    from _winreg import *
except ImportError:
    from winreg import *

keyVal = r"Software\Microsoft\Windows NT\CurrentVersion\SoftwareProtectionPlatform"
try:
    key = OpenKey(HKEY_LOCAL_MACHINE, keyVal, 0, KEY_ALL_ACCESS)
except:
    key = CreateKey(HKEY_LOCAL_MACHINE, keyVal)


def skip_rearm(key):
    try:
        SetValueEx(key, "SkipRearm", 0, REG_DWORD, 0x1)
        print("[+] Registry 'SkipRearm' set to 0x00000001.")
    except WindowsError:
        print("[!] Error: Do not have enough permissions to change machine registry.")
        return -1
    return 0

def query_value(key):
    try:
        value, type = QueryValueEx(key, "SkipRearm")
        print(value)
        if value == 1:
            return True
        else:
            return False
    except:
        print("[!] Error: Could not get data from Windows registry.")
        return -1
    return 0


def unblock():
    proc = subprocess.Popen("slmgr -rearm", shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    while proc.poll() is None:
        time.sleep(1)
    return proc.poll()


if __name__ == "__main__":
    if query_value(key) is False:
        skip_rearm(key)
    elif query_value(key) is True:
        print("[+] Everything is fine.")
        input("Press anything to unblock windows for more 30 days ...")
        unblock()
    else:
        print("[!] Unknown error.")
