/*!
 *  \file     csbpt.c
 *  \brief    CSB+ Tree Implementation in C
 *  \author   Matt Weaver (matt@innerweaver.com)
 *  \date     2009
 */

#include "csbpt.h"

#include <math.h>
#include <stdlib.h>
#include <string.h>

#define CSBPT_ELEM_SIZE (sizeof(int) + sizeof(void *))

/*
 *  Internal Structures
 */

/*!
 *  \brief Internal tree node
 *
 *  A structure for internal nodes.  Internal nodes hold keys and an array of
 *  child nodes (a node group).
 */
struct csbpt_internal_node {
	int    num_keys;   /*!< The number of keys in this node; corresponds to the number of children */
	int   *keys;       /*!< Keys of the child nodes                                                */
	void  *children;   /*!< Child nodes; may be csbpt_internal_node or csbpt_leaf_node instances   */
};

/*!
 *  \brief Node group at the base of the tree
 *
 *  This is a "flattened" set of leaf nodes.  Each leaf node consists of
 *  nothing but a set of memory consisting of alternating pairs of int keys
 *  and pointer values.
 *
 *  Leaf nodes are conceptually linked together into a double-linked-list, but
 *  since each node in a node group is contiguous, they can be physically
 *  combined into a single pair of pointers and a flattened chunk of data.
 */
struct csbpt_leaf_group {
	struct csbpt_leaf_group   *next;        /*!< Pointer to the next node group */
	struct csbpt_leaf_group   *prev;        /*!< Pointer to the prev node group */
	size_t                     num_elems;   /*!< Number of elements             */
};


/*!
 *  \brief The tree structure itself.
 *
 *  Contains tree metadata, and a pointer to the root node.
 */
struct csbpt {
	size_t                       min_children;     /*!< The minimum number of children under a tree node */
	size_t                       max_children;     /*!< The maximum number of children under a tree node */
	int                          height;           /*!< Current height of the tree                       */
	csbpt_measure_fn            *measure;          /*!< Function used to measure a value                 */
	struct csbpt_internal_node  *root;             /*!< Root of the tree                                 */
#ifdef CSBPT_DEBUG
	size_t                       bytes_used;       /*!< Number of bytes allocated for the tree           */
#endif
};

/*
 *  Helper functions
 */


/*!
 *  Creates a node group of internal nodes.
 *
 *  \param  tree       Tree to allocate for
 *
 *  \retval NULL       If an error occurred
 *  \retval other      If allocation succeeded
 */
static struct csbpt_internal_node *alloc_internal_node_group(struct csbpt *tree)
{
	struct csbpt_internal_node *ret;

	ret = calloc(tree->max_children, sizeof(struct csbpt_internal_node));

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Allocating an internal node group of %d bytes to hold %d nodes of %d bytes each at address %x\n",
			tree->max_children * sizeof(struct csbpt_internal_node), tree->max_children, sizeof(struct csbpt_internal_node), ret);
	tree->bytes_used += tree->max_children * sizeof(struct csbpt_internal_node);
#endif

	return ret;
}

static struct csbpt_internal_node *alloc_internal_row(struct csbpt *tree, size_t num_nodes)
{
	int i;
	int num_groups;
	struct csbpt_internal_node *ret;

	num_groups = num_nodes / tree->max_children;
	ret = calloc(num_nodes, sizeof(struct csbpt_internal_node));

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Allocating an internal row %d bytes to hold %d nodes of %d bytes each at address %x\n",
			num_nodes * sizeof(struct csbpt_internal_node), num_nodes, sizeof(struct csbpt_internal_node), ret);
	tree->bytes_used += num_nodes * sizeof(struct csbpt_internal_node);
#endif

	return ret;
}

/*!
 *  Creates a node group of leaf nodes
 *
 *  \param  tree        Tree to allocate for
 *
 *  \retval NULL        If an error occurred
 *  \retval other       If allocation succeeded
 */
static struct csbpt_leaf_group *alloc_leaf_node_group(struct csbpt *tree)
{
	struct csbpt_leaf_group *ret = NULL;

