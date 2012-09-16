# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

JAVA_PKG_IUSE="doc"
inherit java-pkg-2 java-ant-2 subversion

DESCRIPTION="AutoComplete is a library allowing you to add IDE-like auto-completion to any Swing JTextComponent"
HOMEPAGE="http://fifesoft.com/autocomplete/"
ESVN_REPO_URI="http://svn.fifesoft.com/svn/RSyntaxTextArea/AutoComplete/tags/2.0.4/"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

COMMON_DEP="=dev-java/rsyntaxtextarea-${PV}"
DEPEND=">=virtual/jdk-1.5
${COMMON_DEP}"
RDEPEND=">=virtual/jre-1.5
${COMMON_DEP}"

S=${WORKDIR}
EANT_BUILD_TARGET="make-jar"
EANT_DOC_TARGET="make-javadoc"
EANT_GENTOO_CLASSPATH="rsyntaxtextarea"
JAVA_ANT_CLASSPATH_TAGS="${JAVA_ANT_CLASSPATH_TAGS} javadoc"

src_prepare() {
	java-ant_rewrite-classpath build.xml
}

src_install() {
	java-pkg_dojar dist/${PN}.jar

	use doc && java-pkg_dojavadoc javadoc
}
