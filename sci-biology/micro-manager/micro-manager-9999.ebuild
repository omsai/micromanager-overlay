# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_6,2_7,3_1,3_2,3_3,3_4} )
DISTUTILS_OPTIONAL=1
CONFIG_CHECK="VIDEO_V4L2"
JAVA_ANT_DISABLE_ANT_CORE_DEP=1
inherit autotools java-pkg-opt-2 java-ant-2 distutils-r1 linux-info vcs-snapshot

MY_PN="micromanager-upstream"

DESCRIPTION="The Open Source Microscopy Software"
HOMEPAGE="http://www.micro-manager.org/"
if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/mdcurtis/${MY_PN}.git"
	SRC_URI=""
else
	SRC_URI="http://github.com/mdcurtis/${MY_PN}/archive/${PV}.tar.gz -> ${P}.tar.gz"
fi

SLOT="0"
LICENSE="GPL-3 BSD LGPL-2.1"
KEYWORDS="~amd64 ~x86"
IUSE_proprietary="andor andorsdk3"
IUSE="+X +java python doc ${IUSE_proprietary}"
REQUIRED_USE="X? ( java ) python? ( ${PYTHON_REQUIRED_USE} )"

CAMERA_DEPS="
	dev-libs/hidapi
	dev-libs/libusb-compat
	media-libs/freeimage
	media-libs/libdc1394
	media-libs/libgphoto2
	media-libs/opencv
"
PROPRIETARY_DEPS="
	andor? ( sci-libs/andor-camera-driver:2 )
	andorsdk3? ( sci-libs/andor-camera-driver:3 )
"
COMMON_DEPS="
	${CAMERA_DEPS}
	${PROPRIETARY_DEPS}
	X? (
		dev-java/commons-math:2
		dev-java/commons-math:3
		sci-libs/TSFProto:0
		sci-libs/bioformats:0
		dev-java/absolutelayout
		dev-java/bsh:0
		dev-java/gson:2.2.2
		dev-java/guava:17
		dev-java/jcommon:1.0
		dev-java/jfreechart:1.0
		dev-java/joda-time:0
		dev-java/miglayout:0
		dev-java/rsyntaxtextarea:0
		dev-java/swing-layout:1
		dev-java/swingx:1.6
		dev-lang/clojure:1.6
		dev-java/clojure-core-cache:0
		dev-java/clojure-core-memoize:0
		dev-java/clojure-data-json:0
		dev-libs/protobuf:0=[java]
		>=sci-biology/imagej-1.48:0=
	)
	python? ( dev-python/numpy[${PYTHON_USEDEP}] ${PYTHON_DEPS} )
"
RDEPEND="
	${COMMON_DEPS}
	java? (	>=virtual/jre-1.6 )
"
DEPEND="
	${COMMON_DEPS}
	dev-libs/boost
	doc? ( app-doc/doxygen )
	java? (
		>=virtual/jdk-1.6
		dev-lang/swig
		dev-java/ant-core
		>=dev-java/ant-contrib-1.0_beta3:0
		dev-java/hamcrest-core:1.3
		>=dev-java/junit-4.11:4
	)
	python? ( dev-lang/swig )
"

JAVA_ANT_REWRITE_CLASSPATH=1
JAVA_ANT_CLASSPATH_TAGS="mm-javac javac xjavac"
EANT_GENTOO_CLASSPATH="bsh,imagej,clojure-1.6,joda-time,bioformats,commons-math-2,commons-math-3,gson-2.2.2,guava-17,jcommon-1.0,jfreechart-1.0,miglayout,rsyntaxtextarea,swingx-1.6,TSFProto,protobuf"
ECLJ_GENTOO_CLASSPATH="clojure-core-cache,clojure-core-memoize,clojure-data-json"

pkg_setup() {
	java-pkg-opt-2_pkg_setup
	linux-info_pkg_setup
}

src_prepare() {
	epatch "${FILESDIR}"/secretdevice.patch
	epatch "${FILESDIR}"/drop_direct_junit_paths.patch
	epatch "${FILESDIR}"/disable_prefs_during_clojure_builds.patch
	epatch "${FILESDIR}"/makefile.am-typo.patch

	# Disable build of plugins that are impossible to satisfy the dependencies of
	local ech
	for ech in ClojureEditor ; do
		sed -i -e "/${ech}.jar/d" plugins/Makefile.am || die
		mv plugins/${ech}/build.xml{,.donotbuild} || die
	done

	eautoreconf

	java-pkg-opt-2_src_prepare
	use python && distutils-r1_src_prepare
}

