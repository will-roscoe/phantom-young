.. phantom-doc: hand-written

setup_params
============

Overview
--------

``setup_params`` is not a simulation setup routine but a shared parameter module. It defines global variables that are used across multiple setup and analysis routines within Phantom: the maximum radius ``rmax``, the background density ``rhozero``, the logical flag ``ihavesetupB`` indicating whether a magnetic field has been initialised, and the 64-bit integer ``npart_total`` tracking the cumulative particle count across MPI ranks.

Because Fortran module variables are shared across any routine that uses the module, ``setup_params`` acts as a lightweight global registry for quantities that must be communicated between the setup routines and the main code without being passed explicitly as subroutine arguments. This pattern avoids namespace pollution while keeping the parameter values accessible everywhere they are needed.

This module has no runtime parameters, no ``setpart`` subroutine, and no dependencies — it is a pure data module compiled into every setup that requires shared state.

Physical & Mathematical Description
------------------------------------

The module exposes four variables: ``rmax`` (real), used as the outer radius in spherical setups; ``rhozero`` (real), the reference or mean density used for normalisation; ``ihavesetupB`` (logical), set to ``.true.`` when :math:`\mathbf{B}` has been initialised to prevent the main code from overwriting the field; and ``npart_total`` (integer(kind=8)), the total number of particles summed over all MPI domains, used for parallel load balancing.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/setup/setup_params.f90`` for the complete source.
