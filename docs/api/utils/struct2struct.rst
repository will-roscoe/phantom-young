.. phantom-doc: hand-written

struct2struct
=============

Overview
--------

``struct2struct`` is a utility program for converting velocity structure function files between the four formats supported by the ``io_structurefn`` module: ASCII (split or combined), KITP (``.sfn``), and Federrath (``.dat``). This enables structure function data computed in one format (e.g. by Phantom) to be read by tools that require a different format.

Usage is ``struct2struct [outformat] infiles``, where ``outformat`` is the desired output format index (1-4) and ``infiles`` is one or more input files. If no output format is specified, the program defaults to format 1 (ASCII combined). Each input file is converted independently.

This tool is useful when comparing structure functions from Phantom with published data from other codes (such as FLASH or Enzo) that use different output conventions.

Physical & Mathematical Description
------------------------------------

The structure function data stored in each format consists of arrays :math:`S_p^{L,T}(\ell_k)` for :math:`p = 1, \ldots, N_\mathrm{order}` orders and :math:`k = 1, \ldots, N_\mathrm{lag}` lag values. The conversion reads using ``read_structurefn`` (which auto-detects the input format via ``get_sfn_format``) and writes using ``write_structurefn`` with the target format index.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/struct2struct.f90