src_configure() {
	local conf_opts my_ant_flags=()

	if use X ; then
		local ij_jar=$(java-pkg_getjar imagej ij.jar)
		local ij_dir=$(dirname ${ij_jar})
	else
		conf_opts+=" --disable-java-app"
	fi

	if use java ; then
		local jdk_home=$(java-config -O)
		# ./configure fails when it sees eselect-java's bash scripts.
		conf_opts+=" JAVA_HOME=${jdk_home}"
		conf_opts+=" JAVA=$(java-config -J)"
		conf_opts+=" JAVAC=$(java-config -c)"
		conf_opts+=" JAR=$(java-config -j)"
		my_ant_flags+=( -Dmm.build.java.lib.ant-contrib=$(java-pkg_getjar --build-only ant-contrib ant-contrib.jar) )
		my_ant_flags+=( -Dmm.build.java.lib.junit=$(java-pkg_getjar --build-only junit-4 junit.jar) )
		my_ant_flags+=( -Dmm.build.java.lib.hamcrest-core=$(java-pkg_getjar --build-only hamcrest-core-1.3 hamcrest-core.jar) )
		my_ant_flags+=( -Dgentoo.classpath=$(java-pkg_getjars ${EANT_GENTOO_CLASSPATH}):$(java-pkg_getjars --with-dependencies ${ECLJ_GENTOO_CLASSPATH}) )
	fi

	if use python ; then
		python_setup
		local python_home=$(python_get_library_path)
	fi

	ANTFLAGS="${my_ant_flags[@]}" \
	econf \
		$(use_enable X imagej-plugin ${ij_dir}) \
		--disable-install-dependency-jars \
		$(use_with java java ${jdk_home}) \
		$(use_with python python ${python_home}) \
		$(use_with X ij-jar ${ij_jar}) \
		${conf_opts}

	java-ant-2_src_configure
	java-ant_rewrite-classpath buildscripts/javabuild.xml
	java-ant_rewrite-classpath autofocus/buildscripts/autofocusbuild.xml
	# manually hack gentoo.classpath into the clojure classpath
	sed -i -e 's#.*</clj-classpath>.*#<pathelement path="${gentoo.classpath}"/>\n&#' \
		buildscripts/clojurebuild.xml || die
}

src_install() {
	emake DESTDIR="${D}" install

	# TODO doc.
	# TODO source.
	# TODO examples.
	use java && java-pkg_regjar /usr/share/imagej/lib/plugins/Micro-Manager/{MMCoreJ,MMJ_,MMAcqEngine}.jar

	if use X; then
		java-pkg_dolauncher ${PN}-standalone \
			--main org.micromanager.MMStudio \
			--pwd /usr/share/imagej/lib \
			--java_args '-Xmx1024M -XX:MaxDirectMemorySize=1000G' \
			--pkg_args '-Dmmcorej.library.loading.stderr.log=yes -Dmmcorej.library.path="/usr/share/imagej/lib" -Dorg.micromanager.plugin.path="/usr/share/imagej/lib/mmplugins" -Dorg.micromanager.autofocus.path="/usr/share/imagej/lib/mmautofocus"  -Dorg.micromanager.default.config.file="/usr/share/imagej/lib/MMConfig_demo.cfg" -Dorg.micromanager.corelog.dir=/tmp' \

		java-pkg_dolauncher ${PN} \
			--main ij.ImageJ \
			--pwd /usr/share/imagej/lib \
			--java_args '-Xmx1024M -XX:MaxDirectMemorySize=1000G' \
			--pkg_args '-Dmmcorej.library.loading.stderr.log=yes -Dmmcorej.library.path="/usr/share/imagej/lib" -Dorg.micromanager.plugin.path="/usr/share/imagej/lib/mmplugins" -Dorg.micromanager.autofocus.path="/usr/share/imagej/lib/mmautofocus"  -Dorg.micromanager.default.config.file="/usr/share/imagej/lib/MMConfig_demo.cfg" -Dorg.micromanager.corelog.dir=/tmp' \

		make_desktop_entry "${PN} -eval 'run(\"Micro-Manager Studio\");'" "Micro-Manager Studio" ImageJ \
			"Graphics;Science;Biology"
	fi
}
