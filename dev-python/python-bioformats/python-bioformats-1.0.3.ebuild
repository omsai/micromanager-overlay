# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python2_7 )

inherit distutils-r1

DESCRIPTION="Python wrapper for Bio-Formats to read and write life sciences file formats"
HOMEPAGE="github.com/CellProfiler/python-bioformats/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2 BSD"
SLOT="0"
KEYWORDS=""
IUSE="doc test"

DEPEND="dev-python/javabridge"
RDEPEND="${DEPEND}"

# Work in progress:
#
# - Unbundle loci-tools.jar and add bioformats dependency.  Hard masked
#   until bundled jar is removed.