	ret = calloc(1, sizeof(struct csbpt_leaf_group) + tree->max_children * CSBPT_ELEM_SIZE);

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Allocating a leaf node group of size %d to hold %d leaves at address %x\n",
			sizeof(struct csbpt_leaf_group) + tree->max_children * CSBPT_ELEM_SIZE, tree->max_children, ret);
	tree->bytes_used += sizeof(struct csbpt_leaf_group) + tree->max_children * CSBPT_ELEM_SIZE;
#endif

	return ret;
}

/*!
 *  Calculates the height required for a tree to hold the given number of elements
 *
 *  \param  max_children  Maximum number of children per node
 *  \param  num_elems     Required capacity
 *
 *  \return Height required to hold the given capacity
 */
static int calc_required_height(int max_children, int num_elems)
{
	int  hyp_cur_height = 0;
	int  hyp_num_elems  = 1;

	while(hyp_num_elems < num_elems) {
		hyp_cur_height++;
		hyp_num_elems *= max_children;
	}

	return hyp_cur_height;
}

/*!
 *  Allocates memory for the given tree.  Calls itself recursively to allocate
 *  lower levels.
 *
 *  \param  tree   Tree to allocate memory for
 *  \param  root   Root of the current subtree being allocated
 *  \param  height Height of the current subtree being allocated
 *
 *  \retval 0      Allocation succeeded
 *  \retval other  Allocation failed
 */
static int alloc_tree(struct csbpt *tree, struct csbpt_internal_node *root, int height)
{
	int i;

	if(height > 0) {
		root->children = alloc_internal_node_group(tree);

		if(!root->children) {
			return 0;
		}

		for(i = 0; i < tree->max_children; i++) {
			if(alloc_tree(tree, &((struct csbpt_internal_node *) root->children)[i], height - 1)) {
				return 1;
			}
		}

		return 0;
	} else if(height == 0) {
		root->children = alloc_leaf_node_group(tree);

		if(!root->children) {
			return 1;
		}

		return 0;
	} else {
		return 0;
	}
}

/*!
 *  Comparison function for sorting int values
 *
 *  \param  pv1  First value; pointer to an int
 *  \param  pv2  Second value; pointer to an int
 *
 *  \retval -1  v1 < v2
 *  \retval  0  v1 == v2
 *  \retval  1  v1 > v2
 */
static int int_cmp(const void *pv1, const void *pv2)
{
	int *v1 = (int *) pv1;
	int *v2 = (int *) pv2;

	return (*v1 > *v2) - (*v1 < *v2);
}

static struct csbpt_internal_node *alloc_tree_bottom_up(struct csbpt *tree, struct csbpt_internal_node *lower_row, int num_lower_elems)
{
	int i, j;
	int num_elems = num_lower_elems / tree->max_children;
	int num_groups = num_elems / tree->max_children;

	struct csbpt_internal_node  *row;
	struct csbpt_internal_node  *ret;

	if(num_elems > 1) {
#ifdef CSBPT_DEBUG
		fprintf(stderr, "Creating row of %d elements in %d groups with first child at %x\n", num_elems, num_groups, lower_row);
#endif

		row = alloc_internal_row(tree, num_elems);
		for(i = 0; i < num_elems; i++) {
#ifdef CSBPT_DEBUG
			fprintf(stderr, "row[%d] = %x\n", i, &row[i]);
#endif
			row[i].children = &lower_row[i * tree->max_children];
		}

		ret = alloc_tree_bottom_up(tree, row, num_elems);
	} else {
		ret = malloc(sizeof(struct csbpt_internal_node));
#ifdef CSBPT_DEBUG
		fprintf(stderr, "Creating a root node of %d elements at %x with first child at %x\n", num_elems, ret, lower_row);
#endif
		ret->children = lower_row;
	}

	return ret;
}

/*!
 *  Bulk loads the provided data into a tree
 *
 *  \param  tree   Tree to load
 *  \param  values Values to load into the tree
 *  \param  count  Number of values to load
 *
 *  \retval 0      Loading succeeded
 *  \retval other  Loading failed
 */
