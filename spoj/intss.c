#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define UNUSED   0
#define USED     1
#define NEIGHBOR 2

struct vertex {
	int weight;
	int num_edges;
	int *adjacent;
	int state;
};

int vertex_comp(const void *v1p, const void *v2p)
{
	const struct vertex *v1 = (const struct vertex *) v1p;
	const struct vertex *v2 = (const struct vertex *) v2p;

	if(v1->weight < v2->weight) {
		return -1;
	} else if(v1->weight == v2->weight) {
		return 0;
	} else {
		return 1;
	}
}
	
int max_iss_step(struct vertex *vertices, int n, int cur_val, int max_gain, int *included_vertexes, int cur_set_size)
{
	printf("Looking at vertices [");
	for(int i = 0; i < cur_set_size; i++) {
		printf(" %d ", included_vertexes[i]);
	}
	printf("], cur_val = %d, max_gain = %d\n", cur_val, max_gain);
	
	int max_val = cur_val;
	for(int i = 0; i < n; i++) {
		struct vertex *vertex = &vertices[i];
		if(vertex->state == UNUSED) {
			
			int next_max_gain = max_gain;
			vertex->state = USED;
			
			for(int j = 0; j < vertex->num_edges; j++) {
				struct vertex *adj = &vertices[vertex->adjacent[j]];
				if(adj->state == UNUSED) {
					adj->state = NEIGHBOR;
					next_max_gain -= adj->weight;
				}
			}
			
			if(cur_val + next_max_gain > max_val) {
				included_vertexes[cur_set_size] = i;
				int next_val = max_iss_step(vertices, n, cur_val + vertex->weight, next_max_gain - vertex->weight, included_vertexes, cur_set_size + 1);

				if(next_val > max_val) {
					max_val = next_val;
				}
			}
			
			vertex->state = UNUSED;
			for(int j = 0; j < vertices[i].num_edges; j++) {
				struct vertex *adj = &vertices[vertex->adjacent[j]];
				if(adj->state == NEIGHBOR) {
					adj->state = UNUSED;
				}
			}
		}
	}
		
	return max_val;
}
	
int max_iss(struct vertex *vertices, int n)
{
	int *included_vertexes = malloc(n * sizeof(int));
	
	int max_subtree_val = 0;
	for(int i = 0; i < n; i++) {
		max_subtree_val += vertices[i].weight;
	}
	
	int ret = max_iss_step(vertices, n, 0, max_subtree_val, included_vertexes, 0);
	
	free(included_vertexes);
	return ret;
}

void do_test_case() 
{
	int n, k;
	scanf("%d %d", &n, &k);

	struct vertex *vertices = calloc(n, sizeof(struct vertex));
	
	for(int i = 0; i < n; i++) {
		scanf("%d", &vertices[i].weight);
		vertices[i].adjacent = malloc(n * sizeof(int));
	}
	
	for(int i = 0; i < k; i++) {
		int v1, v2;		
		scanf("%d %d", &v1, &v2);
		vertices[v1 - 1].adjacent[vertices[v1 - 1].num_edges++] = v2 - 1;
		vertices[v2 - 1].adjacent[vertices[v2 - 1].num_edges++] = v1 - 1;
	}
	
//	qsort(vertices, n, sizeof(struct vertex), &vertex_comp);
  printf("%d\n", max_iss(vertices, n));

	for(int i = 0; i < n; i++) {
		if(vertices[i].adjacent) {
			free(vertices[i].adjacent);
		}
	}
	free(vertices);
}

int main(int argc, char **argv) {
	#ifdef DATAGEN
	printf("100\n");
	for(int i = 0; i < 100; i++) {
		int n = (rand() % 199) + 2;
		int k = (rand() % (n * (n - 1) / 2)) + 1;
		printf("%d %d\n", n, k);
		for(int j = 0; j < n; j++) {
			printf("%d ", rand() % 100);
		}
		printf("\n");
		for(int j = 0; j < k; j++) {
			printf("%d %d\n", (rand() % n) + 1, (rand() % n) + 1);
		}
		printf("\n");
	}
	#else
	int t;
	scanf("%d", &t);
	
	for(int i = 0; i < t; i++) {
		do_test_case();
	}
	#endif
	
	return 0;
}
