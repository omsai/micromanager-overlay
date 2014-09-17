# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

PYTHON_COMPAT=( python{2_7,3_3,3_4} )
inherit distutils-r1

MY_FILES=( ${PN}.{py,c} )

DESCRIPTION="Read and write image data from and to TIFF files."
HOMEPAGE="http://www.lfd.uci.edu/~gohlke/"
SRC_URI=$(
	for file in ${MY_FILES[*]}; do
		echo "http://www.lfd.uci.edu/~gohlke/code/${file}"
	done
)

LICENSE="BSD"
SLOT="0"
KEYWORDS="x86"
IUSE="matplotlib"
RESTRICT="mirror"

DEPEND="dev-python/numpy
matplotlib? ( dev-python/matplotlib )"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/2013.11.05-unsigned-decimal-constants.patch
)

src_unpack() {
	mkdir ${S}
	cd ${S}
	for file in ${MY_FILES[*]}; do
		cp ${DISTDIR}/${file} .
	done

	cat <<-EOF > setup.py
	from distutils.core import setup, Extension
	import numpy
	setup(name="_tifffile",
		  version="2013.11.05",
		  description="Decodes PackBits and LZW encoded TIFF data.",
		  author="Christoph Gohlke",
		  author_email="cgohlke@uci.edu",
		  url="http://www.lfd.uci.edu/~gohlke/",
		  classifiers=[
			  "Development Status :: 4 - Beta",
			  "Environment :: Console",
			  "Intended Audience :: Developers",
			  "Intended Audience :: End Users/Desktop",
			  "Intended Audience :: Science/Research",
			  "License :: OSI Approved :: BSD License",
			  "Operating System :: MacOS :: MacOS X",
			  "Operating System :: Microsoft :: Windows",
			  "Operating System :: POSIX",
			  "Programming Language :: Python :: Implementation :: CPython",
			  "Topic :: Multimedia :: Graphics",
			  "Topic :: Multimedia :: Video :: Conversion",
			  "Topic :: Scientific/Engineering",
			  "Topic :: Software Development :: Libraries :: Python Modules",
		  ],
		  py_modules=["tifffile"],
		  ext_modules=[Extension("_tifffile", ["tifffile.c"],
								 include_dirs=[numpy.get_include()])])
	EOF

	default
}
