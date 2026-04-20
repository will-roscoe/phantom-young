.. phantom-doc: hand-written

External Libraries
==================

Phantom integrates several discrete external libraries. These are not
documented in full here; this page provides a summary and references for
each library.

Non-Ideal MHD: NICIL
---------------------

NICIL (Non-Ideal Computations for Ions and Larmor) is an external library
providing non-ideal magnetohydrodynamics (MHD) coefficients for Phantom,
specifically Ohmic resistivity, ambipolar diffusion, and the Hall effect.

NICIL computes the conductivity tensor components required by Phantom's
magnetic field evolution equations. The library is located in
``src/lib/NICIL/`` and is maintained independently of Phantom.

**References:**

- Wurster (2016), PASA, 33, e041 — original NICIL description
- Wurster & Bonnell (2023), MNRAS, 522, 891–911 — dynamic boundary extension

Integration with Phantom is handled via ``src/main/nicil_supplement.f90``,
which provides the interface between NICIL's coefficient routines and
Phantom's MHD evolution.

.. seealso::

   `NICIL on GitHub <https://github.com/jameswurster/nicil>`_
