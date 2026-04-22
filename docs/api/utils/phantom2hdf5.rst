.. phantom-doc: hand-written

phantom2hdf5
============

Overview
--------

``phantom2hdf5`` is a command-line utility that converts Phantom binary dump files to HDF5 format, preserving all header information and array data blocks. It delegates to the ``convert_dump_to_hdf5`` routine from ``phantom2hdf5_utils``, which handles the low-level HDF5 file creation and dataset writing.

Usage is ``phantom2hdf5 dumpfile(s)``, accepting one or more dump files on the command line. Each input dump is converted independently, producing an output HDF5 file with the same base name and a ``.h5`` extension.

The HDF5 format is widely supported by Python (via h5py), Julia, and C/C++ tools, making this utility essential for enabling post-processing analysis of Phantom simulations in languages other than Fortran.

Physical & Mathematical Description
------------------------------------

The conversion maps each Phantom binary data block (positions, velocities, smoothing lengths, densities, etc.) to a named HDF5 dataset. The dump header fields (``npart``, ``nptmass``, ``time``, ``hfact``, ``units``) are stored as HDF5 attributes of the root group. Array blocks are stored as 1D or 2D HDF5 datasets with appropriate dimension labels.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2hdf5.f90
