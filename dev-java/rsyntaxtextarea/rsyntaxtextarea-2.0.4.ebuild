# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

JAVA_PKG_IUSE="doc"
inherit java-pkg-2 java-ant-2

DESCRIPTION="RSyntaxTextArea is a syntax highlighting text component written in Swing"
HOMEPAGE="http://fifesoft.com/rsyntaxtextarea/"
SRC_URI="mirror://sourceforge/${PN}/${PN}_${PV}_Source.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND=">=virtual/jdk-1.5"
RDEPEND=">=virtual/jre-1.5"

S=${WORKDIR}
EANT_BUILD_TARGET="make-jar"
EANT_DOC_TARGET="make-javadoc"
JAVA_ANT_CLASSPATH_TAGS="${JAVA_ANT_CLASSPATH_TAGS} javadoc"

src_prepare() {
	# Make compatible for > 1.4 VMs
	sed -i -e 's/throws SAXException /throws SAXException, IOException /g' \
		src/org/fife/ui/${PN}/parser/XmlParser.java
	# Silence compatibility warning since it's now been fixed for > 1.4 VMs
	sed -i -e 's/^.*<echo.*$//g' build.xml
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dojavadoc javadoc
}
