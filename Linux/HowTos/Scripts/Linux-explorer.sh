#!/bin/bash
##############################################################################
#
#
# FILE             : linux-explorer.sh
# Last Change Date : 3-06-2014
# Author(s)        : Joe Santoro
# Date Started     : 15th April, 2004
# Email            : linuxexplo [ at ] unix-consultants.com
# Web              : http://www.unix-consultants.com/examples/scripts/linux/linux-explorer
#
# Usage            : ./linux-explorer.sh [option]
#			-d      Target directory for explorer files
#			-k      Do not delete files created by this script
#			-t      [hardware] [software] [configs] [cluster] [disks] [network] [all]
#			-v      Verbose output
#			-s      Verify Package Installation
#			-h      This help message
#			-V      Version Number of LINUXEXPLO
#
##############################################################################
#
# Purpose          : This script is a linux version of the Solaris explorer
#                    (SUNWexplo) script.
#
#		    Used to collect information about a linux system build for
#		    remote support purposes.
#		    This script is a general purpose script for ALL linux
#		    systems and therefore NOT tied into any one distro.
#
##############################################################################
#
# J.S UNIX CONSULTANTS LTD  MAKES NO REPRESENTATIONS OR WARRANTIES ABOUT THE
# SUITABILITY OF THE SOFTWARE, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE, OR NON-INFRINGEMENT. J.S UNIX CONSULTANTS LTD SHALL
# NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
# MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES.
#
##############################################################################
#
# Modified for use by FreePBX to collect additional Info from Asterisk
#
##############################################################################
 COPYRIGHT="Copyright (c) J.S Unix Consultants Ltd"
 MYVERSION="0.205.FreePBX"
    MYDATE="$(/bin/date +'%Y.%m.%d.%m.%H.%M')"	# Date and time now
    MYNAME=$(basename $0)
    WHOAMI=$(/usr/bin/whoami)		# The user running the script
    HOSTID=$(/usr/bin/hostid)		# The Hostid of this server
MYHOSTNAME=$(/bin/uname -n)		# The hostname of this server
MYSHORTNAME=$(echo $MYHOSTNAME | cut -f 1 -d'.')
   TMPFILE="/tmp/$(basename $0).$$"	# Tempory File
    TOPDIR="/opt/LINUXexplo"		# Top level output directory
 CHECKTYPE=""				# Nothing selected


VERBOSE=0				# Set to see the scripts progress used
			    		# only if connected  to a terminal session.

FULLSOFT=0				# Set to Verify Software installation
			    		# this takes a very long time

KEEPFILES="0"				# Default to remove files created by this script

unset GZIP 				# Ensure that GZIP is unset for later use.

# Set the path for the script to run.
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:$PATH
export PATH

EXPLCFG=/etc/linuxExplo.cfg


##############################################################################
#
#      Function : spinningCursor
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

spinningCursor()
{
	case $toggle in
	    	1) 	echo -n $1" [ \ ]"
			echo -ne "\r"
			toggle="2"
			;;

		2) 	echo -n $1" [ | ]"
			echo -ne "\r"
			toggle="3"
			;;

		3)	echo -n $1" [ / ]"
			echo -ne "\r"
			toggle="4"
			;;

		*) 	echo -n $1" [ - ]"
			echo -ne "\r"
			toggle="1"
			;;
	esac
}



##############################################################################
#
#      Function : MakeDir
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function MakeDir
{
	myDir="$1"

	if [ ! -d $myDir ] ; then
		$MKDIR -p $myDir
		if [ $? -ne 0 ] ; then
			echo "ERROR: Creating directory $LOGDIR"
			exit 1
		fi
	else
		$CHMOD 750 $myDir
	fi
}



##############################################################################
#
#      Function : config_function
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function config_functions
{

	# We need the password file and the group file so that we can work out who

	if [ -f /etc/sudoers ] ; then
		$CP -p /etc/sudoers  ${LOGDIR}/etc/sudoers
	fi

	config_files
	boot_section
	openldap_info
	pam_info
}

##############################################################################
#
#      Function : cluster_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function cluster_functions
{
	MakeDir ${LOGDIR}/clusters

	ocfs2_cluster_info
	redhat_cluster_info
	veritas_cluster_info
	pacemake_cluster_info

}

##############################################################################
#
#      Function : disk_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function disk_functions
{
	MakeDir ${LOGDIR}/hardware/disks
	MakeDir ${LOGDIR}/hardware/disks/raid

	disk_info
	brtfs_info
	lvm_info
	zfs_info
	filesystem_info
	raid_info
	disk_dm_info
	nfs_info
	emc_powerpath_info
	netapp_info
	veritas_vm


}

##############################################################################
#
#      Function : backup_products_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function backup_products_functions
{
	netbackup
}



##############################################################################
#
#      Function : hardware_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function hardware_functions
{
	MakeDir ${LOGDIR}/hardware

	hardware_checks
	disk_functions
	network_functions
	hot_plug

}


##############################################################################
#
#      Function : log_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function log_functions
{
	MakeDir ${LOGDIR}/logs

	selinux_info
	system_logs_info
	proc_sys_info
}

##############################################################################
#
#      Function : network_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function network_functions
{

	MakeDir ${LOGDIR}/networks


	dns_info
	network_info
	iptables_info
	ipchains_info
	ethtool_info
	yp_info

}

##############################################################################
#
#      Function : software_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function software_functions
{

	MakeDir ${LOGDIR}/software

	rpm_info
	deb_info
	pacman_info
	suse_zypper_info
	gentoo_pkgs_info
	spacewalk_info
	sysconfig_info
	rhn_info
	ssh_info
	samba_info
	apache_info
	asterisk_info
}

##############################################################################
#
#      Function : virt_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function virt_functions
{

	MakeDir ${LOGDIR}/virtual
	VIRT=${LOGDIR}/virtual

	xen_info
	libvirt_info

}

##############################################################################
#
#      Function : general_functions
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function general_functions
{

	# Create the default directories I'm going to use.
	MakeDir ${LOGDIR}/boot
	MakeDir ${LOGDIR}/clusters
	MakeDir ${LOGDIR}/etc
	MakeDir ${LOGDIR}/hardware
	MakeDir ${LOGDIR}/hardware/disks
	MakeDir ${LOGDIR}/lp
	MakeDir ${LOGDIR}/logs
	MakeDir ${LOGDIR}/mail
	MakeDir ${LOGDIR}/system
	MakeDir ${LOGDIR}/software
	MakeDir ${LOGDIR}/var
	MakeDir ${LOGDIR}/virtual

	system_logs_info
	openldap_info
	pam_info
	xinetd_info
	crontab_info
	printing_info
	postfix_info
	exim_info
	dovecot_info
	time_info
	ppp_info
	apache_info
	samba_info
	ssh_info
	x11_info
}


##############################################################################
#
#      Function : myselection
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################


function myselection
{

	mywhich
	findCmds
	systemd_info
	performance_info
	release_information
	installation_details


	case $1 in

	configs)	Echo "You have selected \"configs\" "
			config_functions
			;;

	clusters)	Echo "You have selected \"clusters\" "
			cluster_functions
			;;

	disks)		Echo "You have selected \"disks\" "
			disk_functions
			;;

	hardware)	Echo "You have selected \"hardware\" "
			hardware_functions
			;;

	logs)		Echo "You have selected \"logs\" "
			log_functions
			;;

	network)	Echo "You have selected \"network\" "
			network_functions
			;;

	software)	Echo "You have selected \"software\" "
			software_functions
			;;

	virtualization)	Echo "You have selected \"virtualization\" "
			virt_functions
			;;

	general)	Echo "You have selected \"virtualization\" "
			general_functions
			;;


	all|*)		Echo "You have selected \"ALL\" "
			config_functions
			cluster_functions
			disk_functions
			hardware_functions
			log_functions
			network_functions
			virt_functions
			software_functions
			general_functions
			;;

	esac


}





##############################################################################
#
#      Function : Usage
#
#         Notes : N/A
#
##############################################################################

function ShowUsage
{

    	#-------------------------------------------------------------------
    	#   Show help message
    	#-------------------------------------------------------------------

	echo
	echo "$MYNAME Version $MYVERSION - $COPYRIGHT "
	echo
	echo "	usage:   $MYNAME [option] "
	echo
	echo "		-d      Target directory for explorer files"
	echo "		-k	Keep files created by this script"
	echo "		-t      [hardware] [software] [configs] [cluster] [all] [disks] [network]"
	echo "		-v      Verbose output"
	echo "		-s      Verify Package Installation"
	echo "		-h      This help message"
	echo "		-V      Version Number of LINUXEXPLO"
	echo
	exit 1
}





##############################################################################
#
#      Function : Echo
#    Parameters : String to display what function is about to run
#        Output : Print what section we are about to collect data for
#         Notes : N/A
#
##############################################################################



function Echo ()
{

	if [ -t 0 ] ; then

		if [ ${VERBOSE} -ne 0 ] ; then
			echo "[*] $*"
			echo "============================================="
		fi

		if [ ${VERBOSE} -gt 1 ] ; then
			echo "Press Return to Continue.........."
			read A
		fi
	fi
}


##############################################################################
#
#      Function : mywhich
#
#    Parameters : name of program
#
#        Output : path of executable
#
#         Notes : Return back the location of the executable
#		  I need this as not all linux distros have the files
#		  in the same location.
#
##############################################################################


function mywhich ()
{

	local command="$1"

	if [  "$command" =  "" ] ; then
		return
	fi

	local mypath=$(which $command 2>/dev/null)

	if [  "$mypath" =  "" ] ; then
		echo "Command $command not found" >> $NOTFNDLOG
		echo "NOT_FOUND"
	elif [ ! -x "$mypath" ] ; then
		echo "Command $command not executable" >> $NOTFNDLOG
		echo "NOT_FOUND"
	else
		echo "$mypath"
	fi

}



##############################################################################
#
#      Function : findCmds
#
#    Parameters : None
#
#        Output : None
#
#         Notes :       Goes and find each of the commands I want to use and
#			stores the information into the various variables which
#			is the uppercase version of the command itself.
#
#			I need this as not all linux distros have the files
#			in the same location.
#
##############################################################################

