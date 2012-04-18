# Copyright 2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=2

inherit java-pkg-2 subversion

DESCRIPTION="Read and write Tagged Spot Format (TSF) files to store single molecule data such as in STORM/PALM imaging"
HOMEPAGE="http://valelab.ucsf.edu"
ESVN_REPO_URI="https://valelab.ucsf.edu/svn/valelabtools/TSFProto/src/"

SLOT="0"
LICENSE="BSD"
KEYWORDS="~amd64"

IUSE=""

RDEPEND=">=virtual/jre-1.5"
DEPEND=">=virtual/jdk-1.5
	dev-libs/protobuf[java]"

src_unpack() {
	subversion_src_unpack
}

src_prepare() {
	mkdir buildj buildc dist
	protoc --java_out=buildj --cpp_out=buildc ${PN}.proto || die
}

src_compile() {
	ejavac \
		-sourcepath buildj \
		-classpath $(java-pkg_getjar protobuf protobuf.jar) \
		buildj/edu/ucsf/tsf/TaggedSpotsProtos.java || die
	jar cf dist/${PN}.jar -C buildj . || die

	$(tc-getCC) \
		${CXXFLAGS} \
		-c buildc/${PN}.pb.cc -o buildc/lib${PN}.o || die
}

src_install() {
	java-pkg_dojar "dist/${PN}.jar"

	dolib "buildc/lib${PN}.o"
}
