.. phantom-doc: hand-written

set_fixedentropycore
====================

Overview
--------

The ``set_fixedentropycore`` module replaces the inner region of a giant-
star density profile with a fixed-entropy (isentropic) core, providing a
physically motivated alternative to the flat or cubic-spline core
replacements.  In a convective stellar core the entropy is nearly uniform;
this module enforces that condition by constructing a core in which
:math:`P \propto \rho^\gamma` throughout, with :math:`\gamma` and the
entropy constant matched continuously to the surrounding envelope.

The isentropic core is hydrostatic by construction, so the modified
profile can be mapped directly onto SPH particles without requiring
additional relaxation of the core region.  The routine is particularly
important for common-envelope and giant-star disruption setups where the
core structure affects the outcome of the interaction.

Physical & Mathematical Description
------------------------------------

The isentropic core satisfies the polytropic relation

.. math::

   P = K_\mathrm{core}\,\rho^{\gamma},

where the constant :math:`K_\mathrm{core}` is fixed by continuity of
pressure and density at the matching radius :math:`r_\mathrm{core}`:

.. math::

   K_\mathrm{core} =
   \frac{P_\mathrm{orig}(r_\mathrm{core})}
        {\rho_\mathrm{orig}(r_\mathrm{core})^\gamma}.

Inside the core, the density profile is obtained by integrating the
hydrostatic equation

.. math::

   \frac{dP}{dr} = -\rho\,\frac{G M(<r)}{r^2}

with the isentropic EOS substituted for :math:`P`.  This reduces to a
Lane–Emden-type ODE inward from :math:`r_\mathrm{core}` with the
boundary condition :math:`\rho(r_\mathrm{core}) = \rho_\mathrm{orig}`.
The resulting central density :math:`\rho_0` and the core mass are
computed self-consistently, and mass conservation determines the final
normalisation.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/setup/set_fixedentropycore.f90
