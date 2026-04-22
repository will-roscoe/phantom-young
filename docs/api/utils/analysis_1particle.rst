.. phantom-doc: hand-written

analysis_1particle
====================================================================================================================================================================================================================================================================================================================================

Overview
--------

``analysis_1particle`` is a post-processing analysis routine for use with ``phantomanalysis``. On the first call the user is prompted to select a particle index; subsequent calls append the position and velocity of that particle to the output file ``particle_NNNNN.ev`` at each dump time.

This routine is useful for tracking the trajectory of a single SPH particle through a simulation, for example to study the orbit of a test particle in a disc, or to verify particle dynamics against an analytic solution.

The output columns are time, :math:`x`, :math:`y`, :math:`z`, :math:`v_x`, :math:`v_y`, :math:`v_z`, written in double precision for high accuracy.

Physical & Mathematical Description
------------------------------------

The routine extracts the phase-space coordinates :math:`(\mathbf{r}, \mathbf{v})` of the selected particle from the ``xyzh`` and ``vxyzu`` arrays at each dump snapshot, writing the six-dimensional phase vector as a function of simulation time :math:`t`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/analysis_1particle.f90`` for the complete source.
