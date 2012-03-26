# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI='2'

DESCRIPTION="SDK examples for libandor"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/download/download_file/?file=andor-${PV}.tar.gz -> andor-${PV}.tar.gz"
CONTACT_URL="http://www.andor.com/contact_us/"

# The binary libandor-stdc++ files, even though not installed by this package,
# are license restricted, hence "-with-exceptions" applies to the tarball only.
LICENSE="Andor-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="fetch"

DEPEND=">=sci-libs/libandor-${PV}"
RDEPEND="${DEPEND}"

ANDOR_HOME=/opt/andor
EXAMPLES_DIR=${ANDOR_HOME}/examples

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

src_unpack() {
	unpack ${A}

	DESTDIR="${EXAMPLES_DIR}/${FOLDER}"

	for FOLDER in $(cd andor/examples/console; ls -1d *); do
		insinto ${EXAMPLES_DIR}/${FOLDER}
		pushd andor/examples/console/${FOLDER} >> /dev/null

		# patch include
		echo "sed: replacing include stdio.h -> stdlib.h"
		sed -i "s:stdio:stdlib:g" *.cpp || "sed failed"

		# fix g++ warning "depricated conversion from string consant to `char*'"
		echo "sed: fixing string constant conversion warning"
		sed -i "s:(\":((char*)\":g" *.cpp || "sed failed"
		sed -i "s:,\":,(char*)\":g" *.cpp || "sed failed"
		sed -i "s:, \":, (char*)\":g" *.cpp || "sed failed"

		# add install rule to makefile
		echo "sed: adding install rule to makefiles"
		sed -i "/clean/ i INSTALL = install " makefile || die "sed failed"
		sed -i "/clean/ i prefix = /opt/andor/examples" makefile || die "sed failed"
		sed -i "/clean/ i bindir = \$(prefix)/${FOLDER}" makefile || die "sed failed"
		sed -i "/clean/ i install: ${FOLDER}" makefile || die "sed failed"
		# FIXME: makefile install rule should not use absolute path to Gentoo ${D}
		#        but using ${DESTDIR} creates sandbox access violation.
		#		 Solution may be using Makefile.am instead?
		sed -i "/clean/ i \	\$(INSTALL) ${FOLDER} ${D%\/}\$(bindir)/${FOLDER}" \
			makefile || die "sed failed"
		sed -i "/clean/ i \ " makefile || die "sed newline failed"

		popd >> /dev/null
	done
}

src_compile() {
	# examples
	for FOLDER in $(cd andor/examples/console; ls -1d *); do
		insinto ${EXAMPLES_DIR}/${FOLDER}
		pushd andor/examples/console/${FOLDER} >> /dev/null
		emake DESTDIR="${EXAMPLES_DIR}/${FOLDER}" || die "emake failed"
		popd >> /dev/null
	done
}

src_install() {
	# source and examples
	for FOLDER in $(cd andor/examples/console; ls -1d *); do
		insinto ${EXAMPLES_DIR}/${FOLDER}
		pushd andor/examples/console/${FOLDER} >> /dev/null
		doins *.cpp makefile || die "doins failed"
		if [ -e *.PAL ]; then
			doins *.PAL || die "doins failed"
		fi
		emake DESTDIR="${EXAMPLES_DIR}/${FOLDER}" install || die "install failed"
		popd >> /dev/null
	done

	fperms -R 775 ${EXAMPLES_DIR} || die "fperms failed"

	insinto ${EXAMPLES_DIR}
	echo "It is recommended you make a copy of the " >> README
	echo "Andor example programs, ${EXAMPLES_DIR}" >> README
	echo "for example in your user's home directory, since " >> README
	echo "1) only root has g++ permission to compile in /opt, and " >> README
	echo "2) if you rebuild the package you can override your " >> README
	echo "   modified examples" >> README
	doins README || die "newins failed"
}

# TODO: Python use flag support
