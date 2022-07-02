# Kata: Islands

Inspired by
[Jérôme Cukier](https://www.quora.com/What-question-is-likely-to-be-asked-at-technical-interview-for-a-start-up-front-end-position-tc130k-He-noted-it-will-be-a-single-question-for-45-minutes-and-I-can-use-any-language-so-it-must-be-an-algo-Not-sure-how/answer/J%C3%A9r%C3%B4me-Cukier)

## Dependencies

* [Idris2](https://www.idris-lang.org/)
* [hash-table](https://github.com/alrunner4/idris-hashtable)

## Test Execution

```bash
idris2 -p hash-table Islands.idr -x example
```

## Implementation Notes

My choice of sparse representation here is slightly different than Jerome's: while creating a
two-way mapping from position to id and id to position-set serves to avoid some duplicated
depth-first traversal, the computational cost of joining islands is incurred up-front and is
worst-case proportional to the total number of positions added to the graph (_O(n)_). Instead, by
adding a second layer of indirection to the position-keyed mapping - now a position to
pointer-to-mutable-id mapping - the computational cost to join islands is bounded by the number of
islands rather than the number of positions. This would be significant if the supported use cases
include an expectation that the number of positions making up a single island may be much larger
than the number of contiguous islands within the dataset.

The performance implication of my arrangement of pointer-to-mutable variable (in Idris, an IORef of
an IORef of the identifying value) is that addition of positions that cause islands to be joined
only cost a number of pointer assignments on the order of the number of neighbors to that position,
in this case at most 4. A subsequent normalization step can be performed on the pointers within the
graph since the island-joining operation will leave the graph in a state with positions pointing to
different mutable identifiers that themselves were overwritten with a single unified identifier as
part of the join. The additional memory used by the non-normalized representation is on the order of
one pointer per position (_O(n)_), though the memory profile in comparison with the contrasted
approach is likely still better when taking into account the savings of not needing to store the
per-island position listing in addition to the position mapping.

