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
worst-case proportional to the total number of positions added to the graph. Instead, by adding a
second layer of indirection to the position-keyed mapping - now a position to pointer-to-mutable-id
mapping - the computational cost to join islands is bounded by the number of islands rather than the
number of positions.
