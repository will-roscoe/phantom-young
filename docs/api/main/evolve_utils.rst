.. phantom-doc: hand-written

evolve_utils
============

Overview
--------

The ``evolve_utils`` module provides a set of utility routines that support
the main ``evolve`` time-integration loop without being part of the core
physics update. The module is responsible for managing simulation time and
dump scheduling, deciding when to write output files, creating or updating
sink particles and their gravitational forces, and printing per-step log
summaries.

The key public routines are: ``update_time_and_dt`` — advances the
simulation time, checks that individual timestep bins are consistent, and
computes the next global timestep; ``ptmass_create_and_update_forces`` —
checks whether any gas particle has exceeded the sink-creation density
threshold and, if so, creates a new sink, then recomputes sink–sink and
sink–SPH forces; ``write_ev_files`` — triggers output of the ``.ev``
evolution file and the log summary; ``check_and_write_dump`` — decides
whether a full or partial dump should be written at the current time;
and ``print_log`` — formats and prints the per-step timing and physics
summary to the log file.

Physical & Mathematical Description
------------------------------------

The dump schedule is determined by the ``dtmax`` parameter and an integer
step fraction: at each global step the code checks whether
:math:`t_\text{next\,dump} \leq t + \Delta t`. For individual (hierarchical)
timesteps the global time is reconstructed as :math:`t = t_\text{last} +
(i_\text{frac} / 2^{n_\text{binmax}}) \Delta t_\text{max}` to avoid
round-off accumulation. This ensures that dump times remain exact multiples
of ``dtmax`` regardless of the total number of sub-steps taken.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/evolve_utils.F90
