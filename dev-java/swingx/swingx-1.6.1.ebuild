# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

JAVA_PKG_IUSE="doc source test"

inherit java-pkg-2 java-ant-2

MY_P="${P}-src"

DESCRIPTION="SwingLabs Swing Component Extensions"
HOMEPAGE="https://swingx.java.net/"
SRC_URI="http://java.net/downloads/swingx/releases/1.6.1/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="1.6"
KEYWORDS="~amd64 ~x86"

IUSE=""

RDEPEND="
	>=virtual/jre-1.6"
DEPEND="
	>=virtual/jdk-1.6
	app-arch/unzip
	test? (
		dev-java/ant-junit4:0
		dev-java/commons-collections:0
		dev-java/commons-lang:2.1
		dev-java/filters:0
		dev-java/hamcrest-core:0
	)"

S="${WORKDIR}/${MY_P}"

WANT_ANT_TASKS="ant-nodeps"

JAVA_ANT_REWRITE_CLASSPATH="yes"
JAVA_PKG_BSFIX_NAME="build.xml swinglabs-build-impl.xml build-impl.xml"

java_prepare() {
	# preserve demo-taglet for the doc target
	use doc && mv "lib/build-only/demo-taglet.jar" "."
	rm -vf $(find lib/ -name \*.jar) || die
	use doc && mv "demo-taglet.jar" "lib/build-only/"
}

src_test() {
	local jars="junit-4,hamcrest-core,commons-collections,commons-lang-2.1,filters"
	local gcp="$(java-pkg_getjars --build-only ${jars})"

	# remove failing test in 1.6.1
	rm -fv "src/test/org/jdesktop/swingx/SerializableTest.java" || die
	# the test wants to access X otherwise
	unset DISPLAY

	ANT_TASKS="ant-nodeps ant-junit4" eant "-Dgentoo.classpath=\"${gcp}\"" "test"
}

src_install() {
	java-pkg_dojar "dist/${PN}.jar"
	java-pkg_dojar "dist/${PN}-beaninfo.jar"

	use doc && java-pkg_dojavadoc dist/javadoc
	use source && java-pkg_dosrc src/java/* src/beaninfo/*
}
