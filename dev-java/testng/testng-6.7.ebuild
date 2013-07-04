# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
JAVA_PKG_IUSE="doc examples source test"

inherit java-pkg-2 java-ant-2 vcs-snapshot

DESCRIPTION="TestNG is a testing framework inspired from JUnit and NUnit"
HOMEPAGE="http://testng.org/"
SRC_URI="https://github.com/cbeust/${PN}/archive/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="6"
KEYWORDS="~amd64"
IUSE=""

CDEPEND="dev-java/bsh
		dev-java/ant-core
		dev-java/jcommander:1.13
		dev-java/qdox:1.6
		dev-java/snakeyaml
		dev-java/guice:2
		dev-java/junit:4"
DEPEND=">=virtual/jdk-1.5
		test? ( dev-java/junit )
		${CDEPEND}"
RDEPEND=">=virtual/jre-1.5
		${CDEPEND}"

JAVA_ANT_REWRITE_CLASSPATH=1
JAVA_PKG_BSFIX_NAME="build.xml build-tests.xml"
JAVA_ANT_CLASSPATH_TAGS+=" testng javadoc"
JAVA_PKG_FILTER_COMPILER="ecj-3.7"

EANT_GENTOO_CLASSPATH="ant-core,bsh,qdox-1.6,junit-4,jcommander-1.13,snakeyaml,guice-2"
EANT_BUILD_TARGET="compile create-jar"
#include target jar into javadocs generation as containing required annotation classes
EANT_GENTOO_CLASSPATH_EXTRA="./${PN}.jar"
EANT_DOC_TARGET="javadocs"

EANT_TEST_TARGET="tests"

java_prepare() {
	find . -iname '*.jar' -exec rm -v {} +

	#remove bundled classes
	rm -v src/test/java/test/jar/test/jar/*.class

	#remove ivy support
	sed -i -e 's/.*ivy:.*//' build.xml
	mkdir lib
	#fix output jar filename
	sed -i -e "s/\${jar.file}/${PN}.jar/" build.xml

	epatch "${FILESDIR}/${P}-testng.xml.patch"
}

src_test() {
	EANT_GENTOO_CLASSPATH+=",junit"
	cp "${PN}.jar" "target/${P}.jar" || die
	eant -f build-tests.xml run
}

src_install() {
	java-pkg_dojar "${PN}.jar"
	java-pkg_dolauncher testng --main org.testng.TestNG
	java-pkg_register-ant-task

	use doc && java-pkg_dojavadoc javadocs/
	use source && java-pkg_dosrc src/main/org/ src/main/com/
	use examples && java-pkg_doexamples examples/
}
