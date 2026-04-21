.. phantom-doc: hand-written

boundary_dynamic
================

Overview
--------
The ``boundary_dyn`` module implements dynamically adjusting periodic
boundaries for Phantom simulations of collapse and star-formation problems.
The algorithm was introduced by Wurster & Bonnell (2023, MNRAS 522, 891) to
enable simulations that begin from a large, low-density medium and follow the
collapse of dense clumps without wasting computational effort on a fixed,
oversized domain.

In the dynamic boundary scheme the simulation box dimensions are not fixed.
Instead, at each energy-evaluation step the module analyses the particle
distribution to determine whether the box needs to grow (to accommodate
material approaching the boundary) or shrink (to remove depopulated regions).
Particles that fall outside the new boundaries are killed, and new background
particles are injected at the boundary faces to maintain the ambient medium.
The properties of injected particles are copied from the existing background
particle whose density is closest to the initial background density
``rho_bkg_ini``.

The boundary is classified as moving at velocities ``vbdyx``, ``vbdyy``,
``vbdyz``, which allows the entire box to translate (e.g. in a shear flow or
wind-tunnel configuration). The module also tracks the extent of the
high-density gas — particles above the threshold density ``rho_thresh_bdy``
— and of "interesting" particles, defined as those whose velocity diverges
from the background flow by more than a tolerance fraction ``bdy_vthresh``.
The boundary is expanded to ensure that interesting particles remain at least
:math:`n_{\rm dtmax}\,\Delta t_{\rm max}\,v_{\rm ms}` away from the edge,
where :math:`v_{\rm ms}` is the fast magnetosonic speed. This criterion prevents
spurious wave reflections from the domain edge.

Physical & Mathematical Description
-------------------------------------
The effective boundary required to contain the particle distribution for at
least :math:`n_{\rm dtmax}` output steps is computed per-face. For the
:math:`+x` face in the hydrodynamic case:

.. math::
   :label: bdy_extent

   x_{\rm border}^{+} = \max\!\left[
       \max_a(x_a + n_{\rm dtmax}\,\Delta t_{\rm max}\,(v_{x,a} + c_{s,a} - v_{\rm bdy,x})),\;
       \max_a^{\rho > \rho_{\rm thresh}}(x_a) + W_x^{+}
   \right],

where the first term ensures that interesting particles (those with
:math:`|1 - v_{x,a}/v_{\rm bdy,x}| > \epsilon_{\rm bdy}`) will not reach the
boundary within :math:`n_{\rm dtmax}` steps at the local sound speed, and the
second term ensures a background buffer of width :math:`W_x^{+}` around the
densest gas. For MHD the sound speed is replaced by the fast magnetosonic speed
:math:`v_{\rm ms}` computed from the local Alfvén and sound speeds.

The minimum background buffer width is constrained by

.. math::

   W_{\rm min} = 10\,\xi\,h_{\rm fact}\!\left(\frac{m_{\rm gas}}
                 {\rho_{\rm bkg}}\right)^{1/3},

where :math:`\xi = \texttt{radkern}` is the kernel radius parameter and
:math:`h_{\rm fact}` is the smoothing-length factor, ensuring at least ten
kernel radii of background padding around the active region.

Particles are added or removed in slabs of thickness ``dxyz`` (the mean
particle spacing in the background medium). Each new particle is initialised
by copying all properties from the reference background particle ``ibkg`` and
then overwriting its position and, if sufficient background statistics are
available, its velocity and magnetic field with the mean values of quiet
background particles.

The ``update_xyzminmax`` routine applies the boundary velocity each timestep
to translate the box walls:

.. math::

   x_{\rm min} \leftarrow x_{\rm min} + \Delta t\,v_{\rm bdy,x},\qquad
   x_{\rm max} \leftarrow x_{\rm max} + \Delta t\,v_{\rm bdy,x},

and similarly in :math:`y` and :math:`z`.

Derivations
-----------
The buffer-width formula :eq:`bdy_extent` is derived by requiring that a
particle moving at the local fast signal speed will not reach the domain
boundary within :math:`n_{\rm dtmax}` output steps. Given a particle at
position :math:`x_a` with velocity :math:`v_{x,a}` and sound speed
:math:`c_{s,a}`, the furthest position it can reach in time
:math:`n_{\rm dtmax}\,\Delta t_{\rm max}` is
:math:`x_a + n_{\rm dtmax}\,\Delta t_{\rm max}\,(v_{x,a} + c_{s,a})`.
Subtracting the box-velocity contribution :math:`v_{\rm bdy,x}` accounts for
the moving reference frame of the domain. The minimum buffer width
:math:`W_{\rm min}` is derived from the requirement that at least ten kernel
radii of background medium surround the active region, which is the minimum
needed for accurate SPH density estimates at the boundary.

References
----------
The dynamic boundary method is described in Wurster & Bonnell (2023), MNRAS
522, 891–911. This paper is not yet in ``phantom.bib``; a citation key is
needed before inline ``\:cite\:`` references can be used. (not yet in
phantom.bib — citation key needed)

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/boundary_dynamic.f90