function findCmds
{
	if [ ${VERBOSE} -gt 0 ] ; then
		echo "[*] Section - Finding Commands"
		echo "============================================="
	fi


	# Standard commands

            AWK=$(mywhich awk       )
       BASENAME=$(mywhich basename  )
            CAT=$(mywhich cat       )
      CHKCONFIG=$(mywhich chkconfig )
             CP=$(mywhich cp        )
            CUT=$(mywhich cut       )
          CHMOD=$(mywhich chmod     )
         COLUMN=$(mywhich column    )
           DATE=$(mywhich date      )
             DF=$(mywhich df        )
          DMESG=$(mywhich dmesg     )
           ECHO=$(mywhich echo      )
         EQUERY=$(mywhich equery    )
           FILE=$(mywhich file      )
           FIND=$(mywhich find      )
           FREE=$(mywhich free      )
           GREP=$(mywhich grep      )
            GPG=$(mywhich gpg       )
          EGREP=$(mywhich egrep     )
     JOURNALCTL=$(mywhich journalctl)
             LS=$(mywhich ls        )
    LSB_RELEASE=$(mywhich lsb_release )
             LN=$(mywhich ln        )
          MKDIR=$(mywhich mkdir     )
           LAST=$(mywhich last      )
         LOCALE=$(mywhich locale    )
         PSTREE=$(mywhich pstree    )
             PS=$(mywhich ps        )
             RM=$(mywhich rm        )
          SLEEP=$(mywhich sleep     )
      SYSTEMCTL=$(mywhich systemctl )
          MOUNT=$(mywhich mount     )
         MD5SUM=$(mywhich md5sum    )
             MV=$(mywhich mv        )
            SAR=$(mywhich sar       )
           SORT=$(mywhich sort      )
           TAIL=$(mywhich tail      )
          UNAME=$(mywhich uname     )
         UPTIME=$(mywhich uptime    )
            WHO=$(mywhich who       )
            ZIP=$(mywhich zip       )
           GZIP=$(mywhich gzip      )
           GAWK=$(mywhich gawk      )
            SED=$(mywhich sed        )
         GUNZIP=$(mywhich gunzip    )
       SPACERPT=$(mywhich 'spacewalk-report' )
           UNIQ=$(mywhich uniq      )
             WC=$(mywhich wc        )

   # Selinux
       SESTATUS=$(mywhich sestatus   )
      GETSEBOOL=$(mywhich getsebool  )
       SEMANAGE=$(mywhich semanage   )

   # Samba
      TESTPARM=$(mywhich testparm   )
       PDBEDIT=$(mywhich pdbedit   )
        WBINFO=$(mywhich wbinfo     )

 # Systemd
        SYSTEMD=$(mywhich systemd         )
      SYSTEMCTL=$(mywhich systemctl       )
    SYSTEMDCGLS=$(mywhich systemd-cgls    )
SYSTEMDLOGINCTL=$(mywhich systemd-loginctl)


   # Printing
           LPC=$(mywhich lpc   )
           LPQ=$(mywhich lpq  )
        LPSTAT=$(mywhich lpstat  )
      LPQ_CUPS=$(mywhich lpq.cups )

   # Apache
     APACHECTL=$(mywhich apachectl  )
    APACHE2CTL=$(mywhich apache2ctl )

   # Packages
      APTCONFIG=$(mywhich apt-config  )
            RPM=$(mywhich rpm         )
         ZYPPER=$(mywhich zypper      )
           DPKG=$(mywhich dpkg        )
     DPKG_QUERY=$(mywhich dpkg-query  )
         EMERGE=$(mywhich emerge      )
            YUM=$(mywhich yum         )
         PACMAN=$(mywhich pacman      )


   # Kernel Info
        MODINFO=$(mywhich modinfo     )
         SYSCTL=$(mywhich sysctl      )
          KSYMS=$(mywhich ksyms       )
        SLABTOP=$(mywhich slabtop     )

	# H/W Info
           ACPI=$(mywhich acpi         )
    BIOSDEVNAME=$(mywhich biosdevname  )
        CARDCTL=$(mywhich cardclt      )
       DUMPE2FS=$(mywhich dumpe2fs     )
      DMIDECODE=$(mywhich dmidecode    )
          FDISK=$(mywhich fdisk	       )
          BLKID=$(mywhich blkid	       )
         HDPARM=$(mywhich hdparm       )
       HOSTNAME=$(mywhich hostname     )
         HWINFO=$(mywhich hwinfo       )
        HWCLOCK=$(mywhich hwclock      )
          LSMOD=$(mywhich lsmod        )
          LSPCI=$(mywhich lspci        )
          LSPNP=$(mywhich lspnp        )
          LSBLK=$(mywhich lsblk        )
         LSSCSI=$(mywhich lsscsi       )
        IPVSADM=$(mywhich ipvsadm      )
          LSUSB=$(mywhich lsusb        )
          LSDEV=$(mywhich lsdev        )
          LSHAL=$(mywhich lshal        )
         LSRAID=$(mywhich lsraid       )
          MDADM=$(mywhich mdadm        )
       PROCINFO=$(mywhich procinfo     )
        POWERMT=$(mywhich powermt      )
       SMARTCTL=$(mywhich smartclt     )
         SFDISK=$(mywhich sfdisk       )
         HWPARM=$(mywhich hwparm       )
        SCSI_ID=$(mywhich scsi_id      )
       ISCSIADM=$(mywhich iscsiadm     )
      MULTIPATH=$(mywhich multipath    )
        DMSETUP=$(mywhich dmsetup      )
           NTPQ=$(mywhich ntpq         )
           SYSP=$(mywhich sysp         )
        _3DDIAG=$(mywhich 3Ddiag       )
           LSHW=$(mywhich lshw         )
        SYSTOOL=$(mywhich systool      )
         SWAPON=$(mywhich swapon       )
         ASTCMD=$(mywhich asterisk     )

	# Netapp Tools
	SAN_UTIL_DIR=/opt/netapp/santools
	SAN_UTIL_PROG=sanlun
	SANLUN=$SAN_UTIL_DIR/$SAN_UTIL_PROG



	# Disks
          BTRFS=$(mywhich btrfs         )
  DEBUGREISERFS=$(mywhich debugreiserfs )
       EXPORTFS=$(mywhich exportfs      )
         HDPARM=$(mywhich hdparm        )
            LVM=$(mywhich lvm           )
      LVDISPLAY=$(mywhich lvdisplay     )
    LVMDISKSCAN=$(mywhich lvmdiskscan   )
         PVSCAN=$(mywhich pvs           )
            VGS=$(mywhich vgs           )
         VGSCAN=$(mywhich vgscan        )
      VGDISPLAY=$(mywhich vgdisplay     )
         PVSCAN=$(mywhich pvscan        )
            PVS=$(mywhich pvs           )
       REPQUOTA=$(mywhich repquota      )
	TUNE2FS=$(mywhich tune2fs	)

	# ZFS
	    ZFS=$(mywhich zfs		)
	  ZPOOL=$(mywhich zpool		)

	# Veritas FS
      PVDISPLAY=$(mywhich pvdisplay  )
           VXDG=$(mywhich vxdg       )
         VXDISK=$(mywhich vxdisk     )
        VXPRINT=$(mywhich vxprint    )
       VXLICREP=$(mywhich vxlicrep   )

	# Veritas Cluster
       HASTATUS=$(mywhich hastatus  )
          HARES=$(mywhich hares     )
          HAGRP=$(mywhich hagrp     )
         HATYPE=$(mywhich hatype    )
         HAUSER=$(mywhich hauser    )
        LLTSTAT=$(mywhich lltstat   )
      GABCONFIG=$(mywhich gabconfig )
           HACF=$(mywhich hacf      )

	# Redhat Cluster
           CLUSTAT=$(mywhich clustat )
         CLUSVCADM=$(mywhich clusvcadm )
           MKQDISK=$(mywhich mkqdisk )
         CMAN_TOOL=$(mywhich cman_tool )

	# CRM Cluster
                CRM=$(mywhich crm        )
            CRM_MON=$(mywhich crm_mon    )
         CRM_VERIFY=$(mywhich crm_verify )
           CIBADMIN=$(mywhich cibadmin   )

	# Network
       IFCONFIG=$(mywhich ifconfig )
       IWCONFIG=$(mywhich iwconfig )
        NETSTAT=$(mywhich netstat  )
        NFSSTAT=$(mywhich nfsstat  )
          ROUTE=$(mywhich route    )
        YPWHICH=$(mywhich ypwhich  )
             IP=$(mywhich ip 	   )
        MIITOOL=$(mywhich mii-tool )
       IPTABLES=$(mywhich iptables )
       IPCHAINS=$(mywhich ipchains )
        ETHTOOL=$(mywhich ethtool  )
          BRCTL=$(mywhich brctl    )
            ARP=$(mywhich arp      )


	# Tuning
         IOSTAT=$(mywhich iostat   )
         VMSTAT=$(mywhich vmstat   )
           IPCS=$(mywhich ipcs     )
       MODPROBE=$(mywhich modprobe )
         DEPMOD=$(mywhich depmod   )

	# Other
        DOVECOT=$(mywhich dovecot  )
           EXIM=$(mywhich exim     )
       RUNLEVEL=$(mywhich runlevel )
           LSOF=$(mywhich lsof 	   )
            TAR=$(mywhich tar 	   )
         XVINFO=$(mywhich xvinfo   )
       POSTCONF=$(mywhich postconf )

	# Virtual Server
             XM=$(mywhich xm       )
          VIRSH=$(mywhich virsh    )

	# Gentoo
      RC_UPDATE=$(mywhich rc-update )


}


##############################################################################
#
#      Function : release_information
#    Parameters :
#        Output :
#         Notes :
#
##############################################################################

function release_information
{

	Echo "Section - Release"
	MakeDir ${LOGDIR}/etc
	MakeDir ${LOGDIR}/system

	$CP -p  /etc/*-release  ${LOGDIR}/system

	if [ -f /etc/issue ] ; then
		$CP -p  "/etc/issue" ${LOGDIR}/system/issue
	fi

	if [ -f /etc/schmooze ] ; then
		$CP -rp  "/etc/schmooze" ${LOGDIR}/system/schmooze
	fi

	if [ -f /etc/issue.net ] ; then
		$CP -p  /etc/issue.net ${LOGDIR}/etc/issue.net
	fi

	if [ -f /etc/motd ] ; then
		$CP -p  /etc/motd ${LOGDIR}/etc/motd
	fi
}


##############################################################################
#
#      Function : proc_sys_info
#    Parameters :
#        Output :
#         Notes :  Collecting information from the proc directory
#
##############################################################################

function proc_sys_info
{
	Echo "Section - Collecting /proc and /sys Info"


	MakeDir ${LOGDIR}/proc

	$FIND /proc -type f -print 2>/dev/null | \
		$GREP -v "/proc/kcore"    | \
		$GREP -v "/proc/bus/usb"  | \
		$GREP -v "/proc/xen/xenbus"  | \
		$GREP -v "/proc/acpi/event"  | \
		$GREP -v "pagemap"  | \
		$GREP -v "clear_refs"  | \
		$GREP -v "kpagecount"  | \
		$GREP -v "kpageflags"  | \
		$GREP -v "/proc/kmsg" > $TMPFILE


	for i in $($CAT $TMPFILE)
	do
		Dirname=$(dirname $i)
		Filename=$(basename $i)

		MakeDir ${LOGDIR}${Dirname}

		if [ -e "$i" ] ; then

			if [[ -t 0 && ${VERBOSE} -ne 0 ]] ; then
  				spinningCursor
			fi

			$CAT "$i" > ${LOGDIR}${Dirname}/${Filename}  2>&1
		fi

		if [[ -t 0 && ${VERBOSE} -ne 0 ]] ; then
  			spinningCursor
		fi

	done

	echo


	$RM -f $TMPFILE

}

##############################################################################
#
#      Function : netbackup
#    Parameters :
#        Output :
#         Notes : Collect lots of Netbackup information if installed
#
##############################################################################


function netbackup
{
	Echo "Section - Netbackup "

	# Basic Netbackup collection
	NETBACKUPDIR="/usr/openv/netbackup"

	if [ ! -d $NETBACKUPDIR ] ; then
		NBACKUPDIR=${LOGDIR}/backups/netbackup
		MakeDir $NBACKUPDIR
	else
		return
	fi


	PATH=$PATH:$NETBACKUPDIR
	export PATH

	bpstulist -L 	>> $NBACKUPDIR/bpstulist_-L.out

	bppllist 	 > $NBACKUPDIR/bppllist.out

	cat  $NBACKUPDIR/bppllist.out | while read line
	do
		bppllist $line  -U > $NBACKUPDIR/bppllist_${line}_-U.out
	done


	bpps -a 	> $NBACKUPDIR/bpps_-a.out
	bpconfig -l 	> $NBACKUPDIR/bpconfig_-l.out
	bpconfig -L 	> $NBACKUPDIR/bpconfig_-L.out
	vmquery -a 	> $NBACKUPDIR/vmquery_-a.out
	tpconfig -d 	> $NBACKUPDIR/tpconfig_-d.out
	bpmedia 	> $NBACKUPDIR/bpmedia.out
	bpmedialist 	> $NBACKUPDIR/bpmedialist.out
	available_media > $NBACKUPDIR/available_media.out

	bperror -U -backstat -hoursago 48 > $NBACKUPDIR/bperror_-U_-backstat_-hoursago_48.out

	MakeDir $NBackupDir/configs
	cp /usr/openv/netbackup/*.conf $NBACKUPDIR/configs

}


##############################################################################
#
#      Function : hardware_checks
#    Parameters :
#        Output :
#         Notes : Collect Hardware Information
#
##############################################################################

function hardware_checks
{

	Echo "Section - Hardware Info"

	if [ -x $CARDCTL ] ; then
		$CARDCTL info   	> ${LOGDIR}/hardware/cardctl-info.out 2>&1
		$CARDCTL status 	> ${LOGDIR}/hardware/cardctl-status.out 2>&1
		# $CARDCTL ident  	> ${LOGDIR}/hardware/cardctl-ident.out 2>&1
	fi

	MakeDir ${LOGDIR}/hardware/lspci

	if [ -x $LSPCI ] ; then
		$LSPCI          > ${LOGDIR}/hardware/lspci/lspci.out 2>&1
		$LSPCI -n       > ${LOGDIR}/hardware/lspci/lspci-n.out 2>&1
		$LSPCI -knn     > ${LOGDIR}/hardware/lspci/lspci-knn.out 2>&1

		$LSPCI  | while read line
		do
			Bus=$(/bin/echo $line 2>/dev/null | awk '{ print $1 }')
			$LSPCI -vv -s $Bus > ${LOGDIR}/hardware/lspci/lspci_-vv_-s_${Bus}.out 2>&1
		done
	fi


	# Get the port names from the HDA cards
	for i in /sys/class/scsi_host/host*/device/fc_host\:host*/port_name
	do
		if [ -f $i ] ; then
			name=$( echo $i | sed 's/\//_/g' | sed 's/^_//g')
			echo "Port Name : $(cat $i )" >> ${LOGDIR}/hardware/lspci/cat_${name}.out
		fi
	done



	# Get a listing of the /dev directory
	MakeDir ${LOGDIR}/dev

	$LS -laR /dev  > ${LOGDIR}/dev/ls_-laR_dev.out

	if [ -x "$LSUSB" ] ; then
		$LSUSB -xv > ${LOGDIR}/hardware/lsusb_-xv.out 2>&1
		$LSUSB -tv > ${LOGDIR}/hardware/lsusb_-tv.out 2>&1
	fi


	if [ -x "$LSDEV" ] ; then
		$LSDEV -type adaptor > ${LOGDIR}/hardware/lsdev_-type_adaptor.out 2>&1
	fi

	if [ -x "$ACPI" ] ; then
		$ACPI -V > ${LOGDIR}/hardware/acpi-V.out 2>&1
	fi

	if [ -x $FREE ] ; then
		$FREE    > ${LOGDIR}/hardware/free.out
		$FREE -k > ${LOGDIR}/hardware/free_-k.out
	fi


	$LS -laR /dev > ${LOGDIR}/hardware/ls-laR_dev.out

	if [ -d /udev ] ; then
		$LS -laR /udev > ${LOGDIR}/hardware/ls-laR_udev.out
	fi


	# Tape information
	if [ -f /etc/stinit.def ] ; then
		$CP -p /etc/stinit.def ${LOGDIR}/etc/stinit.def
	fi


	# Global Devices list
	if [ -x "$LSHAL" ] ; then
		$LSHAL  > ${LOGDIR}/hardware/lshal.out
	fi

	if [ -x /usr/share/rhn/up2date_client/hardware.py ] ; then
		/usr/share/rhn/up2date_client/hardware.py > ${LOGDIR}/hardware/hardware.py.out 2>&1
	fi

	if [ -x "$SMARTCTL" ] ; then
		for device in $( $LS /dev/hd[a-z] /dev/sd[a-z] /dev/st[0-9] /dev/sg[0-9]  2> /dev/null)
		do
			name=$( echo $device | sed 's/\//_/g' )
			${SMARTCTL} -a $device 2>/dev/null 1> ${LOGDIR}/hardware/smartctl-a_${name}.out
		done
	fi



	##############################################################################
	# Collect Hardware information from the hwinfo program if installed
	##############################################################################

	if [ -x $HWINFO ] ; then
		$HWINFO                 > ${LOGDIR}/hardware/hwinfo.out                 2>&1
		$HWINFO  --isapnp       > ${LOGDIR}/hardware/hwinfo_--isapnp.out        2>&1
		$HWINFO  --scsi         > ${LOGDIR}/hardware/hwinfo_--scsi.out          2>&1
		$HWINFO  --framebuffer  > ${LOGDIR}/hardware/hwinfo_--framebuffer.out   2>&1
	fi


	if [ -x "$PROCINFO"  ] ; then
		$PROCINFO  > ${LOGDIR}/hardware/procinfo.out 2>&1
	fi


	if [ -x "$DMIDECODE" ] ; then
		$DMIDECODE  > ${LOGDIR}/hardware/dmidecode.out 2>&1
	fi


	if [ -x $LSHW  ] ; then
		$LSHW > ${LOGDIR}/hardware/lshw.out 2>&1
	fi

	$CAT /proc/cpuinfo	> ${LOGDIR}/hardware/proc_cpuinfo.out		2>&1
	$CAT /proc/meminfo	> ${LOGDIR}/hardware/proc_meminfo.out 		2>&1
	$CAT /proc/mdstat  	> ${LOGDIR}/hardware/proc_mdstat.out 		2>&1
	$CAT /proc/interrupts	> ${LOGDIR}/hardware/proc_interrupts.out	2>&1
	$CAT /proc/filesystem	> ${LOGDIR}/hardware/proc_filesystems.out	2>&1
	$CAT /proc/devices	> ${LOGDIR}/hardware/proc_devices.out		2>&1
	$CAT /proc/iomem	> ${LOGDIR}/hardware/proc_iomem.out		2>&1
	$CAT /proc/ioports	> ${LOGDIR}/hardware/proc_ioports.out		2>&1
	$CAT /proc/partitions	> ${LOGDIR}/hardware/proc_partitions.out	2>&1
	$CAT /proc/slabinfo	> ${LOGDIR}/hardware/proc_slabinfo.out		2>&1
	$CAT /proc/softirqs	> ${LOGDIR}/hardware/proc_softirqs.out		2>&1


	physicalCPUs=$( $CAT /proc/cpuinfo | grep "physical id" | $SORT | $UNIQ | $WC -l )
	    cpuCores=$( $CAT /proc/cpuinfo | grep "cpu cores"  | $UNIQ  )
       cpuProcessors=$( $CAT /proc/cpuinfo | grep "^processor" | $UNIQ  )


	echo "Physical CPU      : $physicalCPUs" 	>> ${LOGDIR}/hardware/cpu_details.txt
	echo "CPU Cores         : $cpuCores" 		>> ${LOGDIR}/hardware/cpu_details.txt
	echo "CPU Processors    : $cpuCores" 		>> ${LOGDIR}/hardware/cpu_details.txt
}






