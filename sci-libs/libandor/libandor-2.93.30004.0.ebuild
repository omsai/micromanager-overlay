# Copyright 2009-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

EAPI=2

ZIP="Andor_SDK2_(Linux)_V${PV}.zip"
TARBALL="andor-${PV}.tar.gz"

DESCRIPTION="SDK library for scientific digital CCD, ICCD, EMCCD cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/my/ -> ${ZIP}"

LICENSE="Andor-EULA"
SLOT="2"
KEYWORDS="~amd64"
IUSE="+modules +usb"

RESTRICT="fetch"

DEPEND=""
RDEPEND="usb? (
		virtual/libusb:0
		sys-fs/udev
	)"

ANDOR_HOME=/opt/andor
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

	use x86 && SDKLIB=libandor-stdc++6-i386.so.${PV}
	use amd64 && SDKLIB=libandor-stdc++6-x86_64.so.${PV}
}

src_unpack() {
	# Upstream double bags tarball in a zip file
	#
	unpack ${A}
	mv ${WORKDIR}/${TARBALL} ${DISTDIR}
	unpack ${TARBALL}

	mv ${WORKDIR}/andor/* ${WORKDIR}/

	if use modules; then
		cd src/driver
		if kernel_is le 2 4; then
			mv Makefile2.4 Makefile
		else
			mv Makefile2.6 Makefile
		fi
	fi
}

src_compile() {
	if use modules; then
		cd src/driver

		set_arch_to_kernel

		emake LINUXDIR="${KERNEL_DIR}" \
			|| die "Kernel module compile failed"
	fi
}

src_install() {
	# PCI Kernel Module
	#
	if use modules; then
		insinto /lib/modules/${KV_FULL}/${PN}
		if kernel_is ge 2 6; then
			doins src/driver/*.ko || die "doins kernel module failed"
		else
			doins src/driver/*.o || die "doins kernel module failed"
		fi

		# Startup script
		#
		dosbin script/andordrvlx_load \
			 || die "dosbin load module failed"
		echo "install andordrvlx /usr/sbin/andordrvlx_load DMA_MODE=1" \
			 >> ${T}/andor.conf
		insinto /etc/modprobe.d
		doins ${T}/andor.conf || die "doins andor.conf failed"
	fi

	# SDK header
	#
	insinto /usr/include
	doins include/* || die "doins SDK header failed"

	# SDK library
	#
	insinto ${ANDOR_HOME}
	doins lib/${SDKLIB} || die "Could not find SDK lib ${SDKLIB}"
	insinto /usr/lib 
	dosym ../../${ANDOR_HOME}/${SDKLIB} /usr/lib/libandor.so \
              || die "dosym libandor.so failed"
	echo "LDPATH=${ANDOR_HOME}" > 10andor
	doenvd 10andor || die "doenvd failed"

	# firmware files
	#
	insinto ${ANDOR_HOME}/firmware
	doins etc/* || die "doins firmware files failed"

	# The SDK hard-links to /usr/local/etc/andor
	# Without this symlink you will see example programs output
	# "Initailizing...exiting" or 
	# SDK error 20096: DRV_LOAD_FIRMWARE_ERROR
	#
	dosym ../../../../opt/andor/firmware/ \
	      /usr/local/etc/andor \
	      || die "dosym firmware to local failed"
	dosym ../../../../etc/andor/Detector.ini \
	      /opt/andor/firmware/Detector.ini \
	      || die "dosym etc to firmware failed"

	# PCI configuration file (not needed for EEPROM equipped iXons)
	#
	insinto /etc/andor
	newins etc/DetectorTemplate.ini Detector.ini \
              || die "newins PCI configuration file failed"

	# USB udev rule
	#
	insinto /lib/udev/rules.d
	newins script/andor.rules andor-usb.rules \
               || die "newins usb udev rule failed"

	# Documentation
	#
	insinto ${ANDOR_HOME}/doc
	doins INSTALL README ReleaseNotes doc/*.pdf || die "dodoc failed"
}

pkg_postinst() {
	if use modules; then
		ewarn "iXon users MUST add the kernel mem= parameter in your boot loader."
		echo
		elog "Non-iXon PCI camera users must edit the [system] section in"
		elog "  /etc/andor/Detector.ini"
		elog "Also unset DMA_MODE=1 parameter from /etc/modprobe.d/andor.conf"
		echo
		elog "See ReleaseNotes for details"
	fi
}
