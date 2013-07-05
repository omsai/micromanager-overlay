# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} )
PYTHON_SINGLE_TARGET="python2_7"

inherit eutils autotools python-single-r1 java-pkg-opt-2 flag-o-matic java-utils-2 vcs-snapshot

MY_PN="micromanager-upstream"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="The Open Source Microscopy Software"
HOMEPAGE="http://www.micro-manager.org/"
SRC_URI="http://github.com/mdcurtis/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"

SLOT="0"
LICENSE="LGPL-2.1 BSD GPL-3"
KEYWORDS="~x86 ~amd64"
IUSE="+java python clojure_editor ieee1394 andor"
RESTRICT="mirror"

RDEPEND="java? (
		>=virtual/jre-1.5
	)
	ieee1394? ( media-libs/libdc1394 )"

DEPEND="dev-lang/swig
	dev-libs/boost
	java? (
		>=virtual/jdk-1.5
		>=sci-biology/imagej-1.46e
		dev-java/bsh
		dev-java/commons-math:2
		dev-java/swingx:1.6
		dev-java/swing-layout:1
		dev-java/absolutelayout
		dev-java/jfreechart:1.0
		dev-lang/clojure
		clojure_editor? ( dev-util/clooj )
		sci-libs/TSFProto
		sci-libs/bioformats
	)
	python? (
		${PYTHON_DEPS}
		dev-python/numpy
	)
	andor? ( sci-libs/andor-camera-driver:2 )"

pkg_setup() {
	use java && java-pkg-opt-2_pkg_setup
	use python && python-single-r1_pkg_setup
}

src_prepare() {
	# fix zlib detection
	for file in configure.in DeviceKit/configure.in; do
		sed -i -e "s/libz.a/libz.so/g" $file
	done

	epatch ${FILESDIR}/andor_camera_detection.patch
	epatch ${FILESDIR}/arduino_detection.patch

	ebegin "Bootstrap started.  This can take several minutes"
	sh mmUnixBuild.sh
	eend

	einfo "Patching to prevent imagej collision"
	sed -i -e '/cp $(IJJARPATH)/d' mmstudio/Makefile.am

	einfo "Patching to prevent scripts removal"
	sed -i -e '/rm -rf $(IJPATH)\/scripts.*$/d' scripts/Makefile.am

	if use python; then
		einfo "Patching numpy include directory"
		local numpy_sitedir
		numpy_includedir=$(python_get_sitedir)/numpy/core/include/numpy
		sed -i -e "/include_dirs/s~=.*~= \[\"${numpy_includedir}\"\]~" MMCorePy_wrap/setup.py

		einfo "Patching Python bindings to respect DESTDIR"
		sed -i -e 's: $(DEVICEADAPTERPATH): $(DESTDIR)\/$(DEVICEADAPTERPATH):' MMCorePy_wrap/Makefile.am
	fi

	if use java; then
		# making and clearing a single `build' directory prevents
		# multiple plugins from being built simultaneously
		sed -i -e 's/build/build_$@/g' plugins/Makefile.am

		# TODO Make ebuilds for lwm, gaussian
		#      Removing plugins requiring these deps until ebuilds made
		REMOVE_MM_PLUGINS="DataBrowser Gaussian"
		if ! use clojure_editor ; then
			REMOVE_MM_PLUGINS="${REMOVE_MM_PLUGINS} ClojureEditor"
		fi
		for PLUGIN in ${REMOVE_MM_PLUGINS}; do
			einfo "Removing ${PLUGIN} plugin"
			sed -i -e "/^all:/s/$PLUGIN\.jar//g" \
				-e "/^\tcp $PLUGIN\.jar/d" \
				plugins/Makefile.am
		done

		eautoconf
		# FIXME	eautoreconf should replace eautoconf and
		#	subversion_bootstrap lines, but dies because
		#	./Makefile.am searches for the non-existent
		#	SecretDeviceAdapters directory
		#eautoreconf
	fi
}

src_configure() {
	if use java; then
		append-cppflags $(java-pkg_get-jni-cflags)

		IMAGEJ_DIR=$(dirname `java-pkg_getjar imagej ij.jar`) \

		ebegin 'Creating symlinks to .jar dependencies...'
		mkdir -p ../3rdpartypublic/classext/
		pushd ../3rdpartypublic/classext/
		java-pkg_jar-from bsh bsh.jar bsh-2.0b4.jar
		java-pkg_jar-from swingx-1.6 swingx.jar swingx-0.9.5.jar
		java-pkg_jar-from commons-math-2 commons-math.jar commons-math-2.0.jar
		java-pkg_jar-from swing-layout-1 swing-layout.jar swing-layout-1.0.4.jar
		java-pkg_jar-from absolutelayout absolutelayout.jar AbsoluteLayout.jar
		java-pkg_jar-from jfreechart-1.0 jfreechart.jar jfreechart-1.0.13.jar
		java-pkg_jar-from jcommon-1.0 jcommon.jar jcommon-1.0.16.jar
		java-pkg_jar-from imagej
		java-pkg_jar-from clojure-1.4
		if use clojure_editor; then
			java-pkg_jar-from clooj clooj-0.3.4-standalone.jar clooj.jar
		fi
		java-pkg_jar-from protobuf protobuf.jar gproto.jar
		java-pkg_jar-from TSFProto
		java-pkg_jar-from bioformats

		# TODO: Make these dep ebuilds and symlinks for plugins:
		# lwm, gaussian
		popd
		eend
	else
		IMAGEJ_DIR='no'
	fi

	econf \
		--with-imagej=${IMAGEJ_DIR} \
		$(use_enable python)
}

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install

	if use java; then
		# FIXME	java-pkg_dolauncher should replace this bash script.
		#	Problems encountered when attempting this were:
		#	1. dolauncher uses the same name for the launcher and
		#	   the package (gjl_package).  What we want for this
		#	   package is:
		#		/usr/bin/micro-manager
		#	   to contain:
		#		gjl_package=imagej
		#	2. Fixing issue #1 above by editing the output file
		#	   creates unusual behavior with Micro-Manager, always
		#	   asking to select a dataset to open on startup.
		cat <<-EOF > "${T}"/${PN}
		#!/bin/bash

		(
		# MM plugins won't load without changing to this path
		cd /usr/share/imagej/lib

		\$(java-config --java) \\
		   -mx1024m \\
		   -cp \$(java-config -p imagej,libreadline-java) \\
		   ij.ImageJ -run "Micro-Manager Studio"
		) 2>&1 | tee >(logger -t micro-manager) -

		exit 0
		EOF

		make_desktop_entry "${PN}" "Micro-Manager Studio" imagej \
			"Graphics;Science;Biology"

		dobin "${T}"/${PN}
	fi
}