static int bulk_load_tree(struct csbpt *tree, void *values, size_t count, size_t elem_size)
{
	int                          i, j;
	int                          num_leaves;
	int                          num_leaf_groups;
	void                        *tmp_addr;
	struct csbpt_leaf_group    **leaves;
	unsigned char               *elems;
	unsigned char               *a_values = (unsigned char *) values;
	struct csbpt_internal_node  *parents;
	struct csbpt_internal_node  *cur_parent_group;

	num_leaves = (int) pow((double) tree->max_children, (double) tree->height);
	num_leaf_groups = num_leaves / tree->max_children;

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Bulk loading %d values into %d leaf nodes into a tree of height %d and order %d\n", count, num_leaves, tree->height, tree->max_children);
#endif

	/* Create list of measure-elem pairs */
	elems = calloc(count, CSBPT_ELEM_SIZE);
	for(i = 0; i < count; i++) {
		*(elems + i * CSBPT_ELEM_SIZE) = tree->measure(a_values + i * elem_size);
		*((void **) (elems + i * CSBPT_ELEM_SIZE + sizeof(int))) = a_values + i * elem_size;
	}

	qsort(elems, count, CSBPT_ELEM_SIZE, &int_cmp);

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Sorted measurements: [");
	for(i = 0; i < count; i++) {
		fprintf(stderr, "%d:%x%s", *((int *)(elems + i * CSBPT_ELEM_SIZE)), *((void **)(elems + i * CSBPT_ELEM_SIZE + sizeof(int))), i == count - 1 ? "]\n" : ", ");
	}
#endif

	/* Allocate leaf nodes and copy values */
	leaves = calloc(num_leaf_groups, sizeof(struct csbpt_leaf_group *));
	parents = alloc_internal_row(tree, num_leaf_groups);
	for(i = 0; i < num_leaf_groups; i++) {
		leaves[i] = alloc_leaf_node_group(tree);

		if(!leaves[i]) {
			return 1;
		}

		parents[i].children = leaves[i];

		if(i > 0) {
			leaves[i]->prev = leaves[i - 1];
			leaves[i - 1]->next = leaves[i];
		}

		if(i < count / tree->max_children) {
			leaves[i]->num_elems = tree->max_children;
		} else if(i == count / tree->max_children) {
			leaves[i]->num_elems = count % tree->max_children;
		} else {
			leaves[i]->num_elems = 0;
		}

#ifdef CSBPT_DEBUG
		fprintf(stderr, "Copying over %d data elements at offset %d to addr %x[%x]\n", leaves[i]->num_elems, i * tree->max_children * CSBPT_ELEM_SIZE, ((unsigned char *) leaves[i]) + sizeof(struct csbpt_leaf_group), leaves[i]);
#endif
		memcpy(((unsigned char *) leaves[i]) + sizeof(struct csbpt_leaf_group), elems + i * tree->max_children * CSBPT_ELEM_SIZE, leaves[i]->num_elems * CSBPT_ELEM_SIZE);

		parents[i].num_keys = leaves[i]->num_elems;
		parents[i].keys = malloc(sizeof(int));
		for(j = 0; j < leaves[i]->num_elems; j++) {
			parents[i].keys[j] = *((int *) (((unsigned char *) leaves[i]) + sizeof(struct csbpt_leaf_group) + j * CSBPT_ELEM_SIZE));
		}
	}

	if(tree->height == 1) {
		tree->root = parents;
	} else {
		tree->root = alloc_tree_bottom_up(tree, parents, num_leaf_groups);
	}

	return 0;
}

/*
 *  Public functions
 */

struct csbpt *csbpt_create(struct csbpt_tune *tune,
                           csbpt_measure_fn *measure,
                           void *initial_values, size_t initial_value_count, size_t initial_value_elem_size)
{
	struct csbpt *tree = NULL;

	tree = malloc(sizeof(struct csbpt));

	if(!tree) {
		goto csbpt_create_error;
	}

	tree->measure = measure;
	tree->min_children = tune->order;
	if(tree->min_children <= 0) {
		tree->min_children = 1;
	}
	tree->max_children = 2 * tree->min_children;

#ifdef CSBPT_DEBUG
	tree->bytes_used = 0;
#endif

	if(initial_value_count > 0) {
		tree->height = calc_required_height(tree->max_children, initial_value_count);

		if(tune->initial_height > tree->height) {
			tree->height = tune->initial_height;
		}
	} else {
		tree->height = tune->initial_height;
	}

	if(tree->height == 0){
		tree->height = 1;
	}

	tree->root = calloc(1, sizeof(struct csbpt_internal_node));

	if(initial_value_count > 0) {
		bulk_load_tree(tree, initial_values, initial_value_count, initial_value_elem_size);
	} else {

		if(!tree->root) {
			goto csbpt_create_error;
		}

#ifdef CSBPT_DEBUG
		fprintf(stderr, "Creating tree of height %d, min children %d, and max children %d\n", tree->height, tree->min_children, tree->max_children);
#endif

		if(alloc_tree(tree, tree->root, tree->height - 1)) {
			goto csbpt_create_error;
		}
	}

#ifdef CSBPT_DEBUG
	fprintf(stderr, "Tree's memory footprint is %d bytes (not including data)\n", tree->bytes_used);
#endif

	goto csbpt_create_exit;

csbpt_create_error:
	if(tree) {
		csbpt_release(tree);
		tree = NULL;
	}

csbpt_create_exit:
	return tree;
}


int csbpt_release(struct csbpt *tree)
{
#ifdef CSBPT_DEBUG
	fprintf(stderr, "Destroying tree\n");
#endif

	free(tree);

	return 0;
}

#ifdef CSBPT_DEBUG

static int csbpt_dump_dot_node(struct csbpt *tree, int level, void *node, FILE *file)
{
	int i;
	struct csbpt_internal_node *internal_node;
	struct csbpt_leaf_group    *leaf_node;
	void                       *child;

	fprintf(stderr, "Processing node %x in row %d of %d\n", node, level, tree->height);

	if(level < tree->height) {
		internal_node = (struct csbpt_internal_node *) node;
		fprintf(file, "\t\"%x\" [label=\"", node);
		for(i = 0; i < internal_node->num_keys; i++) {
			fprintf(file, "%d", internal_node->keys[i]);
			if(i != internal_node->num_keys - 1) {
				fprintf(file, ",");
			}
		}
		fprintf(file, "\", shape=record];\n");
		if(level + 1 == tree->height) {
			fprintf(stderr, "Reading leaf data of node %x starting from address %x[%x]\n", node, ((unsigned char *) (struct csbpt_leaf_group *) internal_node->children) + sizeof(struct csbpt_leaf_group), internal_node->children);
			child = internal_node->children;
			fprintf(file, "\t\"%x\" -> \"%x\";\n", node, child);
			if(csbpt_dump_dot_node(tree, level + 1, child, file)) {
				return 1;
			}
		} else {
			for(i = 0; i < tree->max_children; i++) {
				child = ((struct csbpt_internal_node *) internal_node->children) + i;
				fprintf(file, "\t\"%x\" -> \"%x\";\n", node, child);
				if(csbpt_dump_dot_node(tree, level + 1, child, file)) {
					return 1;
				}
			}
		}

		return 0;
	} else if(level == tree->height) {
		leaf_node = (struct csbpt_leaf_group *) node;

		if(leaf_node->num_elems > 0) {
			fprintf(file, "\t\"%x\" [label=\"{", node);
			for(i = 0; i < leaf_node->num_elems; i++) {
				fprintf(file, "%d", *((int *) (((unsigned char *) node) + sizeof(struct csbpt_leaf_group) + i * CSBPT_ELEM_SIZE)));
				if(i != leaf_node->num_elems - 1) {
					fprintf(file, "|");
				}
			}
			fprintf(file, "}\", shape=record];\n");
		} else {
			fprintf(file, "\n\"%x\" [label=\"\", shape=record];\n", node);
		}

		return 0;
	} else {
		return 0;
	}
}

int csbpt_dump_dot(struct csbpt *tree, FILE *file)
{
	fprintf(file, "digraph G {\n");

	fprintf(stderr, "Tree root is %x\n", tree->root);
	if(csbpt_dump_dot_node(tree, 0, tree->root, file)) {
		return 1;
	}

	fprintf(file, "}\n");

	return 0;
}
#endif
