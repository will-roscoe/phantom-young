.. phantom-doc: hand-written

io_grid
=======

Overview
--------

``io_grid`` is a module for reading and writing gridded data in four formats: ASCII, binary (Fortran unformatted), stream (direct-access binary), and HDF5. It is used by ``grid2pdf``, ``phantom2divb``, and other utilities to read pre-computed grid data files into Phantom post-processing tools.

The module exposes ``read_grid_header`` (which reads the grid dimensions :math:`N_x`, :math:`N_y`, :math:`N_z` and the number of columns) and ``read_grid_column`` (which reads a single data column from the grid into a 1D array). The format is specified as a string argument (``'ascii'``, ``'binary'``, ``'stream'``, or ``'hdf5'``).

A ``print_grid_formats`` routine lists the available formats with descriptions, making it easy for users to identify the correct format specifier when running grid post-processing tools.

Physical & Mathematical Description
------------------------------------

The grid is stored in column-major (Fortran) order, with the density column at index 1 followed by velocity components. For ASCII format, values are written as space-separated floating-point numbers; for binary, as Fortran unformatted records. The HDF5 format uses the ``hdf5utils`` C interface. All formats represent a regular :math:`(N_x \times N_y \times N_z)` Cartesian grid.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/io_grid.f90
