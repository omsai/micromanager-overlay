# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3} )
PYTHON_SINGLE_TARGET="python3_3"
CONFIG_CHECK="~VIDEO_V4L2"
inherit python-single-r1 java-pkg-opt-2 linux-info subversion

DESCRIPTION="The Open Source Microscopy Software"
HOMEPAGE="http://www.micro-manager.org/"
ESVN_REPO_URI="https://valelab.ucsf.edu/svn/micromanager2/trunk"
ESVN_BOOTSTRAP="autogen.sh"

SLOT="0"
LICENSE="GPL-3 BSD LGPL-2.1"
KEYWORDS="~amd64"
IUSE_cameras="+ieee1394"
IUSE_cameras_proprietary="andor andorsdk3"
IUSE="+X +python +doc +source +examples
${IUSE_cameras} ${IUSE_cameras_proprietary}"
REQUIRED_USE="X? ( java ) python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="mirror"

# FIXME verify which deps are conditional on X
JAVA_DEPS="
dev-java/commons-math:2
sci-libs/TSFProto
sci-libs/bioformats
X? (
>=sci-biology/imagej-1.48v
dev-java/bsh
dev-java/swingx:1.6
dev-java/swing-layout:1
dev-java/absolutelayout
dev-java/jfreechart:1.0
dev-lang/clojure
)
"
CAMERA_DEPS="
ieee1394? ( media-libs/libdc1394 )
andor? ( sci-libs/andor-camera-driver:2 )
andorsdk3? ( sci-libs/andor-camera-driver:3 )
"
COMMON_DEPS="
${CAMERA_DEPS}
python? ( dev-python/numpy )
"
RDEPEND="
${COMMON_DEPS}
java? (	>=virtual/jre-1.6 ${JAVA_DEPS} )
"
DEPEND="
${COMMON_DEPS}
dev-lang/swig
dev-libs/boost
java? (	>=virtual/jdk-1.6 ${JAVA_DEPS} )
doc? ( app-doc/doxygen )
"

src_configure() {
	# FIXME avoid using the subshell and environmental variables here by
	# patching ./m4/mm_java.m4 to resolve the java* symlinks in a sane
	# way.

	# Subshell to contain environmental variables for ./configure.
	(
		# Local variables for econf, but not defining as local since
		# we're in a subshell anyway.
		ij_jar=$(java-pkg_getjar imagej ij.jar)
		jdk_home=$(java-config -O)

		# Environmental variables for ./configure.  These are needed
		# because the configure script tries to resolve the symlinks for
		# java, javac, etc and fails when it sees eselect-java's bash
		# scripts.
		export JAVA_HOME=${jdk_home}
		export JAVA=$(java-config -J)
		export JAVAC=$(java-config -c)
		export JAR=$(java-config -j)

		econf \
			$(use !X && echo "--disable-java-app") \
			$(use_enable X imagej-plugin $(dirname ${ij_jar})) \
			--disable-install-dependency-jars \
			$(use_with java java ${jdk_home}) \
			$(use_with python ) \
			$(use_with X ij-jar ${ij_jar})
	)
}

src_install() {
	emake DESTDIR="${D}" install

	# TODO doc.
	# TODO source.
	# TODO examples.

	if use X; then
		make_desktop_entry "${PN}" "Micro-Manager Studio" imagej \
			"Graphics;Science;Biology"

		# TODO Launcher.
	fi
}
