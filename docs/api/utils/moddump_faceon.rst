.. phantom-doc: hand-written

moddump_faceon
==============

Overview
--------

``moddump_faceon`` realigns a disc simulation so that the disc midplane lies in the :math:`xy`-plane (face-on orientation) with the disc angular momentum vector aligned along :math:`\hat{z}`, and optionally moves the origin to the position of a specified sink particle. Written by Josh Calcino, it uses the angular momentum vector of the disc (computed from particle data) to determine the required rotation.

The routine computes the total angular momentum :math:`\mathbf{L}` of all gas particles, finds the rotation that maps :math:`\mathbf{L}` to :math:`\hat{z}`, and applies this rotation to all particle positions and velocities (gas and sinks) simultaneously. The origin can then be shifted to a sink particle position if desired.

This moddump is a necessary pre-processing step for generating face-on synthetic observations or for analysis tools that assume the disc lies in the :math:`xy`-plane.

Physical & Mathematical Description
------------------------------------

The rotation from the current angular momentum direction :math:`\hat{\mathbf{L}}` to :math:`\hat{z}` is performed by the rotation matrix :math:`\mathbf{R} = \mathbf{I} + \sin\theta [\mathbf{k}]_\times + (1 - \cos\theta) [\mathbf{k}]_\times^2`, where :math:`\mathbf{k} = \hat{\mathbf{L}} \times \hat{z} / |\hat{\mathbf{L}} \times \hat{z}|` is the rotation axis and :math:`\theta = \arccos(\hat{\mathbf{L}} \cdot \hat{z})` is the rotation angle. The matrix :math:`[\mathbf{k}]_\times` is the skew-symmetric cross-product matrix (Rodrigues' rotation formula).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. note::

   This file is excluded from automatic API extraction. Refer to
   ``src/utils/moddump_faceon.f90`` for the complete source.
