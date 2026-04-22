.. phantom-doc: hand-written

phantom2divv
============

Overview
--------

``phantom2divv`` is a post-processing tool that reads Phantom dump files and computes the divergence of the velocity field :math:`\nabla \cdot \mathbf{v}` (and optionally the curl) for all particles, writing the result to a new dump file. It calls ``get_derivs_global`` to evaluate all SPH derivatives including the ``divcurlv`` array.

The utility requires the ``curlv`` flag to be active (for curl computation) and uses the default kernel smoothing length ``hfact_default``. The output dump can be visualised in SPLASH to show the compression (:math:`\nabla \cdot \mathbf{v} < 0`) and expansion (:math:`\nabla \cdot \mathbf{v} > 0`) regions of the flow.

This tool is useful for studying shock structures, disc truncation, and accretion flows where the velocity divergence field reveals the physical structure of the flow more clearly than the velocity field itself.

Physical & Mathematical Description
------------------------------------

The SPH estimate of the velocity divergence is :math:`(\nabla \cdot \mathbf{v})_i = -\sum_j m_j (\mathbf{v}_j - \mathbf{v}_i) \cdot \nabla_i W_{ij} / \rho_i`. For a perfect fluid without shock heating, :math:`d\rho/dt = -\rho \nabla \cdot \mathbf{v}`, so negative divergence indicates compression and density growth. Shocks appear as localised regions of large :math:`|\nabla \cdot \mathbf{v}|`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2divv.f90
