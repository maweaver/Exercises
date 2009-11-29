#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VERTICES 250

#define ADJ(v1, v2) adjacent[(v1) * num_vertices + (v2)]

int num_test_cases;             //<! Number of test cases
int num_edges;                  //<! Number of edges
int num_vertices;               //<! Number of vertices
int num_queries;
int query_size;
int weights[MAX_VERTICES];      //<! Vertex weights
bool adjacent[MAX_VERTICES * MAX_VERTICES - 1];      //<! Flattened adjacency matrix
int num_adjacent[MAX_VERTICES];
int sorted[MAX_VERTICES];       //<! Sorted vertices
int cached_best[MAX_VERTICES];  //<! Best value found for subgraph of i..n
int colors[MAX_VERTICES];       //<! Colors for the vertices
int cur_clique[MAX_VERTICES];   //<! Current clique
int cur_clique_size;            //<! Size of the current clique
int cur_clique_weight;          //<! Weight of the current clique
int best_clique_weight;         //<! Weight of the best clique

int color_comp(const void *pa, const void *pb) {
	int a = *((int *) pa);
	int b = *((int *) pb);

	return (num_adjacent[a] > num_adjacent[b]) - (num_adjacent[a] < num_adjacent[b]);
}

int vertex_comp(const void *pa, const void *pb) {
	int a = *((int *) pa);
	int b = *((int *) pb);

	return colors[a] != colors[b] ?
		(colors[a] > colors[b]) - (colors[a] < colors[b]) :
		(weights[a] < weights[b]) - (weights[a] > weights[b]);
}

/*!
 *  Color vertices
 */
void color() {
	static bool used_colors[MAX_VERTICES];

	for(int i = 0; i < num_vertices; i++) {
		memset(used_colors, 0, sizeof(bool) * num_vertices);
		for(int j = 0; j < num_vertices; j++) {
			if(i != j && ADJ(sorted[i], sorted[j]) && colors[sorted[j]] != -1) {
				used_colors[colors[sorted[j]]] = true;
			}
		}
		
		int cur_color = 0;
		while(used_colors[cur_color]) {
			cur_color++;
		}
		colors[sorted[i]] = cur_color;
	}
}

/*!
 *  Expand each vertex of the given graph against the current clique.
 */
void expand(int *graph, int graph_size, int degree) {
	bool any_expanded = false;

	/* Loop through each vertex in the graph */
	if(cur_clique_weight + degree > best_clique_weight) {
		for(int i = 0; i < graph_size; i++) {
			/* See if it is expandable -- if it is adjacent to all vertices in the clique */
			bool expandable = true;
			for(int j = 0; j < cur_clique_size; j++) {
				if(!ADJ(graph[i], cur_clique[j])) {
					expandable = false;
					break;
				}
			}
			if(expandable) {
				/* Add it to the current clique */
				cur_clique[cur_clique_size++] = graph[i];
				cur_clique_weight += weights[graph[i]];

				if(!cached_best[graph[i]] || cur_clique_weight + cached_best[graph[i]] > best_clique_weight) {
					any_expanded = true;

					/* Build a new graph of all vertices in this graph adjacent to it */
					int *next_graph = malloc(graph_size * sizeof(int));
					int next_graph_size = 0;
					int next_degree = 0;
					for(int j = 0; j < i; j++) {
						if(j != i && ADJ(graph[i], graph[j])) {
							if(next_graph_size == 0 || 
							   colors[graph[j]] != colors[next_graph[next_graph_size - 1]]) {
								next_degree += weights[graph[j]];
							}
							next_graph[next_graph_size++] = graph[j];
						}
					}

					/* Expand the next graph */
					expand(next_graph, next_graph_size, next_degree);
					
					/* Destroy the temporary graph */
					free(next_graph);
				}

				/* Remove it from the current clique */
				cur_clique_size--;
				cur_clique_weight -= weights[graph[i]];

				if(cur_clique_size == 0) {
					cached_best[graph[i]] = best_clique_weight;
				}
			}
		}
	}

	if(!any_expanded && cur_clique_weight > best_clique_weight) {
		best_clique_weight = cur_clique_weight;
		/*		printf("Best clique: [");
		for(int j = 0; j < cur_clique_size; j++) {
			printf(" %d:%d/%d ", colors[cur_clique[j]], cur_clique[j], weights[cur_clique[j]]);
		}
		printf("]\n");*/
	}
}

/*!
 *  Find the maximum clique
 */
void max_clique()
{
	/* Initialize */
	best_clique_weight  = 0;
	cur_clique_size     = 0; 
	cur_clique_weight   = 0;
	memset(cached_best, 0, num_vertices * sizeof(int));

	/* Expand the full graph */
	int * full_graph = malloc(query_size * sizeof(int));
	int degree = 0;
	for(int i = 0; i < query_size; i++) {
		full_graph[i] = sorted[i];
		if(i == 0 || colors[full_graph[i]] != colors[full_graph[i - 1]]) {
			degree += weights[full_graph[i]];
		}
	}
	expand(full_graph, query_size, degree);
}

int main(int argc, char **argv) 
{
	scanf("%d", &num_test_cases);
	for(int i = 0; i < num_test_cases; i++) {

		/* Reset data */
		scanf("%d %d", &num_vertices, &num_edges);
		memset(adjacent, 1, num_vertices * num_vertices - 1);
		memset(num_adjacent, 0, num_vertices * sizeof(int));

		/* Read vertices */
		for(int j = 0; j < num_vertices; j++) {
			scanf("%d", &weights[j]);
			colors[j] = -1;
			sorted[j] = j;
		}

		/* Read edges */
		for(int j = 0; j < num_edges; j++) {
			int v1, v2;		
			scanf("%d %d", &v1, &v2);
			ADJ(v1, v2) = false;
			ADJ(v2, v1) = false;
			num_adjacent[v1]++;
			num_adjacent[v2]++;
		}
		
		/*
		printf("Original vertex set: [");
		for(int j = 0; j < num_vertices; j++) {
			printf(" %d/%d ", j, weights[j]);
		}
		printf("]\n");
		*/

		/* Sort the vertices */
		qsort(sorted, num_vertices, sizeof(int), &color_comp);

		/*
		printf("Pre-colored set: [");
		for(int j = 0; j < num_vertices; j++) {
			printf(" %d/%d ", sorted[j], weights[sorted[j]]);
		}
		printf("]\n");
		*/

		/* Color */
		color();

		scanf("%d", &num_queries);
		for(int j = 0; j < num_queries; j++) {
			scanf("%d", &query_size);

			for(int k = 0; k < query_size; k++) {
				scanf("%d", &sorted[k]);
			}

			/*
			printf("Query vertex set: %d [", query_size);
			for(int j = 0; j < query_size; j++) {
				printf(" %d/%d ", sorted[j], weights[sorted[j]]);
			}
			printf("]\n");
			*/

			/* Resort */
			qsort(sorted, query_size, sizeof(int), &vertex_comp);

			/*
			printf("Sorted query vertex set: [");
			for(int j = 0; j < query_size; j++) {
				printf(" %d:%d/%d ", colors[sorted[j]], sorted[j], weights[sorted[j]]);
			}
			printf("]\n");
			*/

			/* Do the work */
			max_clique();

			/* Show the results */
			printf("%d\n", best_clique_weight);
		}

		if(i != num_test_cases - 1) {
		   printf("\n");
		}
	}

	return 0;
}
