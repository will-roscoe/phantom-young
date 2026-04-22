.. phantom-doc: hand-written

phantom2hdf5_utils
==================

Overview
--------

``phantom2hdf5_utils`` implements the core conversion routine ``convert_dump_to_hdf5`` that maps Phantom binary dump format to HDF5. It uses the ``dump_utils`` module to parse the Phantom dump structure (global block headers, data block headers, and array data) and the HDF5 Fortran library to write the output.

The routine handles all Phantom data types (``i_int``, ``i_real``, ``i_real4``, ``i_real8``, etc.) and preserves the full array block structure, including both global (header-level) and particle-level arrays. It correctly manages the real-size flag (``ierr_realsize``) to distinguish single- and double-precision Phantom dumps.

This module is the technical core of the ``phantom2hdf5`` program and is also available as a library routine for use in other conversion tools that require Phantom-to-HDF5 conversion.

Physical & Mathematical Description
------------------------------------

The conversion reads each Phantom block header tag (a character string of length ``lentag``) and the corresponding data type and size, then creates an HDF5 dataset with the same tag as the dataset name. Integer arrays are stored as ``H5T_NATIVE_INT``, single-precision as ``H5T_NATIVE_FLOAT``, and double-precision as ``H5T_NATIVE_DOUBLE``. The dump file identifier string (``fileid``) is stored as an HDF5 string attribute.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2hdf5_utils.f90
