.. phantom-doc: hand-written

moddump_default
===============

Overview
--------

``moddump_default`` is a no-operation moddump routine that reads a Phantom dump and writes it back out unchanged. It is the default moddump used when no specific modification is requested, and also serves as a template for implementing new moddump routines.

The ``modify_dump`` subroutine simply prints ``' no modifications performed '`` and returns without changing any particle data. This makes it useful as a minimal test that ``phantom_moddump`` can successfully read and write a dump file without any modification.

New moddump routines are created by replacing the body of ``modify_dump`` with the desired particle modifications, following the standard interface ``modify_dump(npart, npartoftype, massoftype, xyzh, vxyzu)``.

Physical & Mathematical Description
------------------------------------

The standard ``modify_dump`` interface receives the particle arrays ``xyzh(4, maxp)`` (positions and smoothing lengths), ``vxyzu(maxvxyzu, maxp)`` (velocities and internal energy), ``massoftype(maxtypes)`` (mass per particle type), and ``npartoftype(maxtypes)`` (number of each type), together with the total particle count ``npart``. Any modification is applied in-place on these arrays.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_default.f90`` for the complete source.
