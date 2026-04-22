.. phantom-doc: hand-written

phantom2divb
============

Overview
--------

``phantom2divb`` is a post-processing tool that reads Phantom dump files and computes the divergence of the magnetic field :math:`\nabla \cdot \mathbf{B}` for all particles, writing the result to a new dump file. It calls ``get_derivs_global`` to evaluate all SPH derivatives, including the divergence cleaning term ``divcurlB``.

The program requires MHD to be compiled in (``mhd = .true.``) and uses the full SPH operator evaluation from the ``deriv`` module. The output dump file can then be loaded into SPLASH to visualise the spatial distribution of :math:`|\nabla \cdot \mathbf{B}|` and identify regions where the divergence constraint is poorly satisfied.

This utility is essential for assessing the quality of magnetic field evolution in MHD simulations, since large values of :math:`|\nabla \cdot \mathbf{B}| / (|\mathbf{B}| / \Delta x)` indicate loss of the solenoidal constraint.

Physical & Mathematical Description
------------------------------------

In constrained gradient MHD the divergence of the magnetic field evolves as :math:`d(\nabla \cdot \mathbf{B})/dt = -(\nabla \cdot \mathbf{B}) \nabla \cdot \mathbf{v} + \nabla \times (\mathbf{v} \times \mathbf{B}) \cdot \nabla - \psi / l_\mathrm{div}`, where :math:`\psi` is the divergence cleaning scalar. The SPH estimate is :math:`(\nabla \cdot \mathbf{B})_i = \sum_j m_j (\mathbf{B}_j - \mathbf{B}_i) \cdot \nabla_i W_{ij} / \rho_i`.

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/utils/phantom2divb.f90