##############################################################################
#
#      Function : boot_section
#    Parameters :
#        Output :
#         Notes : Capture the files required to boot the system
#
##############################################################################


function boot_section
{

	Echo "Section - Boot Info"

	if [ -x "/sbin/lilo" ] ; then
		/sbin/lilo -q 	> $LOGDIR/system/lilo_-q  2>&1
	fi

	$LS -alR /boot	> ${LOGDIR}/system/ls-alR_boot.out 2>&1

	MakeDir ${LOGDIR}/boot/grub
	MakeDir ${LOGDIR}/software
	MakeDir ${LOGDIR}/system

	for i in  /boot/grub/menu.lst  /boot/grub/grub.conf \
		  /boot/grub.conf /boot/grub/device.map
	do
		if [ -f ${i} ] ; then
			$CP -p ${i} ${LOGDIR}/${i}
		fi
	done

	if [ -f /etc/inittab ] ; then
		$CP -p /etc/inittab	${LOGDIR}/etc/inittab
	fi


	if [ -x "$CHKCONFIG" ] ; then
		$CHKCONFIG --list > ${LOGDIR}/software/chkconfig_--list.out 2>&1
	fi

	if [ -x "$SYSTEMCTL" ] ; then
		$SYSTEMCTL --full --no-pager    > ${LOGDIR}/system/systemctl_--full_--nopager
	fi
}


##############################################################################
#
#      Function : config_files
#    Parameters :
#        Output :
#         Notes : Basically take a copy of all the important files in /etc
#
##############################################################################

