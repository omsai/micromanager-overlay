# Copyright 2009-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit linux-mod multilib

OUTER_TARBALL="Andor_Linux_SDK_V${PV}.tar.gz"
TARBALL="andor-${PV}.tar.gz"

DESCRIPTION="SDK library for scientific digital CCD, ICCD, EMCCD cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/my/ -> ${OUTER_TARBALL}"

LICENSE="Andor-EULA"
SLOT="2"
KEYWORDS="~amd64"
IUSE="+modules +usb"

RESTRICT="fetch"

DEPEND=""
RDEPEND="usb? ( virtual/libusb:0
				dev-libs/libusb-compat )"

ANDOR_HOME=/opt/andor-2
SDKLIB=""

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${SRC_URI}"
	einfo "and place it in ${DISTDIR}"
}

pkg_setup() {
	! use modules && ! use usb && \
		die "Select at least one USE flag"

	use modules && kernel_is ge 2 6 24 && kernel_is lt 2 6 27 && \
		die "PCI module not compatible with kernels between 2.6.24 and 2.6.27"
	use modules && linux-mod_pkg_setup

	use usb && kernel_is le 2 4 && \
		die "2.4 kernels do not fully support USB"
	use usb && kernel_is lt 2 6 10 && \
		ewarn "Kernels < 2.6.10 may not support the interrupt polling rate" && \
		ewarn "requirement of Andor USB cameras.  You may see" && \
		ewarn "DRV_USB_INTERRUPT_ENDPOINT_ERROR from ${PN}"

	if use x86; then
		/sbin/ldconfig -p 2>&1 | grep libstdc++.so.6 1>/dev/null
		lib6=`echo $?`
		if [ $lib6 = 0 ]; then
			SDKLIB=libandor-stdc++6-i386.so.${PV}
		else
			SDKLIB=libandor-stdc++5-i386.so.${PV}
		fi
	fi
	use amd64 && SDKLIB=libandor-stdc++6-x86_64.so.${PV}
}

src_unpack() {
	# Upstream double bags tarball in a zip file
	#
	unpack ${A}
	mv ${WORKDIR}/${TARBALL} ${DISTDIR}
	unpack ${TARBALL}

	S=${WORKDIR}/andor/
	cd ${S}

	if use modules; then
		pushd src/driver
		if kernel_is le 2 4; then
			mv Makefile2.4 Makefile
		else
			mv Makefile2.6 Makefile
		fi
		popd
	fi

	# fix issue 2: deprecated SYSFS{}= keyname
	sed -i -e 's/SYSFS/ATTRS/g' script/andor.rules
}

src_compile() {
	if use modules; then
		cd src/driver

		set_arch_to_kernel

		emake LINUXDIR="${KERNEL_DIR}"
	fi
}

src_install() {
	# PCI Kernel Module
	#
	if use modules; then
		insinto /lib/modules/${KV_FULL}/${PN}
		if kernel_is ge 2 6; then
			doins src/driver/*.ko
		else
			doins src/driver/*.o
		fi

		# Startup script
		#
		dosbin script/andordrvlx_load
		echo "install andordrvlx /usr/sbin/andordrvlx_load DMA_MODE=1" \
			 >> ${T}/andor.conf
		insinto /etc/modprobe.d
		doins ${T}/andor.conf
	fi

	# SDK header
	#
	insinto /usr/include
	doins include/*

	# SDK library
	#
	local envd=10$(basename ${ANDOR_HOME})
	echo "LDPATH=${ANDOR_HOME}" > ${envd}
	doenvd ${envd}
	( into ${ANDOR_HOME}; dolib.so lib/${SDKLIB} )
	dosym ../../${ANDOR_HOME}/$(get_libdir)/${SDKLIB} /usr/$(get_libdir)/libandor.so.2
	dosym ../../${ANDOR_HOME}/$(get_libdir)/${SDKLIB} /usr/$(get_libdir)/libandor.so

	# firmware files
	#
	insinto ${ANDOR_HOME}/firmware
	doins etc/*

	# The SDK hard-links to /usr/local/etc/andor
	# Without this symlink you will see example programs output
	# "Initailizing...exiting" or
	# SDK error 20096: DRV_LOAD_FIRMWARE_ERROR
	#
	dosym ../../..${ANDOR_HOME}/firmware/ \
		  /usr/local/etc/andor
	dosym ../../../etc/andor/Detector.ini \
		  ${ANDOR_HOME}/firmware/Detector.ini

	# PCI configuration file (not needed for EEPROM equipped iXons)
	#
	insinto /etc/andor
	newins etc/DetectorTemplate.ini Detector.ini

	# USB udev rule
	#
	if use usb; then
		insinto /lib/udev/rules.d
		newins script/andor.rules andor-usb.rules
	fi

	# Documentation
	#
	insinto ${ANDOR_HOME}/doc
	doins INSTALL ReleaseNotes doc/*.pdf

	# Examples
	#
	insinto ${ANDOR_HOME}/doc/
	doins -r examples
}

pkg_postinst() {
	if use modules; then
		ewarn "iXon PCI/e users must add the kernel mem= parameter in your boot loader."
		echo
		ewarn "Other PCI camera users must edit the [system] section in"
		ewarn "  /etc/andor/Detector.ini"
		ewarn "Also unset DMA_MODE=1 parameter from /etc/modprobe.d/andor.conf"
		echo
		elog "Read ReleaseNotes for details"
	fi
}
