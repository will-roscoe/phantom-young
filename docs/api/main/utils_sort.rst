.. phantom-doc: hand-written

utils_sort
==========

Overview
--------

The ``sortutils`` module provides low-level sorting and indexing routines
used throughout Phantom. The primary public routine is ``indexx``, which
returns an index array that sorts a given real or 8-byte integer array into
ascending order without reordering the array itself (i.e., an indirect sort
or argsort). The ``indexxfunc`` variant accepts a function pointer, allowing
particles to be sorted by an arbitrary scalar criterion — the standard use
is the radius function ``r2func`` or ``r2func_origin`` which returns
:math:`r^2` relative to a given origin.

Additional public routines include: ``Knnfunc`` for finding the :math:`k`
nearest neighbours of a point, ``parqsort`` for a parallel quicksort via
OpenMP, ``find_rank`` for determining the rank of a value in a sorted array,
and ``sort_by_radius`` for a combined sort-and-reorder operation. The module
stores the sort origin ``(x0, y0, z0)`` as private module-level state that
can be set by ``set_r2func_origin``.

Physical & Mathematical Description
------------------------------------

The ``indexx`` routine implements the Heapsort algorithm on the input array
to produce the permutation array without modifying the original data. Heapsort
is used because it is :math:`O(N\log N)` in the worst case (unlike quicksort)
and requires no extra memory beyond the index array. The parallel quicksort
``parqsort`` uses OpenMP task parallelism and is typically faster for large
arrays (:math:`N \gtrsim 10^5`).

References
----------

.. bibliography:: ../../phantom.bib
   :cited:
   :style: plain

API Reference
-------------

.. f:autosrcfile:: ../../../src/main/utils_sort.f90
