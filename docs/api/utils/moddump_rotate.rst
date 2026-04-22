.. phantom-doc: hand-written

moddump_rotate
==============

Overview
--------

``moddump_rotate`` applies a solid-body rotation to all gas particles about the :math:`z`-axis at a specified angular frequency :math:`\Omega`. Written by Mike Lau, it uses the ``--omega`` command-line flag (default :math:`\Omega = 7.92 \times 10^{-3}` in code units) to set the rotation rate.

Each particle's velocity is updated by adding the rotational component :math:`\mathbf{v}_\mathrm{rot} = \Omega \hat{z} \times \mathbf{r}`, with :math:`\hat{z}` being the rotation axis. This is equivalent to starting a stellar envelope simulation in a frame rotating at the specified angular frequency, which is useful for common envelope simulations where the orbital frequency defines the corotating frame.

The modification preserves particle positions and masses while adding angular momentum to the velocity field, which is the correct initial condition for a star that has been synchronised to its orbital period.

Physical & Mathematical Description
------------------------------------

The solid-body rotation velocity at position :math:`\mathbf{r}` about the :math:`z`-axis is :math:`\mathbf{v}_\mathrm{rot} = \Omega \hat{z} \times \mathbf{r} = \Omega (-y, x, 0)`. Each particle's velocity is updated as :math:`\mathbf{v}_i \leftarrow \mathbf{v}_i + \mathbf{v}_{\mathrm{rot},i}`. The resulting velocity profile gives a flat rotation curve in the :math:`xy$-plane with velocity increasing linearly with cylindrical radius :math:`R`: :math:`v_\phi = \Omega R`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_rotate.f90`` for the complete source.
