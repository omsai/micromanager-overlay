# Copyright 2009-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit linux-mod

EAPI=2

ZIP="Andor_SDK3_(Linux)_V${PV}.zip"
TARBALL="andor-sdk3-${PV}.tgz"
AUTOTOOLS_FILES="sdk3-autotools.tar.bz2"

DESCRIPTION="SDK library for scientific CMOS cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/my/ -> ${ZIP}
	https://raw.github.com/omsai/micromanager-overlay/master/sci-libs/libandor/files/${AUTOTOOLS_FILES}"

LICENSE="Andor-EULA"
SLOT="3"
KEYWORDS="~amd64"
IUSE="+modules"

RESTRICT="fetch"

DEPEND=""
RDEPEND=""

ANDOR_HOME=/opt/andor
SDKLIB=""

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${SRC_URI}"
	einfo "and place it in ${DISTDIR}"
}

src_unpack() {
	# Upstream double bags tarball in a zip file
	#
	unpack ${A}
	mv ${WORKDIR}/${TARBALL} ${DISTDIR}
	unpack ${TARBALL}

	mv ${WORKDIR}/andor/* ${WORKDIR}/

	# Patch in autotools files
	#
	unpack ${AUTOTOOLS_FILES}
	eautoreconf
}

src_install() {
	emake install || die
}
