/*!
 *  \file     csbpt.h
 *  \brief    CSB+ Tree Implementation in C
 *  \author   Matt Weaver (matt@innerweaver.com)
 *  \date     2009
 *
 *  <a href="index.html">Main documentation</a>
 */

/*!
 *  \mainpage CSB+ Tree Implementation in C
 *
 *  - API Reference: csbpt.h
 *  - Developer Documentation: csbpt.c
 *
 *  \section Overview
 *
 *  The goal of the csbpt library is to make a general-purpose, reusable data
 *  structure which can be used as the basis for quickly creating more advanced
 *  structures.
 *
 *  The implementation is based on CSB+ trees.  Because they are designed to
 *  make maximum use of the CPU's memory cache, these trees have been shown to
 *  have better performance characteristics for in-memory use than many popular
 *  alternatives.
 *
 *  The generality comes from a design inspired by the Haskell's finger trees:
 *  keys are computed from values using a user-provided measure function, and
 *  combined using a combinator function.
 *
 *  One limitation is that, for performance, measurements are always ints, and
 *  are always compared using C's built-in comparison operators, rather than
 *  a user-provided comparator.
 *
 *  \section Error-Handling
 *
 *  All functions have a documented sentinel return value to indicate failure.
 *  The \c errno variable is set with an error code from either the ISO or
 *  POSIX.1 list of error codes.
 *
 *  If an error occurs in a function which has a corresponding function used to
 *  release its resources, the second function does not need to be called.  For
 *  example, if csbpt_create() fails, there is no need to call csbpt_release().
 *
 *  \section Structure
 *
 *	A B+ tree keeps all of its leaf nodes at the same level in the tree.  In
 *	addition, only the leaf nodes contain data.  Higher level nodes contain
 *	indexes used to make searching faster.
 *
 *	A CSB+ tree is essentially a B+ tree, with an important change to make it
 *	more friendly.  Rather than allocating each node separately and having
 *	parent nodes keep a pointer to each children, all direct children of a
 *	node are combined into a single node group, and accessed via pointer
 *	arithmetic.
 *
 *	This method provides better spatial locality for nodes, hopefully
 *	minimizing the number of cache misses.  It also means that only a single
 *	pointer need be stored in the parent node, meaning that nodes take up less
 *	memory, which in turn means that they are less likely to exhaust the cache.
 *
 *	The number of children of each node is controlled by the \c order of the
 *	tree.  If \c d is the order and \c c is the number of children, \c c is
 *	such that \f$d <= c <= 2d\f$
 *
 *  This means that the height of the tree (and thus the number of levels to
 *  be searched through before a leaf is reached) is \f$log_2d(n)\f$, where
 *  \c n is the number of entries in the tree.
 *
 *  The height of the tree is automatically increased as necessary to maintain
 *  these invariants.
 *
 *  The order of the tree is controllable through a #csbpt_tune setting.
 *
 *  \section References
 *
 *  - <a href="http://www.it.iitb.ac.in/~it603/Project/ref/cacheConsciousBTrees00.pdf">Making B+-Trees Cache Conscious in Main Memory</a>
 *  - <a href="https://oa.doria.fi/bitstream/handle/10024/2906/cachecon.pdf">Cache-Conscious Index Structures for Main-Memory Databases</a>
 *  - <a href="http://www.soi.city.ac.uk/~ross/papers/FingerTree.pdf">Finger trees: a simple general-purpose data structure</a>
 *
 */

#ifndef CSBPT_H_
#define CSBPT_H_

#include <stdio.h>

/*!
 *  \brief Opaque handle to a tree
 */
struct csbpt;

/*!
 *  \brief Parameters to tune a tree
 *
 *  These parameters provide detailed control over a tree's setting.  See the
 *  main documentation for more details on their meaning.
 */
struct csbpt_tune {
	/*!
	 *  The order of the tree.
	 */
	int order;

	/*!
	 *  The initial height of the tree.  The tree will have an initial capacity
	 *  of \f$2d^h\f$ entries.  If the tree is created with a set of initial
	 *  values greater than this, its initial height will be increased beyond
	 *  this value.
	 */
	int initial_height;
};

/*!
 *  \brief Function to measure a value
 *
 *  The measure function is used to compute an integer key from a given value.
 *  This is referred to as a measure, rather than a key, to emphasise that it
 *  is used in comparison operations, rather than opaquely.  Values are always
 *  passed by pointer.
 *
 *  \param  val  Value to measure
 *
 *  \return Integer measure of the value
 */
typedef int (csbpt_measure_fn)(void *val);

typedef int (csbpt_predicate_fn)(void *user_data, void *val);

typedef int (csbpt_action_fn)(void *user_data, void *val);

/*!
 *  \brief Generates a new tree
 *
 *  Generates a new tree with the given tuning parameters and measure function.
 *
 *  \param  tune                 Tuning parameters to control how the tree
 *                                 behaves.  If 0, the default parameters are
 *                                 used.
 *  \param  measure              Function used to measure
 *  \param  combinator           Function used to combine values
 *  \param  initial_values       Values to bulk load into the tree on creation.
 *                                 Bulk loading values on creation is
 *                                 significantly faster than adding them
 *                                 individually later.
 *  \param  initial_value_count  Number of values pointed at by initial_values.
 *
 *  \retval NULL     An error occurred.
 *  \retval other    The function completed successfully
 */
struct csbpt *csbpt_create(struct csbpt_tune *tune,
                           csbpt_measure_fn *measure,
                           void *initial_values, size_t initial_value_count, size_t initial_value_elem_size);


/*!
 *  \brief Releases a tree
 *
 *  Releases a tree and all the resources associated with it.  This should be
 *  called when you are through using a tree for performance purposes.
 *
 *  \param  tree   Tree to release
 *
 *  \retval     0  Resources were released successfully
 *  \retval other  An error occurred while freeing resources
 */
int csbpt_release(struct csbpt *tree);

int csbpt_insert(struct csbpt *tree, void *value);

int csbpt_push_left(struct csbpt *tree, void *value);

int csbpt_push_right(struct csbpt *tree, void *value);

int csbpt_delete(csbpt_predicate_fn *predicate);

int csbpt_find_value(struct csbpt *csbpt, void *user_data, csbpt_predicate_fn *predicate, csbpt_action_fn *action);

int csbpt_find_first_pred(struct csbpt *csbpt, void *user_data, csbpt_predicate_fn *predicate, csbpt_action_fn *action);

int csbpt_find_all_pred(struct csbpt *csbpt, void *user_data, csbpt_predicate_fn *predicate, csbpt_action_fn *action);

int csbpt_iterate(struct csbpt *csbpt, void *user_data, csbpt_action_fn *action);

int csbpt_save(struct csbpt *csbpt, FILE *file);

#ifdef CSBPT_DEBUG
int csbpt_dump_dot(struct csbpt *tree, FILE *file);
#endif

struct csbt *csbpt_load(FILE *file);

#endif /* CSBPT_H_ */