function config_files
{
	Echo "Section - /etc Config Files "

	for i in $( $FIND /etc -name "*.conf" -o -name "*.cf" -o -name "*.cnf" -name "*.cfg" )
	do
		dirname="$(dirname $i)"
		filename="$(basename $i)"

		if [ ! -d ${LOGDIR}/${dirname} ] ; then
			MakeDir ${LOGDIR}/${dirname}
		fi

		$CP -p $i ${LOGDIR}/${dirname}/${filename} 2>/dev/null

	done



	if [ -f /etc/nologin.txt ] ; then
		$CP -p /etc/nologin.txt ${LOGDIR}/etc/nologin.txt
	fi


	$CP -p /etc/securetty 	${LOGDIR}/etc/securetty
	$CP -p /etc/shells 	${LOGDIR}/etc/shells

	if [ -f  /etc/krb.realms ] ; then
		$CP -p /etc/krb.realms 	${LOGDIR}/etc/krb.realms
	fi



	##############################################################################
	# Copy the /etc/profile.d scripts
	##############################################################################

	if [ -d /etc/profile.d ] ; then
		$CP -Rp /etc/profile.d ${LOGDIR}/etc
	fi

	##############################################################################
	# Copy the /etc/modprobe.d scripts
	##############################################################################

	if [ -d /etc/profile.d ] ; then
		$CP -Rp /etc/modprobe.d ${LOGDIR}/etc
	fi


	##############################################################################
	# New in Fedora 9
	##############################################################################

	if [ -d /etc/event.d ] ; then
		$CP -Rp /etc/event.d ${LOGDIR}/etc
	fi


	##############################################################################
	# Get all the pcmcia config information
	##############################################################################

	if [ -d /etc/pcmcia ] ; then

		if [ ! -d ${LOGDIR}/pcmcia  ] ; then
			MakeDir ${LOGDIR}/etc/pcmcia
		fi

		$CP -R -p /etc/pcmcia/*.opts 	${LOGDIR}/etc/pcmcia

	fi

}



##############################################################################
#
#      Function : performance_info
#    Parameters :
#        Output :
#         Notes : some general information about performance
#
##############################################################################

function performance_info
{

	Echo "Section - Performance/System "

	MakeDir ${LOGDIR}/system/performance


	if [ -e /proc/stat ] ; then
		$CAT /proc/stat      	> ${LOGDIR}/system/stat.out
	fi

	$DATE				> ${LOGDIR}/system/date.out
	$FREE				> ${LOGDIR}/system/free.out
	$PS auxw			> ${LOGDIR}/system/ps_auxw.out
	$PS -lef			> ${LOGDIR}/system/ps_-elf.out
	$PSTREE			 	> ${LOGDIR}/system/pstree.out
	$HOSTNAME			> ${LOGDIR}/system/hostname.out
	$IPCS -a			> ${LOGDIR}/system/ipcs_-a.out
	$IPCS -u			> ${LOGDIR}/system/ipcs_-u.out
	$IPCS -l			> ${LOGDIR}/system/ipcs_-l.out
	$UPTIME				> ${LOGDIR}/system/uptime.out
	ulimit -a			> ${LOGDIR}/system/ulimit_-a.out

	if [ -x $VMSTAT ] ; then
		$VMSTAT -s		> ${LOGDIR}/system/performance/vmstat_-s.out
	fi

	if [ "$LSOF" != "" ] ; then
		$LSOF >  ${LOGDIR}/system/lsof.out	2>&1
	fi


	if [ -d /var/log/sa ] ; then
		$CP -p /var/log/sa/sa*	 ${LOGDIR}/system/performance/
	fi

	if [ -e /proc/loadavg ] ; then
		$CAT /proc/loadavg   	> ${LOGDIR}/system/performance/loadavg.out
	fi

}



##############################################################################
#
#      Function : kernel_info
#    Parameters :
#        Output :
#         Notes : Kernel information
#
##############################################################################


function kernel_info
{

	Echo "Section - Kernel info"

	$SYSCTL  -A			> ${LOGDIR}/etc/sysctl_-A.out  2>&1
	$UNAME -a 			> ${LOGDIR}/system/uname_-a.out
	$RUNLEVEL			> ${LOGDIR}/system/runlevel.out
	$WHO -r				> ${LOGDIR}/system/who_-r.out
	$SLABTOP -o			> ${LOGDIR}/system/slabtop_-o.out



	if [ -f /etc/conf.modules ] ; then
		$CP -p /etc/conf.modules	${LOGDIR}/etc/conf.modules
	fi


	if [ ! -d ${LOGDIR}/kernel/info ] ; then
		MakeDir ${LOGDIR}/kernel/info
	fi

	$LSMOD			> ${LOGDIR}/kernel/lsmod.out 2>&1

	$LSMOD | while read line
	do
		kernmod=$( echo $line | $AWK '{ print $1 }' )
		$MODINFO $kernmod  > ${LOGDIR}/kernel/info/${kernmod}.out 2>&1
	done


	if [ -x $KSYMS ] ; then
		$KSYMS 		> ${LOGDIR}/kernel/ksyms.out 2>&1
	fi

	$CP -p /lib/modules/$($UNAME -r)/modules.dep ${LOGDIR}/kernel/modules.dep


	$MODPROBE -n -l -v		> ${LOGDIR}/kernel/modprobe_-n-l-v.out  2>&1
	$DEPMOD -av			> ${LOGDIR}/kernel/depmod_-av.out       2>&1
	$CAT /proc/modules		> ${LOGDIR}/kernel/modules.out          2>&1


	##############################################################################
	# Just incase we have a debian system
	##############################################################################

	if [ -f /etc/kernel-pkg.conf ] ; then
		$CP -p /etc/kernel-pkg.conf   ${LOGDIR}/etc/kernel-pkg.conf
	fi

	if [ -f /etc/kernel-img.conf ] ; then
		$CP -p /etc/kernel-img.conf   ${LOGDIR}/etc/kernel-img.conf
	fi

	##############################################################################
	# Get the kernel configuration details from a 2.6 kernel
	##############################################################################

	if [ -f /proc/config.gz ] ; then
		$GUNZIP -c /proc/config.gz  > ${LOGDIR}/kernel/config
	fi


}




##############################################################################
#
#      Function : hot_plug
#    Parameters :
#        Output :
#         Notes : Take a copy of the /etc/hotplug directory
#
##############################################################################


function hot_plug
{
	Echo "Section - Hot Plug info"

	if [ -d /etc/hotplug ] ; then

		if [ ! -d ${LOGDIR}/etc/hotplug ] ; then
			MakeDir ${LOGDIR}/etc/hotplug
		fi

		cd /etc/hotplug
		$CP -Rp *  ${LOGDIR}/etc/hotplug/
	fi
}


##############################################################################
#
#      Function : disk_info
#    Parameters :
#        Output :
#         Notes : Collect general information about the disks on this system
#
##############################################################################

function disk_info
{
	Echo "Section - Disk Section Checks"
	local Dirname


	MakeDir ${LOGDIR}/hardware/disks

	# Check to see what is mounted

	$DF -k    	> ${LOGDIR}/hardware/disks/df_-k.out	2>&1
	$DF -h    	> ${LOGDIR}/hardware/disks/df_-h.out	2>&1
	$DF -ki   	> ${LOGDIR}/hardware/disks/df_-ki.out	2>&1
	$DF -aki  	> ${LOGDIR}/hardware/disks/df_-aki.out	2>&1
	$DF -akih 	> ${LOGDIR}/hardware/disks/df_-akih.out	2>&1

	if [ -x $SWAPON ] ; then
		$SWAPON -s > ${LOGDIR}/hardware/disks/swapon_-s.out	2>&1
	fi

	$MOUNT			> ${LOGDIR}/hardware/disks/mount.out 		2>&1
	$MOUNT -l		> ${LOGDIR}/hardware/disks/mount_-l.out 		2>&1

	$CAT /proc/mounts 	> ${LOGDIR}/hardware/disks/mounts.out		2>&1


	# fstab Information
	$CP -p /etc/fstab   ${LOGDIR}/hardware/disks/fstab


	# Display any quotas that my have been set
	$REPQUOTA -av		> ${LOGDIR}/hardware/disks/repquota_-av	2>&1


	##############################################################################
	# Disk Format Information
	##############################################################################

	DISKLIST=$($FDISK -l  2>/dev/null | grep "^/dev" | sed 's/[0-9]//g' | awk '{ print $1 }' | sort -u)

	if [ -x $FDISK ] ; then
		$FDISK   -l	> ${LOGDIR}/hardware/disks/fdisk_-l.out  2>&1
	fi

	if [ -x $SFDISK ] ; then
		$SFDISK  -l	> ${LOGDIR}/hardware/disks/sfdisk_-l.out  2>&1
		$SFDISK  -s	> ${LOGDIR}/hardware/disks/sfdisk_-s.out 2>&1
	fi

	if [ -x $BLKID ] ; then
		$BLKID  	> ${LOGDIR}/hardware/disks/blkid.out 2>&1
	fi

	if [ -x $LSBLK ] ; then
		$LSBLK -f 	> ${LOGDIR}/hardware/disks/lsblk_-f.out 2>&1
	fi

	if [ -x $LSSCSI ] ; then
		$LSSCSI -l 	> ${LOGDIR}/hardware/disks/lsscsi_-l.out 2>&1
		$LSSCSI -g 	> ${LOGDIR}/hardware/disks/lsscsi_-g.out 2>&1
	fi

	for DISK in $DISKLIST
	do

		Dirname=$(dirname $DISK)

		if [ "$Dirname" = "/dev/mapper" ] ; then

			if [ ! -L  $DISK ] ; then
				continue
			fi
		fi

		NEWDISK=$(/bin/echo $DISK |  sed s'/\/dev\///g' )

		MakeDir ${LOGDIR}/hardware/disks/${NEWDISK}

		if [ -x $HDPARM ] ; then
			$HDPARM -vIi $DISK 		> ${LOGDIR}/hardware/disks/${NEWDISK}/hdparm_-vIi_${NEWDISK}.out 2>&1
		fi

		if [ -x $SFDISK ] ; then
			$SFDISK  -l $DISK		> ${LOGDIR}/hardware/disks/${NEWDISK}/sfdisk_-l_${NEWDISK}.out 2>&1
		fi

		if [ -x $FDISK ] ; then
			$FDISK   -l $DISK		> ${LOGDIR}/hardware/disks/${NEWDISK}/fdisk_-l_${NEWDISK}.out 2>&1
		fi

	done


	if [ -x "$DUMPE2FS" ] ; then

		MakeDir ${LOGDIR}/hardware/disks/dumpe2fs

		PARTS=$($FDISK -l 2>/dev/null | grep "^/dev" | awk '{ print $1 }')

		for parts in $PARTS
		do
			name=$(/bin/echo $parts | sed 's/\//_/g')
			$DUMPE2FS $parts 		> ${LOGDIR}/hardware/disks/dumpe2fs/fdisk_-l_${name}.out 2>&1
		done

	fi



	##############################################################################
	# Collect Detailed SCSI information about the disks
	##############################################################################

	if [ -x "$SCSI_ID" ] ; then

    		for i in $($LS sd[a-z] 2>/dev/null)
    		do

			if [ -b /dev/${i} ] ; then

     				disk_name=$(/bin/echo /dev/${i} | sed 's/\//_/g')

				$SCSI_ID -g -p 0x80 -d /dev/${i} -s /block/${i} \
				     > ${LOGDIR}/hardware/disks/scsi_id_-g_-p_0x80_${disk_name}.out 2>&1

				$SCSI_ID  -g -p 0x83 -d /dev/${i} -s /block/${i} \
				     > ${LOGDIR}/hardware/disks/scsi_id_-g_-p_0x83_${disk_name}.out 2>&1
        		fi
		done


		for disk in $($LS  /dev/sd*)
		do
			wwid=`$SCSI_ID -g -u $disk`
			if [ "$wwid" != "" ] ; then
				$ECHO -e "Disk:" $disk_short "\tWWID:" $wwid >> ${LOGDIR}/hardware/disks/disk_mapping-wwid.out
			fi
		done


	fi

	if [ -x $SYSTOOL ] ; then
		$SYSTOOL -c scsi_host -v  > ${LOGDIR}/hardware/disks/systool_-c_scsi_host_-v.out 2>&1
	fi


	##############################################################################
	# If we are using multi-pathings then print out the
	# multi-pathing information
	##############################################################################

	if [ -x "$MULTIPATH" ] ; then
		 $MULTIPATH -ll  > ${LOGDIR}/hardware/disks/multipath_-ll.out 2>&1
		 $MULTIPATH -v4  > ${LOGDIR}/hardware/disks/multipath_-v2.out 2>&1
	fi


	if [ -x "$DMSETUP" ] ; then
		MakeDir  ${LOGDIR}/hardware/disks/dmsetup
		$DMSETUP ls         > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_ls.out 2>&1
		$DMSETUP ls --tree  > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_ls--info.out  2>&1
		$DMSETUP info       > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_info.out      2>&1
		$DMSETUP info       > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_info-C.out    2>&1
		$DMSETUP deps       > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_deps.out      2>&1
		$DMSETUP targets    > ${LOGDIR}/hardware/disks/dmsetup/dmsetup_targets.out   2>&1

	fi


	# Check to see what iscsi devices have
	if [ -x "$ISCSIADM" ] ; then
		$ISCSIADM -m session > ${LOGDIR}/hardware/disks/iscsiadm_-m_session.out 2>&1
	fi

}

##############################################################################
#
#      Function : emc_powerpath_info
#    Parameters :
#        Output :
#         Notes : If Powerpath is installed then get some information
#
##############################################################################

function emc_powerpath_info
{
	Echo "Section - EMC Powerpath checks"


	if [ ! -d  ${LOGDIR}/hardware/disks/emcpower ] ; then
		MakeDir  ${LOGDIR}/hardware/disks/emcpower
	fi

	EMCPOWER=${LOGDIR}/hardware/disks/emcpower

	# Check to see what emc powerpath devices we have
	if [ ! -x "$POWERMT" ] ; then
		$ECHO "No $POWERMT Program found" > ${EMCPOWER}/Readme.out
		return
	fi



	$POWERMT check_registration 		>${EMCPOWER}/powermt_check_registration.out 2>&1
	$POWERMT display path			>${EMCPOWER}/powermt_display_path.out 2>&1
	$POWERMT display ports			>${EMCPOWER}/powermt_display_ports.out 2>&1
	$POWERMT display paths class=all	>${EMCPOWER}/powermt_display_paths_class=all.out 2>&1
	$POWERMT display ports dev=all		>${EMCPOWER}/powermt_display_ports_dev=all.out 2>&1
	$POWERMT display dev=all		>${EMCPOWER}/powermt_display_dev=all.out 2>&1


	# Get the partition details for the EMC devices
	for emcdevice in $(ls /dev/emcpower*)
	do
       		emc_disk_name=$(/bin/echo ${emcdevice} | sed 's/\//_/g')
		$FDISK -l $emcdevice 		>${EMCPOWER}/fdisk_-l_${emc_disk_name}.out 2>&1
	done
}


##############################################################################
#
#      Function : netapp_info
#    Parameters :
#        Output :
#         Notes : Check if we have netapp software installed - collect info
#
##############################################################################


function netapp_info
{

	if [ ! -x $SANLUN ] ; then
		$ECHO "No $SANLUN Program found" 		> ${NETAPPDIR}/Readme.out
		return
	fi

	if [ ! -d ${LOGDIR}/hardware/disks/netapp ] ; then
		MakeDir  ${LOGDIR}/hardware/disks/netapp
	fi

	Echo "Section - Netapp checks"

	NETAPPDIR=${LOGDIR}/hardware/disks/netapp

	MakeDir $NETAPPDIR

	$SANLUN version 			> ${NETAPPDIR}/sanlun_version 2>&1
	$SANLUN lun show -v all			> ${NETAPPDIR}/sanlun_lun_show_-v_all 2>&1
	$SANLUN fcp show adapter -v all 	> ${NETAPPDIR}/sanlun_fcp_show_adapter_-v_all 2>&1
	$SANLUN lun show -v all			> ${NETAPPDIR}/sanlun_lun_show-v_all 2>&1
	$SANLUN fcp show adapter -v all		> ${NETAPPDIR}/sanlun_fcp_show_adapter_-v_all 2>&1


}


##############################################################################
#
#      Function : veritas_vm
#    Parameters :
#        Output :
#         Notes : Collect information about veritas volume manager
#
##############################################################################

function veritas_vm
{
	Echo "Section - Veritas Volume Manager checks"


	if [ -d /etc/vx/licenses/lic ] ; then

		if [ ! -d  ${LOGDIR}/etc/vx/licenses/lic ] ; then
			MakeDir  ${LOGDIR}/etc/vx/licenses/lic
    		fi

		$CP -Rp /etc/vx/licenses/lic ${LOGDIR}/etc/vx/licenses/
		$VXLICREP -e > ${LOGDIR}/system/vxlicrep_-e.out 2>&1
	fi

	if [ -d /etc/vx/cbr/bk ] ; then

		if [ ! -d  ${LOGDIR}/etc/vx/cbr/bk ] ; then
			MakeDir ${LOGDIR}/etc/vx/cbr/bk
		fi

		$CP -Rp /etc/vx/cbr/bk ${LOGDIR}/etc/vx/cbr/
	fi


	if [ -d /dev/vx ] ; then

		if [ ! -d  ${LOGDIR}/disks/vxvm ] ; then
			MakeDir ${LOGDIR}/hardware/disks/vxvm
			MakeDir ${LOGDIR}/hardware/disks/vxvm/logs
			MakeDir ${LOGDIR}/hardware/disks/vxvm/disk_groups
		fi


		$LS -laR /dev/vx >  ${LOGDIR}/hardware/disks/vxvm/ls-lR_dev_vx.out 2>&1

		if [ -x $VXDISK  ] ; then
			$VXDISK list   			> ${LOGDIR}/hardware/disks/vxvm/vxdisk_list.out		    2>&1
			$VXDISK -o alldgs list  	> ${LOGDIR}/hardware/disks/vxvm/vxdisk_-o_alldgs_list.out    2>&1
			$VXPRINT -Ath  			> ${LOGDIR}/hardware/disks/vxvm/vxprint_-Ath.out   	    2>&1
			$VXPRINT -h    			> ${LOGDIR}/hardware/disks/vxvm/vxprint_-h.out     	    2>&1
			$VXPRINT -hr   			> ${LOGDIR}/hardware/disks/vxvm/vxprint_-hr.out    	    2>&1
			$VXPRINT -th   			> ${LOGDIR}/hardware/disks/vxvm/vxprint_-th.out    	    2>&1
			$VXPRINT -thrL 			> ${LOGDIR}/hardware/disks/vxvm/vxprint_-thrL.out  	    2>&1
		fi


		if [ -x $VXDG ] ; then
			$VXDG -q list  			> ${LOGDIR}/hardware/disks/vxvm/vxdg_-q_-list.out   2>&1
		fi


		#------------------------------------------------------------------------
		# Collect individual volume information
		#------------------------------------------------------------------------

		for i in $($VXDG -q list|awk '{print $1}')
		do
			$VXDG list $i     > ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxdg_list_${i}.out
			$VXDG -g $i free  > ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxdg_-g_free_${i}.out

			$VXPRINT -vng $i  > ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxprint_-vng_${i}.out

			VOL=$(cat ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxprint_-vng_${i}.out)

			$VXPRINT -hmQqg $i $VOL  \
				> ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxprint_-hmQqg_4vxmk=${i}.out 2>&1

			$VXPRINT -hmQqg $i   \
				> ${LOGDIR}/hardware/disks/vxvm/disk_groups/vxprint_-hmQqg=${i}.out 2>&1

		done

	fi

}


##############################################################################
#
#      Function : filesystem_info
#    Parameters :
#        Output :
#         Notes : General Filesystem information
#
##############################################################################


function filesystem_info
{
	Echo "Section - Filesystem checks"

	MakeDir ${LOGDIR}/hardware/disks/tunefs

	for i in $($DF -kl | grep ^/dev | awk '{ print $1 }')
	do
		if [ -x $TUNE2FS  ] ; then
       			name=$(/bin/echo $i | sed 's/\//_/g')
			$TUNE2FS  -l $i > ${LOGDIR}/hardware/disks/tunefs/tunefs_-l_${name}.out 2>&1
		fi
	done
}


##############################################################################
#
#      Function : nfs_info
#    Parameters :
#        Output :
#         Notes : Get some information about the NFS service
#
##############################################################################


function nfs_info
{
	Echo "Section - NFS checks"

	# Copy NFS config files around
	if [ -f /etc/auto.master ] ; then
		$CP -Rp /etc/auto*	  ${LOGDIR}/etc
	fi

	# lets see what we have really exported
	if [ -x $EXPORTFS ] ; then
		$EXPORTFS -v	> ${LOGDIR}/hardware/disks/exportfs_-v.out 2>&1
	fi

	# This is what we have configured to be exported
	if [ -f /etc/exports ] ; then
		$CP -p /etc/exports	 ${LOGDIR}/etc/exports
	fi


	if [ -x "$NFSSTAT" ] ; then
		$NFSSTAT -a > ${LOGDIR}/hardware/disks/nfsstat_-a.out 2>&1
	fi
}


##############################################################################
#
#      Function : raid_info
#    Parameters :
#        Output :
#         Notes : Check raid used on this system
#
##############################################################################

function raid_info
{
	Echo "Section - Disk Raid checks"

	if [ -f /etc/raidtab ] ; then
		$CP -p /etc/raidtab ${LOGDIR}/etc/raidtab
	fi

	MakeDir ${LOGDIR}/hardware/disks/raid

	if [ -x "$LSRAID" ] ; then
		for i in $( $LS /dev/md[0-9]* 2>/dev/null )
		do
       			name=$(/bin/echo $i | sed 's/\//_/g')
			    $LSRAID -a $i > ${LOGDIR}/hardware/disks/raid/lsraid_-a_${name}.out > /dev/null 2>&1
		done
	fi

	if [ -x "$MDADM" ] ; then
		for i in $( $LS /dev/md[0-9]* 2>/dev/null )
		do
       			name=$( echo $i | sed 's/\//_/g' )
			    $MDADM --detail $i > ${LOGDIR}/hardware/disks/raid/mdadm_--detail_${name}.out > /dev/null 2>&1

			if [ ! -s ${LOGDIR}/hardware/disks/raid/mdadm--detail_${name}.out ] ; then
				$RM -f ${LOGDIR}/hardware/disks/raid/mdadm--detail_${name}.out
			fi
		done
	fi
}


##############################################################################
#
#      Function : brtfs_info
#    Parameters :
#        Output :
#         Notes : Lets look at BRTS - new Linux filesystem
#
##############################################################################

function brtfs_info
{

	Echo "Section - btrfs Section"

	MakeDir ${LOGDIR}/hardware/disks/btrfs

	# Scan all devices
	if [ -x $BTRFS ] ; then
		${BRTFS} filesystem show > ${LOGDIR}/hardware/disks/btrfs/btrfs_filesystem_show.out > /dev/null 2>&1

		$DF -h -t btrfs 2>/dev/null | grep -v Filesystem  | while read line
		do
			FS=$(echo $line | awk '{print $6}')
       			FSN=$( echo $FS | sed 's/\//_/g' )

			if [ "$FS" = "/" ] ; then
				FSN="root"
			fi

			$BTRFS filesystem df  $FS > ${LOGDIR}/hardware/disks/btrfs/btrfs_filesystem_df_$FSN 2>&1
			$BTRFS subvolume list $FS > ${LOGDIR}/hardware/disks/btrfs/btrfs_subvolume_list_$FSN 2>&1
 		done
	fi
}

##############################################################################
#
#      Function : zfs_info
#    Parameters :
#        Output :
#         Notes : Solaris - ZFS Volume Manager - collect details
#
##############################################################################

function zfs_info
{

	if [ -x "$ZPOOL" ] ; then

		Echo "Section - ZFS "

		ZFSDIR=${LOGDIR}/hardware/disks/zfs
		MakeDir ${ZFSDIR}

		$ZPOOL status -v	> ${ZFSDIR}/zpool_status_-v.out 2>&1
		$ZPOOL status -D	> ${ZFSDIR}/zpool_status_-D.out 2>&1
		$ZPOOL history		> ${ZFSDIR}/zpool_history.out 2>&1
		$ZPOOL list		> ${ZFSDIR}/zpool_list.out 2>&1

		$ZFS list		> ${ZFSDIR}/zfs_list.out 2>&1
		$ZFS list -o space	> ${ZFSDIR}/zfs_list_-o_space.out 2>&1
		$ZFS list -t snapshots	> ${ZFSDIR}/zfs_list_-t_snapshots.out 2>&1

		$ZFS get all		> ${ZFSDIR}/zfs_get_all.out 2>&1


		for poolname in $($ZPOOL list | grep -v NAME | $AWK '{print $1}')
		do
			$ZFS get all $poolname 	> ${ZFSDIR}/zfs_get_all_$poolname.out 2>&1
			$ZPOOL status $poolname > ${ZFSDIR}/zpool_status_$poolname.out 2>&1
		done
	fi


}

##############################################################################
#
#      Function : lvm_info
#    Parameters :
#        Output :
#         Notes : Logical Volume Manager - collect details
#
##############################################################################

function lvm_info
{

	Echo "Section - LVM "

	LVMDIR=${LOGDIR}/hardware/disks/lvm
	MakeDir ${LVMDIR}

	if [ -x "$LVDISPLAY" ] ; then
		$LVDISPLAY -vv 	> ${LVMDIR}/lvdisplay_-vv.out  2>&1
		$VGDISPLAY -vv 	> ${LVMDIR}/vgdisplay_-vv.out  2>&1
		$VGSCAN -vv    	> ${LVMDIR}/vgscan_-vv.out     2>&1
		$LVMDISKSCAN -v > ${LVMDIR}/lvmdiskscan_-v.out 2>&1
		$PVSCAN -v      > ${LVMDIR}/pvscan_-v.out      2>&1
		$PVDISPLAY -v   > ${LVMDIR}/pvdisplay_-v.out   2>&1
		$VGS -v         > ${LVMDIR}/vgs-v.out          2>&1
		$PVSCAN -v      > ${LVMDIR}/pvscan-v.out       2>&1

 		 # Map every DM device to a disk
		$LVDISPLAY 2>/dev/null | \
			$AWK  '/LV Name/{n=$3} /Block device/{d=$3; sub(".*:","dm-",d); print d,n;}' \
			> ${LVMDIR}/devices.out 2>&1
	fi

	if [ -x "$LVM" ] ; then
		$LVM dumpconfig 	 		> ${LVMDIR}/lvm_dumpconfig.out				2>&1
		$LVM lvs         			> ${LVMDIR}/lvm_lvs.out					2>&1
		$LVM pvs -o +lv_name,lv_size,seg_all	> ${LVMDIR}/pvs_-o_+lv_name:lv_size:seg_all.out		2>&1
	fi


}


##############################################################################
#
#      Function : disk_dm_info
#    Parameters :
#        Output :
#         Notes : Collect more Disk information
#
##############################################################################


function disk_dm_info
{

	Echo "Section - Disk DM Info "

	# Work out which dm device is being used by each filesystem
	grep dm-[0-9] /proc/diskstats | awk '{print $1, $2, $3}' | while read line
	do

		 Major=$(echo $line | awk '{print $1}' )
		 Minor=$(echo $line | awk '{print $2}' )
		Device=$(echo $line | awk '{print $3}' )


		List=$(ls -la /dev/mapper | grep "${Major},  ${Minor}" | awk '{print $(NF)}')

		echo "$Device = $List " >> ${LOGDIR}/hardware/disks/dm-info.out

	done
}


##############################################################################
#
#      Function : rpm_info
#    Parameters :
#        Output :
#         Notes : Check all packages installed
#
##############################################################################


function rpm_info
{

	if [ -x "$RPM" ] ; then

		Echo "Section - rpm package information "
		MakeDir ${LOGDIR}/software/rpm/rpm-packages

		#
		# Short Description of all packages installed
		#

		echo "Package_Name		Version		Size		Description" 	> ${LOGDIR}/software/rpm/rpm-qa--queryformat.out
		echo "===================================================================================" >> ${LOGDIR}/software/rpm/rpm-qa--queryformat.out

		$RPM -qa --queryformat '%-25{NAME}  %-16{VERSION} %-10{RELEASE} %-10{DISTRIBUTION}  %-10{SIZE} %-10{INSTALLTIME:date} %{SUMMARY}\n' | sort >> ${LOGDIR}/software/rpm/rpm-qa--queryformat.out 2>&1


		#
		# Long Description of all packages installed
		#

		$RPM -qa > ${LOGDIR}/software/rpm/rpm_-qa 2>&1

		$CAT ${LOGDIR}/software/rpm/rpm_-qa | while read line
		do
 			$RPM -qi  $line > ${LOGDIR}/software/rpm/rpm-packages/${line}.out  2>&1

			if [ $? -ne 0 ] ; then
				echo "ERROR: ${line} problem"
			fi
		done


		# print a list os installed packages sorted by install time:
		$RPM -qa -last | tac > ${LOGDIR}/software/rpm/rpm_-qa_-last.out

		#############################################################
		# If you enable verification then this then it's going to
		# take a some time to complete........
		#############################################################

		if [ ${FULLSOFT} -gt 0 ] ; then
			 $RPM -Va > ${LOGDIR}/software/rpm/rpm-Va.out  2>&1
		fi
	fi

	if [ -f /usr/lib/rpm/rpmrc ] ; then
		$CP -p /usr/lib/rpm/rpmrc  ${LOGDIR}/software/rpm/rpmrc
	fi



	# Make a copy of the yum config files so that we can compare them
	YUMDIR=${LOGDIR}/software/yum

	if [ -d /etc/yum.repos.d ] ; then
		MakeDir $YUMDIR/yum.repos.d
		$CP /etc/yum.repos.d/* $YUMDIR/yum.repos.d/
	fi

	if [ -x "$YUM" ]  ; then
		$YUM list installed       > ${YUMDIR}/yum_list_installed.out        2>&1
		$YUM info installed       > ${YUMDIR}/yum_info_installed.out        2>&1
		$YUM -v repolist all      > ${YUMDIR}/yum_-v_repolist_all.out       2>&1
		$YUM repolist enabled     > ${YUMDIR}/yum_repolist_enabled.out      2>&1
		$YUM repolist disabled    > ${YUMDIR}/yum_repolist_disabled.out     2>&1
		$YUM -v repolist all      > ${YUMDIR}/yum_-v_repolist_all.out       2>&1
		$YUM -v repolist enabled  > ${YUMDIR}/yum_-v_repolist_enabled.out   2>&1
		$YUM -v repolist disabled > ${YUMDIR}/yum_-v_repolist_disabled.out  2>&1

	fi

}

##############################################################################
#
#      Function : pacman_info
#    Parameters :
#        Output :
#         Notes : Check all packages installed ( used by ArchLinux/OpenFiler )
#
##############################################################################

function pacman_info
{

	if [ -x "$PACMAN" ]  ; then

		Echo "Section - pacman Checks "
		MakeDir ${LOGDIR}/software/packman

		$PACMAN -qa   > ${LOGDIR}/software/packman/pacman_-qa  2>&1
		$PACMAN -Qi   > ${LOGDIR}/software/packman/pacman_-Qi  2>&1
		$PACMAN -Qdt  > ${LOGDIR}/software/packman/pacman_-Qdt 2>&1
	fi

}

##############################################################################
#
#      Function : systemd_info
#    Parameters :
#        Output :
#         Notes : Get information about SystemD
#
##############################################################################

function systemd_info
{

	if [ -x "$SYSTEMCTL" ]; then

		Echo "Section - Systemd Checks "
		MakeDir ${LOGDIR}/system/systemd

		# systemd checks
		$SYSTEMD  --dump-configuration-items > ${LOGDIR}/system/systemd/systemd_--dump-configuration-items.out 2>&1
		$SYSTEMD  --test                     > ${LOGDIR}/system/systemd/systemd_--test.out                     2>&1

		# systemd-cgls tree
		if [ -x "$SYSTEMDCGLS" ]; then
			$SYSTEMDCGLS  > ${LOGDIR}/system/systemd/systemd-cgls.out 2>&1
		fi

		if [ -x "$SYSTEMDLOGINCTL" ]; then
			$SYSTEMDLOGINCTL --all     > ${LOGDIR}/system/systemd/systemd-loginctl_--all.out     2>&1
			$SYSTEMDLOGINCTL show-seat > ${LOGDIR}/system/systemd/systemd-loginctl_show-seat.out 2>&1
			$SYSTEMDLOGINCTL show-user > ${LOGDIR}/system/systemd/systemd-loginctl_show_user.out 2>&1
		fi

		$SYSTEMCTL                  > ${LOGDIR}/system/systemd/systemctl.out                  2>&1
		$SYSTEMCTL --all            > ${LOGDIR}/system/systemd/systemctl_--all.out            2>&1
		$SYSTEMCTL show-environment > ${LOGDIR}/system/systemd/systemctl_show-environment.out 2>&1
		$SYSTEMCTL --version        > ${LOGDIR}/system/systemd/systemctl_--version.out        2>&1
		$SYSTEMCTL list-unit-files  > ${LOGDIR}/system/systemd/systemctl_list-unit-files.out  2>&1
		$SYSTEMCTL dump             > ${LOGDIR}/system/systemd/systemctl_dump.out             2>&1
		$SYSTEMCTL list-jobs        > ${LOGDIR}/system/systemd/systemctl_list-jobs.out        2>&1
		$SYSTEMCTL list-unit-files --type=service  > ${LOGDIR}/system/systemd/systemctl_list--unit-files_--type=service.out  2>&1

	fi

	if [ -d ${LOGDIR}/etc/systemd ]; then
		$LN -s ${LOGDIR}/etc/systemd ${LOGDIR}/system/systemd/etc-systemd 2>&1
	fi


}


##############################################################################
#
#      Function : deb_info
#    Parameters :
#        Output :
#         Notes : Collect information above Debian packages
#
##############################################################################

function deb_info
{


	if [ -f /var/lib/dpkg/available ] ; then

		Echo "Section - deb package information "

		MakeDir ${LOGDIR}/var/lib/dpkg

		if [ -d /etc/apt ] ; then
			MakeDir ${LOGDIR}/etc/apt
		fi

		if [ -f /etc/apt/sources.list ] ; then
			$CP -p /etc/apt/sources.list ${LOGDIR}/etc/apt/sources.list
		fi


		if [ -f /etc/apt/apt.conf ] ; then
			$CP -p /etc/apt/apt.conf ${LOGDIR}/etc/apt/apt.conf
		fi


		if [ -f /etc/apt/apt.conf ] ; then
			$CP -p /etc/apt/apt.conf ${LOGDIR}/etc/apt/apt.conf
		fi


		if [ -f /var/lib/dpkg/status ] ; then
			$CP -p /var/lib/dpkg/status ${LOGDIR}/var/lib/dpkg/status
		fi


		MakeDir ${LOGDIR}/software/dpkg

		if [ -x "$DPKG" ] ; then
			 $DPKG  --list			> ${LOGDIR}/software/dpkg/dpkg_--list.out
			 $DPKG  -al			> ${LOGDIR}/software/dpkg/dpkg_-al.out
			 $DPKG  --get-selections	> ${LOGDIR}/software/dpkg/dpkg_-get-selections.out
		fi

		if [ -x "$DPKG_QUERY" ] ; then
			 $DPKG_QUERY -W			> ${LOGDIR}/software/dpkg/dpkg-query_-W.out
		fi

		if [ -x /usr/bin/apt-config ] ; then
			/usr/bin/apt-config dump 	> ${LOGDIR}/software/dpkg/apt-config_dump.out
		fi

	fi
}


##############################################################################
#
#      Function : suse_zypper_info
#    Parameters :
#        Output :
#         Notes : Collect information above Suse packages
#
##############################################################################


function suse_zypper_info
{

	if [ -x "$ZYPPER" ] ; then

		Echo "Section - Suse Zypper Info "

		MakeDir ${LOGDIR}/software/zypper

		$ZYPPER repos 		> ${LOGDIR}/software/zypper/zypper_repos         2>&1
		$ZYPPER locks  		> ${LOGDIR}/software/zypper/zypper_locks         2>&1
		$ZYPPER patches  	> ${LOGDIR}/software/zypper/zypper_patches       2>&1
		$ZYPPER packages  	> ${LOGDIR}/software/zypper/zypper_packages      2>&1
		$ZYPPER patterns  	> ${LOGDIR}/software/zypper/zypper_patterns      2>&1
		$ZYPPER products  	> ${LOGDIR}/software/zypper/zypper_products      2>&1
		$ZYPPER services 	> ${LOGDIR}/software/zypper/zypper_services      2>&1
		$ZYPPER licenses 	> ${LOGDIR}/software/zypper/zypper_licenses      2>&1
		$ZYPPER targetos 	> ${LOGDIR}/software/zypper/zypper_targetos	  2>&1
		$ZYPPER list-updates  	> ${LOGDIR}/software/zypper/zypper_list-updates  2>&1
	fi
}



##############################################################################
#
#      Function : gentoo_pkgs_info
#    Parameters :
#        Output :
#         Notes : This Section is for Gentoo - so we can work out what
#	          packages are installed-  Provided by Adam Bills
#
##############################################################################

function gentoo_pkgs_info
{

	if [ -d  /var/db/pkg  ] ; then

		Echo "Section - Gentoo Packages Info "

		MakeDir ${LOGDIR}/software/gentoo

		GENTOPKGS=${LOGDIR}/software/gentoo/gento_kgs.out

		( find /var/db/pkg -type f -name environment.bz2 | while read x; do bzcat $x | \
			awk -F= '{
				if ($1 == "CATEGORY"){
					printf "%s ", $2;
				}
				if ($1 == "PN"){
					printf "%s ",$2;
				}

				if ($1 == "PV"){
					print $2;
				}
			}' ; done

		) >> $GENTOPKGS


        	if [ -x $EQUERY ] ; then
			$EQUERY list > ${LOGDIR}/software/gentoo/equery_list.out
		fi
	fi


	#  Show the bootup info
	if [ -x $RC_UPDATE ] ; then
		$RC_UPDATE show > ${LOGDIR}/software/gentoo/rc-update_show.out
	fi

}

##############################################################################
#
#      Function : spacewalk_info
#    Parameters :
#        Output :
#         Notes : See if we have spacewalk installed
#
##############################################################################

function spacewalk_info
{

	if [ -x $SPACERPT  ] ; then

		Echo "Section - Spacewalk "

		MakeDir ${LOGDIR}/satellite

		for info in users channels errata-list entitlements inventory users-systems errata-systems
		do
			$SPACERPT  $info  > ${LOGDIR}/satellite/${SPACERPT}_${info} 2>&1
		done
	fi
}


##############################################################################
#
#      Function : sysconfig_info
#    Parameters :
#        Output :
#         Notes : Collect all those little config files in /etc/sysconfig
#
##############################################################################


function sysconfig_info
{

	if [ -d /etc/sysconfig ] ; then

		Echo "Section - sysconfig "

		if [ ! -d ${LOGDIR}/etc/sysconfig ] ; then
			MakeDir ${LOGDIR}/etc/sysconfig
		fi

		$CP -p -R /etc/sysconfig/*	${LOGDIR}/etc/sysconfig
	fi
}

##############################################################################
#
#      Function : rhn_info
#    Parameters :
#        Output :
#         Notes : Collect Redhat Network Information
#
##############################################################################

function rhn_info
{
	if [ -d /etc/sysconfig/rhn ] ; then

		Echo "Section - RedHat Network "


		RDIR=${LOGDIR}/rhn
		MakeDir ${RDIR}

		if [ -d  /etc/rhn ] ; then

		    $CP -pR /etc/rhn/ ${LOGDIR}/etc/rhn/

		    if [ -f /etc/sysconfig/rhn/systemid ] ; then
			    if [ -x /usr/bin/xsltproc ] ; then
				    /usr/bin/xsltproc $UTILDIR/text.xsl $RDIR/systemid \
					    > $ROOT/$RHNDIR/systemid 2>&1
			    fi
		    fi
    		fi
	fi


	# if [ -x /usr/bin/rhn-schema-version ] ; then
	# 	/usr/bin/rhn-schema-version >$RDIR}/
	# fi

	# if [ -x /usr/bin/rhn-charsets ] ; then
	#  	/usr/bin/rhn-charsets
	# fi
}



##############################################################################
#
#      Function : system_logs_info
#    Parameters :
#        Output :
#         Notes : Take a copy of the latest logs
#
##############################################################################


function system_logs_info
{
	Echo "Section - Systems Log "

	$CP -R -p /var/log/*  ${LOGDIR}/logs

	$DMESG  > ${LOGDIR}/logs/dmesg.out
	$LAST   > ${LOGDIR}/logs/lastlog

	if [ -d /var/crash ] ; then
		for i in $( $FIND /var/crash -name "*.txt" )
		do
			dirname="$(dirname $i)"
			filename="$(basename $i)"

			if [ ! -d ${LOGDIR}/${dirname} ] ; then
				MakeDir ${LOGDIR}/${dirname}
			fi

			$CP -p $i ${LOGDIR}/${dirname}/${filename} 2>/dev/null

		done
	fi


	if [ -x $JOURNALCTL ] ; then
		$JOURNALCTL  --all --no-pager  > ${LOGDIR}/logs/journalctl_--all_--no-pager.out
	fi


}


##############################################################################
#
#      Function : selinux_info
#    Parameters :
#        Output :
#         Notes : selinux info
#
##############################################################################

function selinux_info
{
	Echo "Section - SElinux Section checks"

	SELINUXDIR=${LOGDIR}/selinux
	MakeDir ${SELINUXDIR}

	if [ -x $SESTATUS ] ; then
		$SESTATUS     > ${SELINUXDIR}/sestatus.out     2>&1
		$SESTATUS -bv > ${SELINUXDIR}/sestatus_-bv.out 2>&1
	fi

	if [ -x $SEMANAGE ] ; then
		$SEMANAGE port -l		> ${SELINUXDIR}/semanage_port_-l.out      2>&1
		$SEMANAGE login -l		> ${SELINUXDIR}/semanage_login_-l.out     2>&1
		$SEMANAGE user -l		> ${SELINUXDIR}/semanage_user_-l.out      2>&1
		$SEMANAGE node -l		> ${SELINUXDIR}/semanage_node_-l.out      2>&1
		$SEMANAGE interface -l		> ${SELINUXDIR}/semanage_interface_-l.out 2>&1
		$SEMANAGE boolean -l		> ${SELINUXDIR}/semanage_boolean_-l.out   2>&1
	fi


	if [ -x $GETSEBOOL ] ; then
		$GETSEBOOL -a  > ${LOGDIR}/selinux/getsebool_-a.out 2>&1
	else
		echo "getsebool not installed " >  ${LOGDIR}/selinux/getsebool_-a.out 2>&1
	fi
}


##############################################################################
#
#      Function : xen_info
#    Parameters :
#        Output :
#         Notes : XEN VM information
#
##############################################################################


function xen_info
{

	if [ -d /etc/xen ] ; then

		Echo "Section - xen Section checks"

		MakeDir ${VIRT}/xen

		XENETC=${LOGDIR}/xen

		if [ ! -d $XENETC ] ; then
			MakeDir $XENETC
		fi

		$CP -Rp /etc/xen/* ${XENETC}/
		MakeDir ${VIRT}/xen

		if [ -x $XM  ] ; then
			$XM list		> $VIRT/xen/xm_list.out		2>&1
			$XM info		> $VIRT/xen/xm_info.out		2>&1
			$XM logs		> $VIRT/xen/xm_log.out		2>&1
			$XM dmesg		> $VIRT/xen/xm_dmesg.out	2>&1
			$XM vcpu-list		> $VIRT/xen/xm_vcpu-list.out	2>&1

			for myHost in $($XM list  2>/dev/null | egrep -v "VCPUs |^Domain-0")
			do
				$XM network-list $myHost 	> $VIRT/xen/xm_network-list_${myHost}.out   2>&1
				$XM uptime $myHost		> $VIRT/xen/xm_uptime_${myHost}.out         2>&1
				$VIRSH dominfo $myHost   	> $VIRT/xen/virsh_dominfo_${myHost}.out     2>&1
			done

		fi
	fi
}

##############################################################################
#
#      Function : libvirt_info
#    Parameters :
#        Output :
#         Notes : Virt-manager type information
#
##############################################################################


function libvirt_info
{

	if [ -x $VIRSH ] ; then

		Echo "Section - libvirt Section "

		MakeDir ${VIRT}/libvirt
		MakeDir ${VIRT}/vm_configs

		$VIRSH  list --all     >   ${VIRT}/libvirt/virsh_list_--all.out 2>&1
		$VIRSH  net-list --all >   ${VIRT}/libvirt/virsh_net-list_--all.out 2>&1
		$VIRSH -c qemu:///system capabilities \
					> ${VIRT}/libvirt/virsh_-c_qemu:___system_capabilities.out 2>&1


		# Next Dump out all the running configs for each of the VMs

		List=$( $VIRSH list --all | egrep -v "State|^-" | awk '{print $2}' | sed '/^$/d')

		for i in $List
		do
			$VIRSH dumpxml $i > ${VIRT}/vm_configs/${i}.xml
		done

	fi
}


##############################################################################
#
#      Function : yp_info
#    Parameters :
#        Output :
#         Notes : Yellow Pages information - not used that much these days
#
##############################################################################


function yp_info
{

	if [ -x "$YPWHICH" ] ; then

		Echo "Section NIS/YP Services "
		YPDIR=${LOGDIR}/yp
		MakeDir ${YPDIR}

		$YPWHICH -m > ${YPDIR}/ypwhich-m.out 2>&1
	fi

	if [ -f /etc/domainname ] ; then
		$CP -p /etc/domainname ${LOGDIR}/etc/

		$LS -lR /var/yp/$(cat /etc/domainname) > ${YPDIR}/ls_-lR.out 2>&1
	fi
}




##############################################################################
#
#      Function : network_info
#    Parameters :
#        Output :
#         Notes : Collect lots of network information
#
##############################################################################


function network_info
{
	Echo "Section - Networking "

	for i in $($LS -d /etc/host* )
	do
		filename=$(basename $i)
		$CP -p  $i ${LOGDIR}/etc/${filename}
	done


	for i in $( $LS -d /etc/ftp* 2>/dev/null )
	do
		filename=$(basename $i)
		$CP -p $i ${LOGDIR}/etc/$filename
	done



	$CP -p /etc/services ${LOGDIR}/etc/services

	if [ -f /etc/HOSTNAME ] ; then
		$CP -p /etc/HOSTNAME ${LOGDIR}/etc/HOSTNAME
	fi

	if [ -f /etc/hostname ] ; then
		$CP -p /etc/hostname ${LOGDIR}/etc/hostname
	fi

	if [ -f /etc/networks ] ; then
		$CP -p /etc/networks ${LOGDIR}/etc/networks
	fi

	if [ -f /etc/hosts.allow ] ; then
		$CP -p /etc/hosts.allow ${LOGDIR}/etc/hosts.allow
	fi

	if [ -f /etc/hosts.deny ] ; then
		$CP -p /etc/hosts.deny ${LOGDIR}/etc/hosts.deny
	fi

	if [ -f /etc/hosts ] ; then
		$CP -p /etc/hosts ${LOGDIR}/etc/hosts
	fi

	if [ -f /etc/shells ] ; then
		$CP -p /etc/shells ${LOGDIR}/etc/shells
	fi

	if [ -f "${LOGDIR}/etc/resolv.conf" ]; then
		if [ ! -d ${LOGDIR}/network ] ; then
			MakeDir ${LOGDIR}/network
		fi
		$CP -p /etc/resolv.conf ${LOGDIR}/network/resolv.conf 2>&1
	fi

	if [ -f /etc/network/interfaces ] ; then

		if [ ! -d ${LOGDIR}/etc/network/interfaces ] ; then
			if [ ! -d ${LOGDIR}/etc/network ] ; then
				MakeDir ${LOGDIR}/etc/network
			fi
		 	MakeDir ${LOGDIR}/etc/network/interfaces
		fi

		$CP -p /etc/network/interfaces ${LOGDIR}/etc/network/interfaces

	fi



	MakeDir ${LOGDIR}/network

	$IFCONFIG  -a		> ${LOGDIR}/network/ifconfig_-a.out    2>&1
	$NETSTAT -rn		> ${LOGDIR}/network/netstat_-rn.out    2>&1
	$NETSTAT -lan		> ${LOGDIR}/network/netstat_-lan.out   2>&1
	$NETSTAT -lav		> ${LOGDIR}/network/netstat_-lav.out   2>&1
	$NETSTAT -tulpn		> ${LOGDIR}/network/netstat_-tulpn.out 2>&1
	$NETSTAT -ape		> ${LOGDIR}/network/netstat_-ape.out   2>&1
	$NETSTAT -uan		> ${LOGDIR}/network/netstat_-uan.out   2>&1
	$NETSTAT -s 		> ${LOGDIR}/network/netstat_-s.out     2>&1
	$NETSTAT -in 		> ${LOGDIR}/network/netstat_-in.out    2>&1
	$ROUTE  -nv		> ${LOGDIR}/network/route_-nv.out      2>&1
	$ARP  -a		> ${LOGDIR}/network/arp_-a.out         2>&1

	if [ -x "$IP" ] ; then
		$IP  add	> ${LOGDIR}/network/ip_add.out     2>&1
		$IP  route	> ${LOGDIR}/network/ip_route.out   2>&1
		$IP  link	> ${LOGDIR}/network/ip_link.out    2>&1
		$IP  rule	> ${LOGDIR}/network/ip_rule.out    2>&1
	fi

	if [ -x "$IWCONFIG" ] ; then
		$IWCONFIG	> ${LOGDIR}/network/iwconfig.out 2>&1
	fi

	if [ -x "${MIITOOL}" ] ; then
		 ${MIITOOL}	> ${LOGDIR}/network/mii-tool.out 2>&1
	fi

	if [ -x $BIOSDEVNAME ] ; then
		$BIOSDEVNAME -d > ${LOGDIR}/network/biosdevname_-d.out 2>&1
	fi


	#
	# Collect bridging information
	#
	if [ -x "${BRCTL}" ] ; then

	    $BRCTL show > ${LOGDIR}/network/brctl_show.out 2>&1

		for myBridge in $($BRCTL show | grep -v "STP enabled" |  grep ^[a-zA-Z] | awk '{ print $1}')
		do

			$BRCTL showmacs $myBridge > ${LOGDIR}/network/btctl_showmacs_${myBridge}.out 2>&1
			$BRCTL showstp  $myBridge > ${LOGDIR}/network/btctl_showstp_${myBridge}.out 2>&1
		done

	fi

}


##############################################################################
#
#      Function : iptables_info
#    Parameters :
#        Output :
#         Notes : Collect iptables information
#
##############################################################################

function iptables_info
{

	if [ -x "$IPTABLES" ] ; then

		Echo "Section - iptables check"

		$IPTABLES -L 		        > ${LOGDIR}/network/iptables-L.out
		$IPTABLES -t filter -nvL 	> ${LOGDIR}/network/iptables-t_filter-nvL.out
		$IPTABLES -t mangle -nvL 	> ${LOGDIR}/network/iptables-t_mangle-nvL.out
		$IPTABLES -t nat -nvL		> ${LOGDIR}/network/iptables_-t_nat_-nvL.out

	else
		echo "no iptables in kernel"   > ${LOGDIR}/network/iptables-NO-IP-TABLES
	fi
}



##############################################################################
#
#      Function : ipchains_info
#    Parameters :
#        Output :
#         Notes : ipchains not use much these days - replaced by iptables
#
##############################################################################


function ipchains_info
{

	if [ -x "$IPCHAINS" ] ; then
		Echo "Section - ipchains check"
		$IPCHAINS -L -n > ${LOGDIR}/network/ipchains_-L_-n.out
	fi
}


##############################################################################
#
#      Function : ethtool_info
#    Parameters :
#        Output :
#         Notes : More networking information
#
##############################################################################


function ethtool_info
{

	if [ -x "$ETHTOOL" ] ; then

		Echo "Section - ethtool checks"

		for version in 4 6
		do
			INTERFACES=$( cat /proc/net/dev | grep "[0-9]:" | awk -F: '{print $1 }' )

			for i in $INTERFACES
			do
				$ETHTOOL $i    >  ${LOGDIR}/network/ethtool_ipv${version}_${i}.out    2>&1
       		 		$ETHTOOL -i $i >> ${LOGDIR}/network/ethtool_ipv${version}_-i_${i}.out 2>&1
       		 		$ETHTOOL -S $i >> ${LOGDIR}/network/ethtool_ipv${version}_-S_${i}.out 2>&1
			done
		done
	fi
}


##############################################################################
#
#      Function : xinetd_info
#    Parameters :
#        Output :
#         Notes : collect inetd information
#
##############################################################################

function xinetd_info
{

	if [ -d /etc/xinet.d ] ; then

		Echo "Section - xinetd checks"

		XINETD=${LOGDIR}/etc/xinet.d

		MakeDir ${XINETD}

		for i in $($LS -d /etc/xinetd.d/* )
		do
			filename=$(basename $i)
			$CP -p $i  ${XINETD}/$filename
		done
	fi


	if [ -f /etc/xinetd.log ] ; then
		$CP -p /etc/xinetd.log ${LOGDIR}/etc/xinetd.log
	fi
}

##############################################################################
#
#      Function : dns_info
#    Parameters :
#        Output :
#         Notes : Some simple DNS information
#
##############################################################################



function dns_info
{
	Echo "Section - DNS checks"


	if [ -f /etc/named.boot ] ; then
		$CP -p  /etc/named.boot ${LOGDIR}/etc/named.boot
	fi


	DNSDIR=""
	# if [ -f "/etc/named.conf" ] ; then
	# 	DNSDIR=$($GREP -i directory /etc/named.conf | \
	# 		 $GREP -v ^# | \
	# 		 $GAWK '{ print $2 ;}' | \
	# 		 $SED s/\"//g|/bin/sed s/\;//g
	# 		)
	# fi


	if [ "${DNSDIR}" != "" ] ; then

		if [ ! -d ${LOGDIR}${DNSDIR} ] ; then
			MakeDir ${LOGDIR}${DNSDIR}
		fi

		cd ${DNSDIR}
		 $TAR cf - . 2>/dev/null | ( cd ${LOGDIR}${DNSDIR} ; tar xpf - ) > /dev/null 2>&1
	fi
}


##############################################################################
#
#      Function : ocfs2_cluster_info
#    Parameters :
#        Output :
#         Notes : Oracles OCFS2 cluster filesystems
#
##############################################################################

function ocfs2_cluster_info
{

	if [ -f /etc/ocfs2/cluster.conf ] ; then

		Echo "Section - ocfs2 cluster checks"

		MakeDir ${LOGDIR}/etc/ocfs2

		$CP -p /etc/ocfs2/cluster.conf    ${LOGDIR}/etc/ocfs2/cluster.conf
		MakeDir ${CLUSTERDIR}/ocfs2
		$CP -p /etc/ocfs2/cluster.conf    ${CLUSTERDIR}/ocfs2/cluster.conf
	fi

}


##############################################################################
#
#      Function : redhat_cluster_info
#    Parameters :
#        Output :
#         Notes : Collect information about Redhat Cluster
#
##############################################################################

function redhat_cluster_info
{

	if [ -x $CLUSTAT ] ; then

		Echo "Section - Redhat Cluster checks"

		MyClusterDir=${CLUSTERDIR}/redhat
		      MakeDir ${CLUSTERDIR}/redhat

		$CLUSTAT	> $MyClusterDir/clustat.out             2>&1
		$CLUSTAT -f	> $MyClusterDir/clustat_-f.out          2>&1
		$CLUSTAT -l	> $MyClusterDir/clustat_-l.out          2>&1
		$CLUSTAT -I	> $MyClusterDir/clustat_-I.out          2>&1
		$CLUSTAT -v	> $MyClusterDir/clustat_-v.out          2>&1
		$CLUSTAT -x	> $MyClusterDir/clustat_-x.out          2>&1

		$CLUSVCADM -v	> $MyClusterDir/clusvcadm_-x.out	2>&1
		$CLUSVCADM -S	> $MyClusterDir/clusvcadm_-S.out	2>&1

		#
		# List out Quorum devices and CMAN_TOOL
		#
		if [ -x $MKQDISK ] ; then
			$MKQDISK -L >>  $MyClusterDir/mkqdisk_-L.out	2>&1
		fi

		# added by Ruggero Ruggeri
		if [ -x $CMAN_TOOL ] ; then
			$CMAN_TOOL status >>  $MyClusterDir/cman_tool_status.out 2>&1
			$CMAN_TOOL nodes >>   $MyClusterDir/cman_tool_nodes.out  2>&1
		fi

		#
		# Copy the cluster config files over
		#
		if [ -f /etc/cluster.xml ] ; then
			$CP -p /etc/cluster.xml    ${LOGDIR}/etc/cluster.xml
			$CP -p /etc/cluster.xml    $MyClusterDir/cluster.xml
		fi

		if [ -d /etc/cluster ] ; then
			$CP -Rp /etc/cluster/*     $MyClusterDir/
		fi

	fi
}




##############################################################################
#
#      Function : veritas_cluster_info
#    Parameters :
#        Output :
#         Notes : Collect information about Veritas Cluster
#
##############################################################################


function veritas_cluster_info
{

	if [ -d /opt/VRTSvcs/bin ] ; then
		PATH=$PATH:/opt/VRTSvcs/bin
	fi

	if [ -f /etc/VRTSvcs/conf/config/main.cf ] ; then

		Echo "Section - Veritas Cluster Checks"

    		VCSDIR=${CLUSTERDIR}/veritas

		MakeDir ${VCSDIR}


		MakeDir  ${LOGDIR}/etc/VRTSvcs/conf/config
		$CP -p  /etc/VRTSvcs/conf/config/* ${LOGDIR}/etc/VRTSvcs/conf/config


		if [ -d /var/VRTSvcs/log ] ; then
			MakeDir  ${LOGDIR}/var/VRTSvcs/log
			$CP -p  /var/VRTSvcs/log/* ${LOGDIR}/var/VRTSvcs/log
    		fi


		$HASTATUS -sum       >   ${VCSDIR}/hastatus_-sum.out 2>&1
		$HARES -list         >   ${VCSDIR}/hares_-list.out   2>&1
		$HAGRP -list         >   ${VCSDIR}/hagrp_-list.out   2>&1
		$HATYPE -list        >   ${VCSDIR}/hatype_-list.out  2>&1
		$HAUSER -list        >   ${VCSDIR}/hauser_-list.out  2>&1
		$LLTSTAT -vvn        >   ${VCSDIR}/lltstat_-vvn.out  2>&1
		$GABCONFIG -a        >   ${VCSDIR}/gabconfig_-a.out  2>&1

		$HACF -verify /etc/VRTSvcs/conf/config/main.cf > ${VCSDIR}/hacf-verify.out 2>&1

		$CP -p  /etc/llthosts   ${LOGDIR}/etc
		$CP -p  /etc/llttab     ${LOGDIR}/etc
		$CP -p  /etc/gabtab     ${LOGDIR}/etc
	fi
}


##############################################################################
#
#      Function : pacemake_cluster_info
#    Parameters :
#        Output :
#         Notes : Pacemaker cluster information collection
#
##############################################################################

function pacemake_cluster_info
{


	if [ -x $CRM_MON ] ; then

		Echo "Section - CRM Cluster checks"

		CRMDIR=${CLUSTERDIR}/crm

		MakeDir ${CRMDIR}

		$CRM_MON --version > ${CRMDIR}/crm_mon_--version.out

		if [ -x $CRM ] ; then
			$CRM status 			> ${CRMDIR}/crm_status.out
			$CRM configure show 		> ${CRMDIR}/crm_configure_show.out
			$CRM configure show xml		> ${CRMDIR}/crm_configure_show_xml.out
			$CRM ra classes 		> ${CRMDIR}/crm_ra_classes.out
			$CRM ra list ocf heartbeat 	> ${CRMDIR}/crm_ra_list_ocf_heartbeat.out
			$CRM ra list ocf pacemaker 	> ${CRMDIR}/crm_ra_list_ocf_pacemaker.out
		fi


		if [ -x $CRM_VERIFY ] ; then
			$CRM_VERIFY -L 		> ${CRMDIR}/crm_verify_-L.out
		fi

		if [ -x $CIBADMIN ] ; then
			$CIBADMIN -Ql > ${CRMDIR}/cibadmin_-Ql.out
		fi
	fi
}

##############################################################################
#
#      Function : crontab_info
#    Parameters :
#        Output :
#         Notes : Collect crontab information
#
##############################################################################


function crontab_info
{
	Echo "Section - Crontab check"

	MakeDir ${LOGDIR}/etc/cron
	$CP -R -p /etc/cron*  ${LOGDIR}/etc


	if [ -d /var/spool/cron ] ; then
		MakeDir ${LOGDIR}/var/spool/cron
		cd /var/spool/cron
		$TAR cf - .  | ( cd ${LOGDIR}/var/spool/cron ; tar xpf - )
	fi
}


##############################################################################
#
#      Function : printing_info
#    Parameters :
#        Output :
#         Notes : Collectin information about print jobs and printers
#
##############################################################################


function printing_info
{
	Echo "Section - Printer Checks"

	PRINTDIR=${LOGDIR}/lp

	MakeDir ${PRINTDIR}
	MakeDir ${PRINTDIR}/general
	MakeDir ${LOGDIR}/etc/printcap

	if [ -x $LPSTAT ]  ; then
		$LPSTAT -t	> ${PRINTDIR}/lpstat_-t.out 2>&1
	fi

	if [ -x $LPC ]  ; then
		$LPC status	> ${PRINTDIR}/lpstat_status.out 2>&1
	fi

	if [ -f /etc/printcap ] ; then
		$CP /etc/printcap	  ${LOGDIR}/etc/printcap
	fi


	if [ -d /etc/cups ] ; then
		MakeDir ${LOGDIR}/etc/cups
		$CP -p  -R /etc/cups/*  ${LOGDIR}/etc/cups
	fi

	$LPQ > ${PRINTDIR}/general/lpq.out  2>&1


	if [ -x $LPQ_CUPS ] ; then
		$LPQ_CUPS	> ${PRINTDIR}/lpq.cups.out 2>&1
	fi
}


##############################################################################
#
#      Function : openldap_info
#    Parameters :
#        Output :
#         Notes : collect information about openldap
#
##############################################################################


function openldap_info
{

	if [ -d /etc/openldap ] ; then

		Echo "Section - Openldap Checks"

		MakeDir ${LOGDIR}/etc/openldap
		$CP -p -R /etc/openldap/*  ${LOGDIR}/etc/openldap
	fi
}


##############################################################################
#
#      Function : pam_info
#    Parameters :
#        Output :
#         Notes : collect information about pam
#
##############################################################################


function pam_info
{
	Echo "Section - Pam Checks"

	MakeDir ${LOGDIR}/etc/pam

	$CP -p -R /etc/pam.d/*  ${LOGDIR}/etc/pam/
}




##############################################################################
#
#      Function : sendmail_info
#    Parameters :
#        Output :
#         Notes : Collect information about sendmail
#
##############################################################################


function sendmail_info
{

	if [ -f /etc/sendmail.cf ] ; then

		Echo "Section - Sendmail "

		MakeDir ${LOGDIR}/etc/mail

		$CP -p /etc/sendmail.cf ${LOGDIR}/etc/sendmail.cf
	fi

	if [ -f /etc/sendmail.cw ] ; then
		$CP -p /etc/sendmail.cw ${LOGDIR}/etc/sendmail.cw
	fi


	if [  -d /etc/mail ] ; then
		for i in $($LS -d /etc/mail/* | $GREP -v \.db) ; do
			$CP -R -p $i ${LOGDIR}/etc/mail
		done
	fi

	if [ -f /etc/aliases ] ; then
		$CP -p /etc/aliases ${LOGDIR}/etc/aliases
	fi

	if [ -f /etc/mail/aliases ] ; then
		$CP -p /etc/mail/aliases ${LOGDIR}/etc/mail/aliases
	fi
}


##############################################################################
#
#      Function : postfix_info
#    Parameters :
#        Output :
#         Notes : Collect information about postfix
#
##############################################################################


function postfix_info
{

	if [ -d /etc/postfix ] ; then

		Echo "Section - Postfix "

		POSTDIR=${LOGDIR}/etc/postfix
		MakeDir $POSTDIR
		$CP -p -R /etc/postfix/*  ${POSTDIR}

		POSTTOPDIR=${LOGDIR}/mail/postfix
		MakeDir $POSTTOPDIR

		$POSTCONF -v		> ${POSTTOPDIR}/postconf_-v.out 2>&1
		$POSTCONF -l		> ${POSTTOPDIR}/postconf_-l.out 2>&1
	fi
}

##############################################################################
#
#      Function : exim_info
#    Parameters :
#        Output :
#         Notes : Collect information about exim
#
##############################################################################


function exim_info
{

	if [ -d /etc/exim ] ; then

		Echo "Section - Exim checks"

		EXIMDIR=${LOGDIR}/etc
		$CP -p -R /etc/exim  ${EXIMDIR}

		EXIMTOPDIR=${LOGDIR}/mail/exim
		MakeDir $EXIMTOPTDIR

		$EXIM -bV	> ${LOGDIR}/mail/exim/exim_-bV.out
		$EXIM -bp	> ${LOGDIR}/mail/exim/exim_-bp.out

	fi
}


##############################################################################
#
#      Function : dovecot_info
#    Parameters :
#        Output :
#         Notes : Collect information about dovecote
#
##############################################################################


function dovecot_info
{

	if [ -d /etc/dovecot ] ; then

		Echo "Section - Dovecot checks"

		EXIMDIR=${LOGDIR}/etc
		$CP -p -R /etc/dovecot  ${EXIMDIR}

		DOVETOPDIR=${LOGDIR}/mail/dovecot
		MakeDir $DOVETOPTDIR

		$DOVECOTE -a > ${LOGDIR}/mail/dovecot/dovecote_-a.out

	fi

}

##############################################################################
#
#      Function : time_info
#    Parameters :
#        Output :
#         Notes : General time information
#
##############################################################################

function time_info
{
	Echo "Section - NTP"

	TIMEDIR=${LOGDIR}/etc/time

	if [ ! -d ${TIMEDIR} ] ; then
		MakeDir ${TIMEDIR}
	fi

	$DATE 		> ${TIMEDIR}/date

	if [ -f /etc/timezone ] ; then
		$CP -p /etc/timezone  ${TIMEDIR}/timezone
	fi

	if [ -f /usr/share/zoneinfo ] ; then
		$CP -p /usr/share/zoneinfo  ${TIMEDIR}/zoneinfo
	fi

	if [ -f /etc/ntp.drift ] ; then
		$CP -p /etc/ntp.drift ${TIMEDIR}/ntp.drift
	fi

	if [ -x $HWCLOCK ] ; then
		$HWCLOCK --show > ${TIMEDIR}/hwclock_--show.out
	fi

	if [ -x $NTPQ  ] ; then
		$NTPQ -p > ${TIMEDIR}/ntpq_-p.out 2>&1
	fi

	if [ -f /etc/ntp/step-tickers ] ; then
		$CP -p /etc/ntp/step-tickers ${LOGDIR}/etc
	fi

	if [ -f /etc/ntp/ntpservers ] ; then
		$CP -p /etc/ntp/ntpservers   ${LOGDIR}/etc
	fi
}


##############################################################################
#
#      Function : ppp_info
#    Parameters :
#        Output :
#         Notes : Collect any PPP files
#
##############################################################################

function ppp_info
{

		PPPDIR=${LOGDIR}/etc/ppp
		MakeDir ${PPPDIR}

	if [ ! -d ${PPPDIR} ] ; then

		Echo "Section - PPP"

		MakeDir ${PPPDIR}/peers
	fi

	if [ -d /etc/ppp ] ; then
		$CP -R -p /etc/ppp/* 		${PPPDIR} 2>&1
	fi

	if [ -d /etc/wvdial ] ; then
		$CP -p /etc/ppp/options.* 	${PPPDIR} > /dev/null 2>&1
		$CP -p -R /etc/ppp/peers/* 	${PPPDIR}/peers
	fi

	##############################################################################
	# This section is for removing any information
	# about hardcoded passwords inserted in files.
	##############################################################################

	if [ -f /etc/wvdial.conf ] ; then
		$CAT /etc/wvdial.conf | sed -e /^Password/d  > ${LOGDIR}/etc/wvdial.conf
	fi

}

##############################################################################
#
#      Function : asterisk_info
#    Parameters :
#        Output :
#         Notes : Collect Asterisk info
#
##############################################################################


function asterisk_info
{
	ASTRDIR=${LOGDIR}/asterisk_info

	MakeDir ${ASTRDIR}
	$ASTCMD -V > $ASTDIR/version
	$ASTCMD -rx "sip show peers" > $ASTDIR/sippeers
	$ASTCMD -rx "sip show settings" > $ASTDIR/sipsettings
	$ASTCMD -rx "sip show registry" > $ASTDIR/sipregistry
	$ASTCMD -rx "dahdi show channels" > $ASTDIR/dahdi_channels
	$ASTCMD -rx "dahdi show status" > $ASTDIR/dahdi_status
	$ASTCMD -rx "pri show spans" > $ASTDIR/pri
	$ASTCMD -rx "database show" > $ASTDIR/astdb
	$ASTCMD -rx "config list" > $ASTDIR/configs
	$ASTCMD -rx "core show hints" > $ASTDIR/hints
	$ASTCMD -rx "core show channeltypes" > $ASTDIR/channeltypes
	$ASTCMD -rx "core show uptime" > $ASTDIR/uptime
	$ASTCMD -rx "core show sysinfo" > $ASTDIR/sysinfo
	$ASTCMD -rx "obdc show all" > $ASTDIR/obdc

}


##############################################################################
#
#      Function : apache_info
#    Parameters :
#        Output :
#         Notes : Collect any Apache Files
#
##############################################################################


function apache_info
{


	if [ -d /etc/httpd ] ; then
		APACHEDIR=${LOGDIR}/httpd
	else
		APACHEDIR=${LOGDIR}/apache
	fi

	if [ ! -d $APACHEDIR ] ; then

		Echo "Section - Apache"

		MakeDir ${APACHEDIR}
	fi


	if [ -x $APACHECTL ] ; then
		$APACHECTL status  > ${APACHEDIR}/apachectl_status.out 2>&1
	fi

	if [ -x $APACHE2CTL ] ; then
		$APACHE2CTL status > ${APACHEDIR}/apache2ctl_status.out 2>&1
	fi
}



##############################################################################
#
#      Function : samba_info
#    Parameters :
#        Output :
#         Notes : Collect some SAMBA information ( needs updating for Samba4)
#
##############################################################################

function samba_info
{
	Echo "Section - Samba"

	SAMBADIR=${LOGDIR}/hardware/disks/samba

	if [ ! -d ${SAMBADIR} ] ; then
		MakeDir ${SAMBADIR}
	fi

	if [ -x $TESTPARM  ] ; then
		echo "y" | $TESTPARM > ${SAMBADIR}/testparm.out 2>&1
	fi

	if [ -x $WBINFO ] ; then
		$WBINFO -g  > ${SAMBADIR}/wbinfo_-g.out 2>&1
    		$WBINFO -u  > ${SAMBADIR}/wbinfo_-g.out 2>&1
	fi

	if [ -x $PDBEDIT  ] ; then
		$PDBEDIT -L ${SAMBADIR}/pdbedit_-L.out 2>&1
	fi

}

##############################################################################
#
#      Function : ssh_info
#    Parameters :
#        Output :
#         Notes : Collect information about ssh
#
##############################################################################


function ssh_info
{
	Echo "Section - ssh Checks"


	SSHDIR=${LOGDIR}/etc/ssh

	MakeDir ${SSHDIR}


	if [ -f /etc/nologin ] ; then
		$CP -p /etc/nologin ${LOGDIR}/etc/nologin
	fi

	if [ -d /etc/ssh/ssh_config ] ; then
		$CP -p /etc/ssh/ssh_config ${SSHDIR}/ssh_config
	fi

	if [ -d /etc/ssh/sshd_config ] ; then
		$CP -p /etc/ssh/sshd_config ${SSHDIR}/sshd_config
	fi
}


##############################################################################
#
#      Function : x11_info
#    Parameters :
#        Output :
#         Notes : X11
#
##############################################################################


function x11_info
{
	Echo "Section - X11"
	XDIR=${LOGDIR}/X

	MakeDir $XDIR

	if [ -d /etc/X11 ] ; then
		$CP -R -p /etc/X11 	${LOGDIR}/etc
	fi


	if [ -x $SYSP ] ; then
		$SYSP -c		> ${XDIR}/sysp_-c.out
		$SYSP -s mouse		> ${XDIR}/sysp_-s_mouse.out
		$SYSP -s keyboard 	> ${XDIR}/sysp_-s_keyboard.out
	fi

	if [ -x $_3DDIAG ] ; then
		$_3DDIAG 	> ${XDIR}/3Ddiag.out
	fi
}



##############################################################################
#
#      Function : taritup_info
#    Parameters :
#        Output :
#         Notes : tar up all the files that are going to be sent to support
#
##############################################################################


function taritup_info
{
	cd $LOGDIR

	$TAR czf ${TARFILE} . > /dev/null 2>&1

	if [ -t 0 ] ; then

		Sum=$($MD5SUM ${TARFILE} | $AWK '{print $1}' )

		echo
		echo "A support file has been created for support purposes"
		echo
		echo
		echo "The MD5sum is       : $Sum"
		echo "The Support File is : ${TARFILE}"
		echo
		echo "Please send this file and the MD5sum details to your support representative. "
		echo
	fi
}

##############################################################################
#
#      Function : RemoveDir
#    Parameters : None
#        Output : None
#         Notes : Remove directories
#
##############################################################################

function RemoveDir
{

	local myDIR=$1

	if [ -d "$myDIR" ] ; then
    		if [[ "${myDIR}" != "/" && \
			"${myDIR}" != "/var" && \
			"${myDIR}" != "/usr"  && \
			"${myDIR}" != "/home" ]] ; then

			if [ ${VERBOSE} -gt 0 ] ; then
        			Echo "Removing Old Directory : ${myDIR}"
			fi

			$RM -rf ${myDIR}
   		fi
	fi

}

##############################################################################
#
#      Function : System_Info
#    Parameters : None
#        Output : None
#         Notes : Print out brief information about the system
#
##############################################################################

function System_Info
{

if [ ! -t 0 ] ; then
	return
fi


if [ -f $EXPLCFG ] ; then

	Echo "Section - Found $EXPLCFG file"

	# Customer Contact Name
	NAME=$(grep ^EXP_USER_NAME $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )

	# Customer Name
	COMPANY=$(grep ^EXP_CUSTOMER_NAME $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )

	# Customer Contact Phone Number
	TELEPHONE=$(grep ^EXP_PHONE $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )

	# Customer Contact Email
	EMAIL=$(grep ^EXP_USER_EMAIL $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )

	# Customer Contact City
	TICKET_ID=$(grep ^EXP_TICKET_ID $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )

	# Where LINUXexplo output should be mailed
	SUPPORT=$(grep ^EXP_EMAIL $EXPLCFG | cut -f2 -d'=' | sed s'/\"//g' )
else

	echo
	echo "$MYNAME - $MYVERSION"
	echo
	echo "This program will gather system information and can take several"
	echo "minutes to finish."
	echo
	echo "You must complete some questions before start."
	echo "It will produce a .tgz or .tgz.gpg file output and a directory"
	echo "on your /opt/LINUXexplo/linux/ directory".
	echo
	echo "Please follow the support instruction for submit this information"
	echo
	echo "**********************************************************************"
	echo "Personal information"
	echo "**********************************************************************"
	read -p "Company    : " COMPANY
	read -p "Your name  : " NAME
	read -p "Email      : " EMAIL
	read -p "Telephone  : " TELEPHONE
	read -p "TicketID   : " TICKET_ID
	echo
	echo "**********************************************************************"
	echo "System information"
	echo "**********************************************************************"
	read -p "Problem description                        : " PROBLEM
	read -p "System description                         : " SYSTEM
	read -p "Environment (test/dev/prod)                : " ENVIRONMENT
	echo
	read -p "Are you sure to continue? (Y/n)            : " REPLY

	if [[ "$REPLY"  = [Yy] ]]; then
		Echo "Starting support gathering process."
	else
		Echo "Aborting."
		exit 0
	fi

fi


systemPlataform=$($UNAME -m)
kernelVersion=$($UNAME -r)
Mem=$(cat /proc/meminfo | grep ^MemTotal: | awk '{print $2}')
MEMINFO=$(echo $(($Mem / 1000000)))

if [ -x $LSB_RELEASE ] ; then
	LSB_RELEASE_INFO=$(${LSB_RELEASE} -a )
else
	LSB_RELEASE_INFO="Could not find LSB_RELEASE info"
fi



/bin/cat <<- EOF > /tmp/README
-----------------------------------------------------------------------------
$MYNAME - $MYVERSION
-----------------------------------------------------------------------------
This directory contains system configuration information.
Information was gathered on $MYDATE

Contact support made by: $NAME from $COMPANY
-----------------------------------------------------------------------------
CONTACT INFORMATION
-----------------------------------------------------------------------------

Company            : $COMPANY
Name               : $NAME
Email              : $EMAIL
Telephone          : $TELEPHONE
Ticket ID          : $TICKET_ID

----------------------------------------------------------------------------
SYSTEM INFORMATION
----------------------------------------------------------------------------

Date               : $MYDATE
Command Line       : $0 $@
Hostname           : $MYHOSTNAME
Host Id            : ${HOSTID}
System type        : $SERVER
System platform    : $systemPlatform
Kernel Version     : $kernelVersion
Server Memory      : ${MEMINFO}GB
Environment        : $ENVIRONMENT
System description : $SYSTEM
Problem description: $PROBLEM

----------------------------------------------------------------------------

$LSB_RELEASE_INFO

----------------------------------------------------------------------------

Uptime:
$(${UPTIME})

swapon -s:
$($SWAPON -s | $GREP -v "Filename")

vmstat:
$($VMSTAT 2 5 | $SED '1d' | $COLUMN -t  2> /dev/null )

df:
$($DF -h )

Network:
$($IFCONFIG -a )

----------------------------------------------------------------------------
EOF

# Create support information so we don't have to ask the customer each time.
if [ ! -f  $EXPLCFG ] ; then

	cat <<- EOF  > $EXPLCFG

		# Customer Contact Name
		EXP_USER_NAME="$NAME"

		# Customer Name
		EXP_CUSTOMER_NAME="$COMPANY"

		# Customer Contact Phone Number
		EXP_PHONE="$TELEPHONE"

		# Customer Contact Email
		EXP_USER_EMAIL="$EMAIL"

		EXP_EMAIL="$SUPPORT"

		# Default list of modules to run
		EXP_WHICH="all"
	EOF

fi


}


##############################################################################
#
#      Function : Installation_details
#    Parameters : None
#        Output : None
#         Notes : Collection information about installation
#
##############################################################################

function installation_details
{
	Echo "Section - Installation info"

	if [ -f "/root/anaconda-ks.cfg" ]; then
  		MakeDir "${LOGDIR}/system/Installation"
  		$CP -p "/root/anaconda-ks.cfg" ${LOGDIR}/system/Installation/anaconda-ks.cfg
	fi

}


##############################################################################
#                               MAIN
##############################################################################



#
# Ensure that we are the root user
#
if [ ${UID} -ne 0 ] ; then
   	echo
	echo "ERROR: Sorry only the root user can run this script"
	echo
	exit 1
fi




# Remove any temporary files we create
trap '$RM -f $TMPFILE >/dev/null 2>&1; exit' 0 1 2 3 15


##############################################################################
#                   Check the command line options
##############################################################################

while getopts ":d:k:t:vhV" OPT
do
	case "$OPT" in
		d)	if [ $OPTARG = "/" ] ; then
				echo "ERROR: root directory selected as target! "
				echo "Exiting."
				exit 1
			elif [ $OPTARG != "" ] ; then
				TOPDIR=${OPTARG%%/}
       	         	fi
			;;

		k)  KEEPFILES="1"
			;;

		t) 	CHECKTYPE="$OPTARG"
			# echo "DEBUG: checktype : $CHECKTYPE"
			;;

		v)  VERBOSE="1"
			;;
		D)  DEBUG="1"
			;;

		s)  FULLSOFT="1"
			;;

		h)  ShowUsage
			;;

		V)  echo
	  	    echo "LINUXexplo Version : $MYVERSION"
		    echo
		    exit 0
		    ;;
	esac
done


if [ ${VERBOSE} -gt 0 ] ; then

	if [ -t 0 ] ; then
		tput clear
	fi
fi




   LOGTOP="${TOPDIR}/linux"
   LOGDIR="${LOGTOP}/explorer.${HOSTID}.${MYSHORTNAME}-${MYDATE}"
  TARFILE="${LOGDIR}.tar.gz"
NOTFNDLOG="${LOGDIR}/command_not_found.out"
CLUSTERDIR=${LOGDIR}/clusters




if [ ! -d $LOGDIR ] ; then
	/bin/mkdir  -p $LOGDIR
fi

# find ALL my commands for this script
findCmds

System_Info

Echo "Creating Explorer Directory : $LOGDIR"

RemoveDir ${LOGTOP}

# echo "LOGDIR : \"${TOPDIR}/linux/${MYHOSTNAME}-${DATE}/output\" "

#  make sure this is a linux system

if [ "$($UNAME -s)" != "Linux" ] ; then
	echo "ERROR: This script is only for Linux systems "
	exit 1
fi


# Make the directory I'm going to store all the files

if [ ! -d $LOGDIR ] ; then
	MakeDir $LOGDIR

fi


if [ -f /tmp/README ] ; then
	mv /tmp/README ${LOGDIR}/README
fi

echo "$MYVERSION" > ${LOGDIR}/rev

myselection "$CHECKTYPE"

taritup_info

# Remove all the files tared up in $LOGDIR ( except tar file )

if [ $KEEPFILES -eq 1 ] ; then
        RemoveDir ${LOGDIR}
fi

##############################################################################
#		            That's ALL Folks !!!
##############################################################################
