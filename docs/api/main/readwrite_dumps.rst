.. phantom-doc: hand-written

readwrite_dumps
===============

Overview
--------

The ``readwrite_dumps`` module provides the top-level routines for writing and reading
Phantom binary snapshot (dump) files. Full dumps, written by ``write_fulldump``,
contain every array required to restart the simulation exactly: particle positions and
smoothing lengths (``xyzh``), velocities and thermal energies (``vxyzu``), phase flags
(``iphase``), magnetic field evolution arrays (``Bevol``, ``Bxyz`` for MHD runs), dust
properties, radiation fields, and point-mass (sink particle) data. Small dumps, written
by ``write_smalldump``, store a reduced subset sufficient for analysis and visualisation
but not for restart.

Dump files are structured in tagged blocks. A text file-identifier string (built by
``fileident`` in ``readwrite_dumps_common``) encodes the Phantom version, git SHA,
compile-time physics flags (MHD, dust, gravity, etc.), and a timestamp. An integer and
real-valued header (``dump_h``) follows, containing global scalars such as ``npart``,
``npartoftype``, ``nblocks`` (for MPI), ``gamma``, ``hfact``, ``alpha``, and the three
fundamental code units ``udist``, ``umass``, ``utime``. Particle arrays are then written
in typed blocks (``i_real4``, ``i_real8``, etc.) prefixed by block-length metadata.

The routine ``read_dump`` is the single entry point for reading both full and small
dumps. It calls ``unfill_header`` (from ``readwrite_dumps_common``) to extract global
scalars, allocates particle memory via the ``memory`` module, and then reads each array
block in a format-tolerant manner that can handle files written by older Phantom versions
or the sphNG code. HDF5 output is handled by a separate compiled layer; the binary path
is always available.

Physical & Mathematical Description
------------------------------------

The dump file format is a direct binary serialisation of Phantom's internal particle
arrays. Particle positions and smoothing lengths are stored as a single four-component
array:

.. math::

   \mathtt{xyzh}(1:4,\,i) = \bigl(x_i,\;y_i,\;z_i,\;h_i\bigr),

where :math:`h_i` is the smoothing length satisfying:

.. math::

   h_i = h_{\mathrm{fact}}\left(\frac{m_i}{\rho_i}\right)^{1/3}.

Velocities and thermal energy are packed similarly:

.. math::

   \mathtt{vxyzu}(1:4,\,i) = \bigl(v_{x,i},\;v_{y,i},\;v_{z,i},\;u_i\bigr),

with :math:`u_i` the specific internal energy. For MHD runs the magnetic field
evolution variable satisfies:

.. math::

   \mathtt{Bevol}(1:4,\,i) = \bigl(B_{x,i},\;B_{y,i},\;B_{z,i},\;\psi_i\bigr),

where :math:`\psi_i` is the hyperbolic divergence-cleaning scalar. The file-identifier
string has the format:

.. math::

   \underbrace{\mathtt{FT}}_{\text{full,tagged}}
   \mathtt{:Phantom:}\underbrace{\mathtt{v}x.x.x}_{\text{version}}
   \mathtt{:}\underbrace{\text{SHA}}_{\text{git hash}}
   \;\mathtt{(}\underbrace{\text{flags}}_{\text{physics}}\mathtt{)}\;
   \underbrace{\mathtt{dd/mm/yyyy\;hh:mm:ss}}_{\text{timestamp}}

where the first character is ``F`` for a full dump or ``S`` for a small dump, and the
second character is ``T`` when the file uses tagged arrays.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/readwrite_dumps.f90
