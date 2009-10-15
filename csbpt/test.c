#include <stdlib.h>

#include "csbpt.h"

static int ordered_ints_measure(void *val)
{
/*	fprintf(stderr, "Asked to measure value %d\n", *((int *) val));*/
	return *((int *) val);
}

static int ordered_ints_action_fn(void *user_data, void *val)
{
	printf("Action called with value %d\n", *((int *) val));
}

int main(int argc, char **argv) {
	int i;
	struct csbpt_tune tune;
	struct csbpt *tree;
	FILE *dot_file;
	int *initial_data;
	const int initial_data_size = 25;

	tune.order = 2;
	tune.initial_height = 0;

	initial_data = calloc(initial_data_size, sizeof(int));
	fprintf(stderr, "Initial values: [");
	for(i = 0; i < initial_data_size; i++) {
		initial_data[i] = rand() % (initial_data_size * 10);
		fprintf(stderr, "%d", initial_data[i]);
		if(i != initial_data_size - 1) {
			fprintf(stderr, ", ");
		} else {
			fprintf(stderr, "]\n");
		}
	}

	tree = csbpt_create(&tune,
			ordered_ints_measure,
			initial_data, initial_data_size, sizeof(int));

	if(!tree) {
		fprintf(stderr, "Error creating tree");
	}


	dot_file = fopen("tree.dot", "w");

	if(csbpt_dump_dot(tree, dot_file)) {
		fprintf(stderr, "Error creating .dot file");
	}

	fclose(dot_file);
}
