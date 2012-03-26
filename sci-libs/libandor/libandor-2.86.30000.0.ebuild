# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

EAPI='2'

DESCRIPTION="SDK library for scientific digital CCD, ICCD, EMCCD and sCMOS cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/download/download_file/?file=andor-${PV}.tar.gz -> andor-${PV}.tar.gz"
CONTACT_URL="http://www.andor.com/contact_us/"

LICENSE="Andor-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="modules"

RESTRICT="fetch"

DEPEND=""
RDEPEND=">=dev-libs/libusb-0.1.12-r5"

ANDOR_HOME=/opt/andor
LIB=""
SDKLIB=""

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${SRC_URI}"
	einfo "untar V${PV}.tar.gz and place andor-${PV}.tar.gz"
    einfo "in ${DISTDIR}"
	echo
	einfo "You must register on the Andor website and be personally granted "
	einfo "access by Andor to download and use their software."
	einfo "To get access, please contact the Andor Product Support division"
	einfo "${CONTACT_URL}"
}

pkg_setup() {
	if use modules; then
		linux-mod_pkg_setup
		if \
			kernel_is ge 2 6 24 && kernel_is lt 2 6 27; then
			eerror "Andor PCI kernel module is incompatibile with verions between "
			eerror "2.6.24 and 2.6.27"
			die "Kernel not compatible"
		fi
		elog "Upgrade to a newer kernel if the build fails"
	elif kernel_is le 2 4; then
		eerror "2.4 kernels do not fully support USB.  Rebuild with modules USE flag "
		eerror "for running PCI cameras only, or upgrade your kernel for USB support."
	fi
	
	if kernel_is lt 2 6 10; then
		ewarn "Kernels less < 2.6.10 may not support the interrupt polling rate "
		ewarn "requirement of Andor USB cameras.  You may see error code "
		ewarn "DRV_USB_INTERRUPT_ENDPOINT_ERROR"
	fi

	if use x86; then
		/sbin/ldconfig -p 2>&1 | grep libstdc++.so.6 1>/dev/null
		lib6=`echo $?`
		if [ $lib6 = 0 ]; then
			SDKLIB=libandor-stdc++6-i386.so.${PV}
		else
			SDKLIB=libandor-stdc++5-i386.so.${PV}
		fi
		LIB=lib
	elif use amd64; then
		SDKLIB=libandor-stdc++6-x86_64.so.${PV}
		LIB=lib64
	fi
}

src_unpack() {
	unpack ${A}
	
	if use modules; then
		pushd andor/src/driver >> /dev/null
		if kernel_is le 2 4; then
			mv Makefile2.4 Makefile
		else
			mv Makefile2.6 Makefile
		fi

#		epatch "${FILESDIR}/${PV}-fix-format-warnings.patch"
		popd >> /dev/null
	fi
}

src_compile() {
	# PCI Kernel Module
	if use modules; then
		pushd andor/src/driver >> /dev/null
		set_arch_to_kernel
		emake \
                LINUXDIR="${KERNEL_DIR}" \
                || die "Compiling kernel module failed"
		popd >> /dev/null
	fi
}

src_install() {
	# PCI Kernel Module
	if use modules; then
		insinto /lib/modules/${KV_FULL}/${PN}
		if kernel_is ge 2 6; then
			doins andor/src/driver/*.ko || die "doins kernel module failed"
		else
			doins andor/src/driver/*.o || die "doins kernel module failed"
		fi
		# Startup script
		dosbin andor/script/andordrvlx_load
		ewarn "iXon users MUST add the kernel mem= parameter in your boot loader."
		ewarn "Then on startup run as root:"
		ewarn "  /usr/sbin/andordrvlx_load DMA_MODE=1"
		elog "Other PCI camera users must run just:"
		elog "  /usr/sbin/andordrvlx_load"
		elog "non-iXon PCI camera users, don't forget edit Detector.ini per ReleaseNotes"
		# TODO: use a udev rule instead to load andordrvlx and perform associated actions
	fi

	# SDK library
	insinto ${ANDOR_HOME}
	doins andor/lib/${SDKLIB} || die "Could not find SDK lib ${SDKLIB}"
	insinto /usr/lib 
	dosym ../../${ANDOR_HOME}/${SDKLIB} /usr/lib/libandor.so || die "dosym libandor.so failed"
	dodir /etc/env.d || die "dodir failed"
	echo "LDPATH=${ANDOR_HOME}" > 10andor
	doenvd 10andor || die "doenvd failed"

	# SDK header
	insinto /usr/include
	doins andor/include/* || die "doins SDK header failed"

	# configuration files
	insinto /etc/andor
	doins andor/etc/* || die "doins etc files failed"
	# !!! The SDK hard-links to /usr/local/etc/andor
	# Missing this file placement results in Initailizing...exiting or 
	# SDK error 20096: DRV_LOAD_FIRMWARE_ERROR
	dosym ../../../../etc/andor/ /usr/local/etc/andor || die "dosym local to etc failed"

	# USB udev rule
	insinto /etc/udev/rules.d
	newins andor/script/andor.rules andor-usb.rules || die "doins usb udev rule failed"

	# Documentation
	dodoc andor/ReleaseNotes || die "dodoc failed"
	insinto ${ANDOR_HOME}/doc
	doins andor/doc/*.pdf
}
