# Copyright 2009-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools multilib

EAPI=4

ZIP="Andor_SDK3_(Linux)_V${PV}.zip"
TARBALL="andor-sdk3-${PV}.tgz"
AUTOTOOLS_FILES="sdk3-autotools.tar.gz"

DESCRIPTION="SDK library for scientific CMOS cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
ZIP_URI="https://www.andor.com/my/ -> ${ZIP}"
AUTOTOOLS_URI="https://github.com/omsai/sdk3-autotools/tarball/master -> ${AUTOTOOLS_FILES}"
SRC_URI="${ZIP_URI} ${AUTOTOOLS_URI}"

LICENSE="Andor-EULA"
SLOT="3"
KEYWORDS="~amd64"
IUSE="+modules"

RESTRICT="fetch"

DEPEND=""
RDEPEND=""

ANDOR_HOME=/opt/andor-3
PREFIX=${ANDOR_HOME}
EPREFIX=${PREFIX}
LIBDIR=${PREFIX}/$(get_libdir)
SYSCONFDIR=${PREFIX}/etc
DOCDIR=${PREFIX}/doc

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${ZIP_URI}"
	einfo "and"
	einfo "${AUTOTOOLS_URI}"
	einfo "and place it in ${DISTDIR}"
}

src_unpack() {
	# Upstream double bags tarball in a zip file
	#
	unpack ${A}
	mv ${WORKDIR}/${TARBALL} ${DISTDIR}
	unpack ${TARBALL}
	cp -r andor/* .

	ebegin "Copying autotools files patch"
	touch README NEWS AUTHORS
	cp -r omsai*/* .
	eautoreconf
	eend
}

src_configure() {
	econf 	--prefix ${PREFIX} \
		--libdir ${LIBDIR} \
		--sysconfdir ${SYSCONFDIR} \
		--docdir ${DOCDIR}
}

src_install() {
	emake DESTDIR="${D}" install

	# Symlinks
	#
	IMAGE_LIBDIR=${D}${LIBDIR}
	pushd ${IMAGE_LIBDIR} || die
	for lib_name in $( ls *.${PV} \
				| xargs -n1 basename ) ; do
		lib_base=${lib_name%%.*}
		SRC=${lib_base}.so.${PV}
		LINK_NAME=${lib_base}.so.3
		dosym ${SRC} ${LIBDIR}/${LINK_NAME}
	done
	popd

	# env.d
	#
        local envd=10$(basename ${ANDOR_HOME})
        echo "LDPATH=${ANDOR_HOME}" > ${envd}
        doenvd ${envd}

	# udev
	#
	local rules_path=/usr/$(get_libdir)/udev/rules.d
	dodir ${rules_path}
	dosym ../../..${LIBDIR}/udev/rules.d/andor.rules \
		 ${rules_path}/andor.rules

	dosym ..${SYSCONFDIR}/andor_sdk.conf /etc/andor_sdk.conf

	# Examples
	#
	insinto ${ANDOR_HOME}
	doins -r examples
}
