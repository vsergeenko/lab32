#!/bin/sh
# hwclock.sh	Set and adjust the CMOS clock, according to the UTC
#		setting in /etc/default/rcS (see also rcS(5)).
#
# Version:	@(#)hwclock.sh  2.00  14-Dec-1998  miquels@cistron.nl
#
# Patches:
#		2000-01-30 Henrique M. Holschuh <hmh@rcm.org.br>
#		 - Minor cosmetic changes in an attempt to help new
#		   users notice something IS changing their clocks
#		   during startup/shutdown.
#		 - Added comments to alert users of hwclock issues
#		   and discourage tampering without proper doc reading.

# WARNING:	Please read /usr/share/doc/util-linux/README.Debian.hwclock
#		before changing this file. You risk serious clock
#		misbehaviour otherwise.

FIRST=no	# debian/rules sets this to 'yes' when creating hwclockfirst.sh

# Set this to any options you might need to give to hwclock, such
# as machine hardware clock type for Alphas.
HWCLOCKPARS=

[ ! -x /sbin/hwclock ] && exit 0
. /etc/default/rcS

. /lib/lsb/init-functions
verbose_log_action_msg() { [ "$VERBOSE" = no ] || log_action_msg "$@"; }

[ "$GMT" = "-u" ] && UTC="yes"
case "$UTC" in
       no|"")	GMT="--localtime"
		UTC=""
		if [ "X$FIRST" = "Xyes" ] && [ ! -r /etc/localtime ]; then
		    if [ -z "$TZ" ]; then
			log_action_msg "System clock was not updated at this time"
			exit 1
		    fi
		fi
		;;
       yes)	GMT="--utc"
		UTC="--utc"
		;;
       *)	log_action_msg "Unknown UTC setting: \"$UTC\""; exit 1 ;;
esac

case "$BADYEAR" in
       no|"")	BADYEAR="" ;;
       yes)	BADYEAR="--badyear" ;;
       *)	log_action_msg "unknown BADYEAR setting: \"$BADYEAR\""; exit 1 ;;
esac

case "$1" in
	start)
		if [ ! -f /etc/adjtime ] && [ ! -e /etc/adjtime ]; then
		    echo "0.0 0 0.0" > /etc/adjtime
		fi

		if [ "$FIRST" != yes ]; then
		    # Uncomment the hwclock --adjust line below if you want
		    # hwclock to try to correct systematic drift errors in the
		    # Hardware Clock.
		    #
		    # WARNING: If you uncomment this option, you must either make
		    # sure *nothing* changes the Hardware Clock other than
		    # hwclock --systohc, or you must delete /etc/adjtime
		    # every time someone else modifies the Hardware Clock.
		    #
		    # Common "vilains" are: ntp, MS Windows, the BIOS Setup
		    # program.
		    #
		    # WARNING: You must remember to invalidate (delete)
		    # /etc/adjtime if you ever need to set the system clock
		    # to a very different value and hwclock --adjust is being
		    # used.
		    #
		    # Please read /usr/share/doc/util-linux/README.Debian.hwclock
		    # before enablig hwclock --adjust.

		    #hwclock --adjust $GMT $BADYEAR
		    :
		fi

		if [ "$HWCLOCKACCESS" != no ]; then
		    log_daemon_msg "Setting the system clock"

		    # Copies Hardware Clock time to System Clock using the correct
		    # timezone for hardware clocks in local time, and sets kernel
		    # timezone. DO NOT REMOVE.
		    /sbin/hwclock --hctosys $GMT $HWCLOCKPARS $BADYEAR

		    if [ "$FIRST" = yes ]; then
			# Copies Hardware Clock time to System Clock using the correct
			# timezone for hardware clocks in local time, and sets kernel
			# timezone. DO NOT REMOVE.
			if [ -z "$TZ" ]; then
			   /sbin/hwclock --noadjfile --hctosys $GMT $HWCLOCKPARS $BADYEAR
			else
			   TZ="$TZ" /sbin/hwclock --noadjfile --hctosys $GMT $HWCLOCKPARS $BADYEAR
			fi

			if /sbin/hwclock --show $GMT $HWCLOCKPARS $BADYEAR 2>&1 > /dev/null |
			    grep -q '^The Hardware Clock registers contain values that are either invalid'; then
				echo "Invalid system date -- setting to 1/1/2002"
				/sbin/hwclock --set --date '1/1/2002 00:00:00' $GMT $HWCLOCKPARS $BADYEAR
			fi
		    fi

		    #	Announce the local time.
		    verbose_log_action_msg "System Clock set. Local time: `date $UTC`"
		else
		    verbose_log_action_msg "Not setting System Clock"
		fi
		log_end_msg 0
		;;
	stop|restart|reload|force-reload)
		#
		# Updates the Hardware Clock with the System Clock time.
		# This will *override* any changes made to the Hardware Clock.
		#
		# WARNING: If you disable this, any changes to the system
		#          clock will not be carried across reboots.
		#
		if [ "$HWCLOCKACCESS" != no ]; then
		    log_daemon_msg "Saving the system clock"
		    if [ "$GMT" = "-u" ]; then
			GMT="--utc"
		    fi
		    /sbin/hwclock --systohc $GMT $HWCLOCKPARS $BADYEAR
		    verbose_log_action_msg "Hardware Clock updated to `date`"
		else
		    verbose_log_action_msg "Not saving System Clock"
		fi
		log_end_msg 0
		;;
	show)
		if [ "$HWCLOCKACCESS" != no ]; then
			/sbin/hwclock --show $GMT $HWCLOCKPARS $BADYEAR
		fi
		;;
	*)
		log_success_msg "Usage: hwclock.sh {start|stop|reload|force-reload|show}"
		log_success_msg "       start sets kernel (system) clock from hardware (RTC) clock"
		log_success_msg "       stop and reload set hardware (RTC) clock from kernel (system) clock"
		exit 1
		;;
esac
