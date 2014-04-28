# Copyright 2009-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
S=${WORKDIR}/andor
BUILD_TARGETS=" "
CONFIG_CHECK="VIDEO_V4L2"
ERROR_V4L2="Kernel must be compiled with V4L2 support!"
MODULE_NAMES="bitflow(bitflow:${S}/bitflow/drv/)"
MODULESD_BITFLOW_DOCS="bitflow/README_dist"
MODULESD_BITFLOW_ADDITIONS=(
	"options /sbin/modprobe v4l2_common"
	"options /sbin/modprobe videodev"
	"options bitflow fwDelay1=200"
	"options bitflow customFlags=1"
)
inherit linux-mod multilib

DESCRIPTION="SDK library for scientific CMOS cameras"
HOMEPAGE="http://www.andor.com/software/sdk/"
SRC_URI="https://www.andor.com/my/ -> andor-sdk3-${PV}.tgz"

LICENSE="Andor-EULA"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE=""

RESTRICT="fetch"

DEPEND=""
RDEPEND=""

PREFIX=/opt/andor-3
BITFLOWDIR=${PREFIX}/bitflow
LIBDIR=${PREFIX}/$(get_libdir)
DOCDIR=${PREFIX}/doc
SYSCONFDIR=${PREFIX}/etc

pkg_nofetch() {
	einfo "Due to license restrictions, download:"
	einfo "${SRC_URI}"
	einfo "and place it in ${DISTDIR}"
}

src_prepare() {
	# BitFlow CameraLink framegrabber card.
	pushd bitflow/drv/
	mv Makefile_$(usex x86 32 64)b Makefile
	# Possible fix for issue #23; upstream contacted for confirmation.
	ebegin "Patching BitFlow driver"
	sed -i -e "s/VM_RESERVED/VM_DONTEXPAND | VM_DONTDUMP/" bflki.c
	eend
	popd

	# Remove BitFlow .svn junk.
	find . -type d -name ".svn" -print0 | xargs -0 rm -r

	BUILD_PARAMS="-C /lib/modules/${KV_FULL}/build M=${S}/bitflow/drv/"
}

src_install() {
	# BitFlow CameraLink framegrabber card.
	linux-mod_src_install

	# sCMOS SDK header.
	rm inc/atmcdLXd.h			# Useless CCD SDK-2 header.
	doheader inc/*

	# sCMOS SDK libraries.
	pushd $(usex x86 "x86" "x86_64")
	dodir ${LIBDIR}
	dodir /usr/$(get_libdir)
	for lib in $( ls *.so.${PV} ) ; do
		# Versioned library.
		( into ${PREFIX}; dolib.so ${lib} )
		# Symlinks.
		local lib_base=${lib%%.*}
		for link_name in ${lib_base}.so{.3,} ; do
			dosym ../..${LIBDIR}/${lib} /usr/$(get_libdir)/${link_name}
		done
	done
	popd

	# BitFlow SDK header.
	doheader bitflow/inc/*

	# BitFlow SDK library.
	pushd bitflow/$(usex x86 "32b" "64b")/lib
	lib=$(ls *.so)
	# Versioned library.
	( into ${PREFIX}; dolib.so ${lib} )
	# Symlinks.
	local lib_base=${lib%%.*}
	for link_name in ${lib_base}.so{.8,} ; do
		dosym ../..${LIBDIR}/${lib} /usr/$(get_libdir)/${link_name}
	done
	popd

	# BitFlow files (firmware, etc).
	dodir ${BITFLOWDIR}
	insinto ${BITFLOWDIR}
	pushd bitflow
	doins -r camf/ config/ fshf/
	popd

	# Library paths.
	local envd=10$(basename ${PREFIX})
	echo "LDPATH=${PREFIX}" >> ${envd}
	echo "BITFLOW_INSTALL_DIRS=${BITFLOWDIR}" >> ${envd}
	doenvd ${envd}

	# Fix hard-link to /usr/local/lib
	local myetc=andor_sdk.conf
	echo ${LIBDIR} > ${myetc}
	insinto /etc
	doins ${myetc}
	dosym ../../../etc/${myetc} ${SYSCONFDIR}/${myetc}
	dosym ../../../etc/${myetc} /usr/local/etc/${myetc}

	# sCMOS and BitFlow docs.
	insinto ${DOCDIR}
	doins ReleaseNotes.txt doc/* bitflow/README*


	# sCMOS SDK examples.
	insinto ${PREFIX}
	doins -r examples
}

pkg_postinst() {
	ewarn "Ensure your boot loader has the kernel 'nopat' parameter"
	ewarn "and that you are in the video group."
	echo
	einfo "To load the kernel module immediately, run:"
	einfo "  modprobe bitflow"
}
