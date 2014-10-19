# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

# One must inherit `base' to use `java-pkg-2' with `distutils-r1' but
# not sure why.  Perhaps it is an idiosyncrasy of inheritance being
# shoehorned into Bash?
inherit base distutils-r1 java-pkg-2 java-pkg-simple

DESCRIPTION="Python wrapper for the Java Native Interface"
HOMEPAGE="http://github.com/CellProfiler/python-javabridge/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86"
IUSE="test"

COMMON_DEP="
dev-java/rhino:1.6
>=dev-python/cython-0.18
dev-python/numpy
"
DEPEND="
>=virtual/jdk-1.5
${COMMON_DEP}
"
RDEPEND="
>=virtual/jre-1.5
${COMMON_DEP}
"

S="${WORKDIR}/${P}"
MY_TARGET_DIR=${PN}/jars
MY_TARGETS=( runnablequeue test )
JAVA_GENTOO_CLASSPATH="junit-4"

java_prepare() {
	# Unbundle rhino.
	local bundled_jar="rhino-1.7R4.jar"
	cd ${S}/${MY_TARGET_DIR}
	rm -v ${bundled_jar} || die
	# Actually rhino 1.7.4 is bundled but we are using 1.7.2 ebuild
	# which, strangely, is slotted as 1.6 instead of 1.7 (hence the
	# "rhino-1.6" below).  Bug # 524528 is open to bump rhino to 1.7.4
	java-pkg_jar-from rhino-1.6 js.jar ${bundled_jar}
}

src_compile() {
	# This for loop is a hack for `java-pkg-simple_src_compile' not
	# building multiple targets.
	local java_src_root=java/org/cellprofiler/
	dirs=( runnablequeue javabridge)
	for ((i=0;i<${#dirs[@]};i++)) ; do
		JAVA_SRC_DIR="${java_src_root}${dirs[i]}"
		echo ${JAVA_SRC_DIR}
		java-pkg-simple_src_compile
		cp -v ${PN}.jar ${MY_TARGET_DIR}/${MY_TARGETS[i]}.jar
	done;

	distutils-r1_src_compile
}

src_install() {
	# Manual install for multiple jar targets.
	for target in ${MY_TARGETS[*]} ; do
		java-pkg-simple_verbose-cmd \
			java-pkg_dojar ${MY_TARGET_DIR}/${target}.jar
	done

	distutils-r1_src_install
}

# Work in progress:
#
# - jars folder is still installed in image.  Patch needed for Python
#   files to load the jars via java-config.
#
# - Fix numpy C API deprecation warning for importing
#   numpy/arrayobject.h
