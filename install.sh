#!/bin/sh
set -e
# This script was taken from docker and modified to work for lochnas. 
# See original apache 2.0 license here https://github.com/docker/docker-install/blob/master/LICENSE
# 
# Lochnas for Linux installation script
#
# This script is meant for quick & easy install via:
#   $ curl -fsSL https://raw.githubusercontent.com/SiloCityLabs/lochnas/v3/install.sh -o install.sh && sh install.sh
#
#
# NOTE: Make sure to verify the contents of the script
#       you downloaded matches the contents of install.sh
#       located at https://raw.githubusercontent.com/SiloCityLabs/lochnas/v3/install.sh
#       before executing.

DOWNLOAD_URL="https://github.com/SiloCityLabs/lochnas.git"

command_exists() {
	command -v "$@" > /dev/null 2>&1
}

is_wsl() {
	case "$(uname -r)" in
	*microsoft* ) true ;; # WSL 2
	*Microsoft* ) true ;; # WSL 1
	* ) false;;
	esac
}

deprecation_notice() {
	distro=$1
	distro_version=$2
	echo
	printf "\033[91;1mDEPRECATION WARNING\033[0m\n"
	printf "    This Linux distribution (\033[1m%s %s\033[0m) reached end-of-life and is no longer supported by this script.\n" "$distro" "$distro_version"
	echo   "    No updates or security fixes will be released for this distribution, and users are recommended"
	echo   "    to upgrade to a currently maintained version of $distro."
	echo
	printf   "Press \033[1mCtrl+C\033[0m now to abort this script, or wait for the installation to continue."
	echo
	sleep 10
}

get_distribution() {
	lsb_dist=""
	# Every system that we officially support has /etc/os-release
	if [ -r /etc/os-release ]; then
		lsb_dist="$(. /etc/os-release && echo "$ID")"
	fi
	# Returning an empty string here should be alright since the
	# case statements don't act unless you provide an actual value
	echo "$lsb_dist"
}

# Check if this is a forked Linux distro
check_forked() {

	# Check for lsb_release command existence, it usually exists in forked distros
	if command_exists lsb_release; then
		# Check if the `-u` option is supported
		set +e
		lsb_release -a -u > /dev/null 2>&1
		lsb_release_exit_code=$?
		set -e

		# Check if the command has exited successfully, it means we're in a forked distro
		if [ "$lsb_release_exit_code" = "0" ]; then
			# Print info about current distro
			cat <<-EOF
			You're using '$lsb_dist' version '$dist_version'.
			EOF

			# Get the upstream release info
			lsb_dist=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'id' | cut -d ':' -f 2 | tr -d '[:space:]')
			dist_version=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'codename' | cut -d ':' -f 2 | tr -d '[:space:]')

			# Print info about upstream distro
			cat <<-EOF
			Upstream release is '$lsb_dist' version '$dist_version'.
			EOF
		else
			if [ -r /etc/debian_version ] && [ "$lsb_dist" != "ubuntu" ] && [ "$lsb_dist" != "raspbian" ]; then
				if [ "$lsb_dist" = "osmc" ]; then
					# OSMC runs Raspbian
					lsb_dist=raspbian
				else
					# We're Debian and don't even know it!
					lsb_dist=debian
				fi
				dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
				case "$dist_version" in
					11)
						dist_version="bullseye"
					;;
					10)
						dist_version="buster"
					;;
					9)
						dist_version="stretch"
					;;
					8)
						dist_version="jessie"
					;;
				esac
			fi
		fi
	fi
}

do_install() {
	echo "# Executing lochnas install script"

    if test -f "/lochnas/server.bin"; then
		cat >&2 <<-'EOF'
			Warning: the "lochnas" setup appears to already exist on this system.

			If you already have LochNAS installed, this script can cause trouble, which is
			why we're displaying this warning and provide the opportunity to cancel the
			installation.

			You may press Ctrl+C now to abort this script.
		EOF
		( set -x; sleep 20 )
	fi

	user="$(id -un 2>/dev/null || true)"

	sh_c='sh -c'
	if [ "$user" != 'root' ]; then
		if command_exists sudo; then
			sh_c='sudo -E sh -c'
		elif command_exists su; then
			sh_c='su -c'
		else
			cat >&2 <<-'EOF'
			Error: this installer needs the ability to run commands as root.
			We are unable to find either "sudo" or "su" available to make this happen.
			EOF
			exit 1
		fi
	fi

	# perform some very rudimentary platform detection
	lsb_dist=$( get_distribution )
	lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

	if is_wsl; then
		echo
		echo "WSL DETECTED: This script is not intended for use on Windows."
		echo
		exit 1
	fi

	case "$lsb_dist" in

		ubuntu)
			if command_exists lsb_release; then
				dist_version="$(lsb_release --codename | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
				dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
			fi
		;;

		debian|raspbian)
			dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
			case "$dist_version" in
				11)
					dist_version="bullseye"
				;;
				10)
					dist_version="buster"
				;;
				9)
					dist_version="stretch"
				;;
				8)
					dist_version="jessie"
				;;
			esac
		;;

		centos|rhel|sles)
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

		*)
			if command_exists lsb_release; then
				dist_version="$(lsb_release --release | cut -f2)"
			fi
			if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
				dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
			fi
		;;

	esac

	# Check if this is a forked Linux distro
	check_forked

	# Print deprecation warnings for distro versions that recently reached EOL,
	# but may still be commonly used (especially LTS versions).
	case "$lsb_dist.$dist_version" in
		debian.stretch|debian.jessie)
			deprecation_notice "$lsb_dist" "$dist_version"
			;;
		raspbian.stretch|raspbian.jessie)
			deprecation_notice "$lsb_dist" "$dist_version"
			;;
		ubuntu.xenial|ubuntu.trusty)
			deprecation_notice "$lsb_dist" "$dist_version"
			;;
	esac

	# Run setup for each distro accordingly
	case "$lsb_dist" in
		ubuntu|debian|raspbian)

            # We need git for lochnas setup
            if ! command_exists git; then
                $sh_c 'apt-get update -qq >/dev/null'
                $sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq git >/dev/null"
            fi

            # Let docker do its own checks and just run it
            if ! command_exists docker; then
                $sh_c "curl -fsSL https://get.docker.com/ -o get-docker.sh"
                $sh_c "sh get-docker.sh"
                $sh_c "rm -f get-docker.sh"
            fi
            if ! command_exists docker-compose; then 
                $sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-compose >/dev/null"
            fi

            # Pull down LochNAS
            $sh_c "git clone $DOWNLOAD_URL /lochnas"
            $sh_c "cp /lochnas/config.example.yml /lochnas/config.yml"

			# Ask user for domain
			echo -n "Enter root domain name to use for lochnas: " 
			read domain
			# Ask user for email
			echo -n "Enter email for ssl registration: " 
			read email

			# Replace domain and email in config.yml
			sed -i "s/GLOBAL_DOMAIN=domain.com/GLOBAL_DOMAIN=$domain/" /lochnas/config.yml
			sed -i "s/GLOBAL_EMAIL=email@domain.com/GLOBAL_EMAIL=$email/" /lochnas/config.yml

			cd /lochnas
            $sh_c "./server.bin -daemon install"

			echo "Edit `/lochnas/config.yml` then restart lochnas daemon with `service lochnas restart`"

			exit 0
			;;
		*)
			echo
			echo "ERROR: Unsupported distribution '$lsb_dist'"
			echo
			exit 1
			;;
	esac
	exit 1
}

# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"
do_install
