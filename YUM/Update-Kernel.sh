## list current kernel version
uname -r

## find latest version
rpm -q --last kernel | head -n 1 | awk '{print $1}'

rpm -qa | grep kernel

yum reinstall <kernelpackage>
