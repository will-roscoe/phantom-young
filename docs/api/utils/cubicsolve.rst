.. phantom-doc: hand-written

cubicsolve
==========

Overview
--------

``cubicsolve`` provides analytic routines for finding all real (and complex) roots of a cubic polynomial equation of the form :math:`a x^3 + b x^2 + c x + d = 0`. Written by Daniel Price and described in the module ``cubic``, it uses the Cardano-Vieta formula following the presentation in Woan's Cambridge Handbook of Physics Formulas (2000).

The module contains both a real-root solver (``cubicsolve``) that returns up to three real roots and a complex-root solver (``cubicsolve_complex``) that returns all three roots including complex conjugate pairs. The complex solver is used by the ``dustywaves`` module to compute the analytic dispersion relation for dusty sound waves, which in general has complex roots corresponding to damped oscillations.

The algorithms reduce the general cubic to depressed form by substitution :math:`x = t - b/(3a)`, then apply Cardano's formula or the trigonometric method for the case of three real roots (the casus irreducibilis).

Physical & Mathematical Description
------------------------------------

The depressed cubic :math:`t^3 + pt + q = 0` (obtained by eliminating the quadratic term) has discriminant :math:`\Delta = -4p^3 - 27q^2`. If :math:`\Delta > 0` there are three distinct real roots given by :math:`t_k = 2\sqrt{-p/3}\cos\!\left[\frac{1}{3}\arccos\!\left(\frac{3q}{2p}\sqrt{-3/p}\right) - \frac{2\pi k}{3}\right]` for :math:`k = 0, 1, 2`. If :math:`\Delta < 0` there is one real root and two complex conjugate roots, found via Cardano's formula.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/cubicsolve.f90`` for the complete source.
