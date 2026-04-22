.. phantom-doc: hand-written

phantom2sphNG
=============

Overview
--------

``phantom2sphNG`` converts a Phantom dump file to the legacy sphNG format, enabling Phantom simulation snapshots to be read by the sphNG code or old SPLASH versions. It reads the Phantom dump using ``read_dump`` and writes the output in sphNG binary format using ``write_fulldump`` with the sphNG format option.

The conversion is primarily useful for backward compatibility with tools that were developed for sphNG (a predecessor of Phantom) and have not been updated for the Phantom binary format. The reverse conversion (sphNG to Phantom) is not needed since Phantom can read sphNG dumps directly.

Usage is ``phantom2sphNG dumpfilein dumpfileout``.

Physical & Mathematical Description
------------------------------------

The sphNG dump format stores particle data in a specific binary layout with unformatted Fortran records, including an integer header, a real-number header, and then separate records for positions, velocities, smoothing lengths, densities, and internal energies. The conversion preserves all conserved quantities but may lose quantities (such as magnetic field components) that are not present in the sphNG format.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2sphNG.f90
