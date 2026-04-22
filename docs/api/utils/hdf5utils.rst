.. phantom-doc: hand-written

hdf5utils
=========

Overview
--------

``hdf5utils`` provides Fortran interfaces to the C routines that handle HDF5 file I/O for Phantom grid data. The module uses Fortran's ``iso_c_binding`` to declare ``bind(c)`` interfaces to the C functions in ``write_grid_hdf5.c`` and ``read_grid_hdf5.c``, enabling Phantom to read and write HDF5-format grid files without a direct Fortran HDF5 library dependency.

The interface covers writing a 3D float array to an HDF5 dataset (``write_grid_hdf5``), reading the grid dimensions (``read_grid_hdf5_header``), and reading individual columns of grid data (``read_grid_hdf5_column``) in either single or double precision. A generic interface ``read_grid_hdf5_column`` dispatches to the appropriate precision variant.

This module is used by ``io_grid`` and ``phantom2hdf5_utils`` to provide HDF5 format support in the grid I/O and dump conversion utilities.

Physical & Mathematical Description
------------------------------------

The HDF5 format stores the 3D grid as a C-order dataset of shape :math:`(N_x, N_y, N_z)`. The C binding maps Fortran array indices to C column-major layout via the ``bind(c)`` attribute, with the dataset name and filename passed as null-terminated C strings (``character(kind=c_char)``). Data are stored as single-precision (``c_float``) or double-precision (``c_double``) depending on the interface variant.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/hdf5utils.f90
