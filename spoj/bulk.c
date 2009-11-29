/*! \file bulk.c
 *
 * \section Problem
 *
 * ACM uses a new special technology of building its transceiver stations. This technology is called Modular
 * Cuboid Architecture (MCA) and is covered by a patent of Lego company. All parts of the transceiver are
 * shipped in unit blocks that have the form of cubes of exactly the same size. The cubes can be then
 * connected to each other. The MCA is modular architecture, that means we can select preferred transceiver
 * configuration and buy only those components we need .
 *
 * The cubes must be always connected "face-to-face", i.e. the whole side of one cube is connected to the
 * whole side of another cube. One cube can be thus connected to at most six other units. The resulting
 * equipment, consisting of unit cubes is called The Bulk in the communication technology slang.
 *
 * Sometimes, an old and unneeded bulk is condemned, put into a storage place, and replaced with a new one.
 * It was recently found that ACM has many of such old bulks that just occupy space and are no longer needed.
 * The director has decided that all such bulks must be disassembled to single pieces to save some space.
 * Unfortunately, there is no documentation for the old bulks and nobody knows the exact number of pieces
 * that form them. You are to write a computer program that takes the bulk description and computes the
 * number of unit cubes.
 *
 * Each bulk is described by its faces (sides). A special X-ray based machine was constructed that is able to
 * localise all faces of the bulk in the space, even the inner faces, because the bulk can be partially
 * hollow (it can contain empty spaces inside). But any bulk must be connected (i.e. it cannot drop into
 * two pieces) and composed of whole unit cubes.
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*!
 * Struct to hold info on a line which varies only in the Y direction.
 */
struct line {
	int z;   /*!< Z coordinate */
	int lower_variant;
	int upper_variant;
	int invariant;
};

struct plane {
	int z;
	int height;

	struct line *horiz_lines;
	int num_horiz_lines;
	int horiz_pos;
	int horiz_crossings;

	struct line *vert_lines;
	int num_vert_lines;
	int vert_pos;
	int vert_crossings;
};

int            horiz_line_capacity   = 10;   /*!< Number of lines allocated */
struct line   *horiz_lines;                  /*!< All lines which vary only by y */
int            num_horiz_lines;              /*!< Number of lines in current test case */

int            vert_line_capacity = 10;
struct line   *vert_lines;
int            num_vert_lines;

int            num_relevant_xs;
bool           relevant_x_bools[1001];
int           *relevant_xs;

int            num_relevant_ys;
bool           relevant_y_bools[1001];
int           *relevant_ys;

int            num_planes;
bool           plane_bools[1001];
struct plane  *planes;

/*!
 * Comparator used to sort the lines first by z, then by x, and finally by y.
 */
static int compare_lines(const void *l1p, const void *l2p) {
	const struct line *l1 = (const struct line *) l1p;
	const struct line *l2 = (const struct line *) l2p;

	/* Sort first by Z */
	if(l1->z > l2->z) {
		return 1;
	} else if(l1->z < l2->z) {
		return -1;
	}

	/* Sort next by X */
	if(l1->invariant > l2->invariant) {
		return 1;
	} else if(l1->invariant < l2->invariant) {
		return -1;
	}

	/* Then by Y1 */
	if(l1->lower_variant > l2->lower_variant) {
		return 1;
	} else if(l1->lower_variant < l2->lower_variant) {
		return -1;
	}

	/* Finally by Y2 */
	if(l1->upper_variant > l2->upper_variant) {
		return 1;
	} else if(l1->upper_variant < l2->upper_variant) {
		return -1;
	}

	/* Must be the same */
	return 0;
}

/*!
 * Adds the line if it is parallel to the Y axis
 */
void maybe_add_line(int x1, int y1, int z1, int x2, int y2, int z2) {
	if((x1 == x2 && z1 == z2 && y1 != y2) ||
	   (x1 != x2 && z2 == z2 && y1 == y2)) {

		if(!relevant_x_bools[x1]) {
			relevant_x_bools[x1] = true;
			num_relevant_xs++;
		}

		if(!relevant_x_bools[x2]) {
			relevant_x_bools[x2] = true;
			num_relevant_xs++;
		}

		if(!relevant_y_bools[y1]) {
			relevant_y_bools[y1] = true;
			num_relevant_ys++;
		}

		if(!relevant_y_bools[y2]) {
			relevant_y_bools[y2] = true;
			num_relevant_ys++;
		}

		if(!plane_bools[z1]) {
			plane_bools[z1] = true;
			num_planes++;
		}

		//fprintf(stderr, "(%2d, %2d, %2d) -> (%2d, %2d, %2d)\n", x1, y1, z1, x2, y2, z2);
		if(x1 == x2) {
			if(num_vert_lines + 1 > vert_line_capacity) {
				vert_line_capacity *= 2.0;
				vert_lines = realloc(vert_lines, vert_line_capacity * sizeof(struct line));
			}
			vert_lines[num_vert_lines].invariant = x1;
			vert_lines[num_vert_lines].lower_variant = y1 < y2 ? y1 : y2;
			vert_lines[num_vert_lines].upper_variant = y1 < y2 ? y2 : y1;
			vert_lines[num_vert_lines].z = z1;
			num_vert_lines++;
		} else {
			if(num_horiz_lines + 1 > horiz_line_capacity) {
				horiz_line_capacity *= 2.0;
				horiz_lines = realloc(horiz_lines, horiz_line_capacity * sizeof(struct line));
			}
			horiz_lines[num_horiz_lines].invariant = y1;
			horiz_lines[num_horiz_lines].lower_variant = x1 < x2 ? x1 : x2;
			horiz_lines[num_horiz_lines].upper_variant = x1 < x2 ? x2 : x1;
			horiz_lines[num_horiz_lines].z = z1;
			num_horiz_lines++;
		}
	}
}

static void do_test_case(FILE *input, int num) {
#ifdef BULK_DUMP_OBJ
	char *filename = malloc(13);
	snprintf(filename, 13, "bulk_%03d.obj", num);
	FILE *obj_file = fopen(filename, "w+");
	free(filename);
#endif

	//	fprintf(stderr, "Doing test case...\n");
	num_vert_lines = 0;
	num_horiz_lines = 0;
	num_relevant_xs = 0;
	num_relevant_ys = 0;
	num_planes = 0;
	memset(relevant_x_bools, 0, 1001 * sizeof(bool));
	memset(relevant_y_bools, 0, 1001 * sizeof(bool));
	memset(plane_bools, 0, 1001 * sizeof(bool));

	/* Read in all lines with variance in y */
	int num_faces;
	fscanf(input, "%d", &num_faces);

#ifdef BULK_DUMP_OBJ
	int *num_face_vertices = malloc(num_faces * sizeof(int));
#endif

	for(int i = 0; i < num_faces; i++) {

		int num_vertices;
		fscanf(input, "%d", &num_vertices);

		int *face_coords = malloc(num_vertices * 3 * sizeof(int));
#ifdef BULK_DUMP_OBJ
		num_face_vertices[i] = num_vertices;
#endif
		for(int j = 0; j < num_vertices; j++) {
			fscanf(input, "%d %d %d", face_coords + j * 3, face_coords + j * 3 + 1, face_coords + j * 3 + 2);
#ifdef BULK_DUMP_OBJ
			fprintf(obj_file, "v %d %d %d\n", face_coords[j * 3], face_coords[j * 3 + 1], face_coords[j * 3 + 2]);
#endif
		}

		for(int j = 1; j < num_vertices; j++) {
			/*fprintf(stderr, "Eval: %d == %d, %d = %d, %d != %d\n", 
					face_coords[j * 3], face_coords[(j - 1) * 3],
					face_coords[j * 3 + 1], face_coords[(j - 1) * 3 + 1],
					face_coords[j * 3 + 2], face_coords[(j - 1) * 3 + 2]);*/

			if(face_coords[j * 3] == face_coords[(j - 1) * 3] &&
			   face_coords[j * 3 + 1] == face_coords[(j - 1) * 3 + 1] &&
			   face_coords[j * 3 + 2] != face_coords[(j - 1) * 3 + 2]) {

				//fprintf(stderr, "Appears to be not on the X-Y plane, using\n");

				for(int k = 1; k < num_vertices; k++) {
					maybe_add_line(face_coords[k * 3], face_coords[k * 3 + 1], face_coords[k * 3 + 2],
								   face_coords[(k - 1) * 3], face_coords[(k - 1) * 3 + 1], face_coords[(k - 1) * 3 + 2]);
				}

				maybe_add_line(face_coords[0], face_coords[1], face_coords[2],
							   face_coords[num_vertices * 3 - 3], face_coords[num_vertices * 3 - 2], face_coords[num_vertices * 3 - 1]);

				break;
			}
		}
		free(face_coords);
	}

#ifdef BULK_DUMP_OBJ
	int cur_vert = 1;
	for(int i = 0; i < num_faces; i++) {
		fprintf(obj_file, "f ");
		for(int j = 0; j < num_face_vertices[i]; j++) {
			fprintf(obj_file, "%d ", cur_vert++);
		}
		fprintf(obj_file, "\n");
	}
	fclose(obj_file);
#endif

	relevant_xs = malloc(num_relevant_xs * sizeof(int));
	relevant_ys = malloc(num_relevant_ys * sizeof(int));
	planes = malloc(num_planes * sizeof(struct plane));

	int cur_relevant_x = 0;
	int cur_relevant_y = 0;
	for(int i = 0; i < 1001; i++) {
		if(relevant_x_bools[i]) {
			relevant_xs[cur_relevant_x++] = i;
		}
		if(relevant_y_bools[i]) {
			relevant_ys[cur_relevant_y++] = i;
		}
	}

	/*
	fprintf(stderr, "%d relevant x's: [", num_relevant_xs);
	for(int i = 0; i < num_relevant_xs; i++) {
		fprintf(stderr, " %d ", relevant_xs[i]);
	}
	fprintf(stderr, "]\n");

	fprintf(stderr, "%d relevant y's: [", num_relevant_ys);
	for(int i = 0; i < num_relevant_ys; i++) {
		fprintf(stderr, " %d ", relevant_ys[i]);
	}
	fprintf(stderr, "]\n\n");
	*/
	qsort(horiz_lines, num_horiz_lines, sizeof(struct line), &compare_lines);
	qsort(vert_lines, num_vert_lines, sizeof(struct line), &compare_lines);

	int cur_horiz_line = 0;
	int cur_vert_line = 0;
	int cur_plane = 0;
	for(int i = 0; i < 1001; i++) {
		if(plane_bools[i]) {
			planes[cur_plane].z = i;
			planes[cur_plane].horiz_lines = horiz_lines + cur_horiz_line;
			int horiz_start = cur_horiz_line;
			while(cur_horiz_line < num_horiz_lines && horiz_lines[cur_horiz_line].z == i) {
				cur_horiz_line++;
			}
			planes[cur_plane].num_horiz_lines = cur_horiz_line - horiz_start;

			planes[cur_plane].vert_lines = vert_lines + cur_vert_line;
			int vert_start = cur_vert_line;
			while(cur_vert_line < num_vert_lines && vert_lines[cur_vert_line].z == i) {
				cur_vert_line++;
			}
			planes[cur_plane].num_vert_lines = cur_vert_line - vert_start;

			planes[cur_plane].height = 0;
			if(cur_plane > 0) {
				planes[cur_plane - 1].height = i - planes[cur_plane - 1].z;
			}

			planes[cur_plane].vert_pos = 0;
			planes[cur_plane].horiz_pos = 0;
			planes[cur_plane].vert_crossings = 0;
			planes[cur_plane].horiz_crossings = 0;

			/*
			fprintf(stderr, "Plane at z = %d w/ height %d has %d horizontal lines and %d vertical ones:\n", planes[cur_plane].z, planes[cur_plane].height, planes[cur_plane].num_horiz_lines, planes[cur_plane].num_vert_lines);
			fprintf(stderr, "Horizontal Lines:\n");
			for(int j = 0; j < planes[cur_plane].num_horiz_lines; j++) {
				fprintf(stderr, "(%2d, %2d) -> (%2d, %2d)\n",
						planes[cur_plane].horiz_lines[j].lower_variant,
						planes[cur_plane].horiz_lines[j].invariant,
						planes[cur_plane].horiz_lines[j].upper_variant,
						planes[cur_plane].horiz_lines[j].invariant);
			}
			fprintf(stderr, "Vertical Lines:\n");
			for(int j = 0; j < planes[cur_plane].num_vert_lines; j++) {
				fprintf(stderr, "(%2d, %2d) -> (%2d, %2d)\n",
						planes[cur_plane].vert_lines[j].invariant,
						planes[cur_plane].vert_lines[j].lower_variant,
						planes[cur_plane].vert_lines[j].invariant,
						planes[cur_plane].vert_lines[j].upper_variant);
			}
			*/

			cur_plane++;
		}
	}

	int volume = 0;
	for(int i = 0; i < num_relevant_ys - 1; i++) {
		for(int j = 0; j < num_relevant_xs - 1; j++) {
			for(int k = 0; k < num_planes; k++) {
				planes[k].horiz_pos = 0;
				planes[k].horiz_crossings = 0;
				planes[k].vert_pos = 0;
				planes[k].vert_crossings = 0;
			}

			int x1 = relevant_xs[j]; int x2 = relevant_xs[j + 1];
			int y1 = relevant_ys[i]; int y2 = relevant_ys[i + 1];
			int area = (x2 - x1) * (y2 - y1);
			int stack_height = 0;

			bool includePlane = false;
			for(int k = 0; k < num_planes; k++) {
				struct plane *p = planes + k;

				/*
				//				fprintf(stderr, "Vert pos @ z = %d is %d\n", p->z, p->vert_pos);
				for(int i = p->horiz_pos; i < p->num_horiz_lines; i++) {
					struct line *h = p->horiz_lines + i;

					//fprintf(stderr, "Checking h line stretching from (%d) to (%d) at %d\n", h->lower_variant, h->upper_variant, h->invariant);

					if(h->lower_variant > x2) {
						break;
					}

					if(h->invariant < y2 && h->lower_variant <= x1 && h->upper_variant >= x2) {
						p->horiz_crossings++;
						p->horiz_pos = i + 1;
						//fprintf(stderr, "Crossed line from (%d, %d) -> (%d, %d), h => %d\n",
						//h->lower_variant, h->invariant, h->upper_variant, h->invariant, p->horiz_crossings);
					} else if(h->upper_variant <= x1) {
						p->horiz_pos = i + 1;
					}
				}

				//fprintf(stderr, "Vert pos @ z = %d is %d\n", p->z, p->vert_pos);
				for(int i = p->vert_pos; i < p->num_vert_lines; i++) {
					struct line *v = p->vert_lines + i;

					//fprintf(stderr, "Checking v line stretching from (%d) to (%d) at %d\n", v->lower_variant, v->upper_variant, v->invariant);

					if(v->lower_variant > y2) {
						break;
					}

					if(v->invariant < x2 && v->lower_variant <= y1 && v->upper_variant >= y2) {
						p->vert_crossings++;
						p->vert_pos = i + 1;
						//fprintf(stderr, "Crossed line from (%d, %d) -> (%d, %d), v => %d\n",
					    // v->invariant, v->lower_variant, v->invariant, v->upper_variant, p->vert_crossings);
					} else if(v->upper_variant <= y1) {
						p->vert_pos = i + 1;
					}
				}*/

				p->horiz_crossings = 0;
				for(int l = 0; l < p->num_horiz_lines; l++) {
					struct line *h = p->horiz_lines + l;
					if(h->invariant < y2 && h->lower_variant <= x1 && h->upper_variant >= x2) {
						p->horiz_crossings++;
					}
				}

				p->vert_crossings = 0;
				for(int l = 0; l < p->num_vert_lines; l++) {
					struct line *v = p->vert_lines + l;

					if(v->invariant < x2 && v->lower_variant <= y1 && v->upper_variant >= y2) {
						p->vert_crossings++;
					}
				}

				if(p->horiz_crossings % 2 && p->vert_crossings % 2) {
					includePlane = !includePlane;
				}

				//fprintf(stderr, "At z = %d, height = %d, h = %d, v = %d, including? %s, volume += %d\n", p->z, p->height, p->horiz_crossings, p->vert_crossings, includePlane ? "yes" : "no", area * p->height);

				if(includePlane) {
					volume += area * p->height;
					stack_height += area * p->height;
				}
			}

			//fprintf(stderr, "Calculated volume from (%d, %d) -> (%d, %d) w/ area %d to be %d\n\n", x1, y1, x2, y2, area, stack_height);
		}
	}

	printf("The bulk is composed of %d units.\n", volume);
	free(relevant_xs);
	free(relevant_ys);
	free(planes);
}

int main(int argc, char** argv) {
	FILE *input = stdin;

	vert_lines = malloc(vert_line_capacity * sizeof(struct line));
	horiz_lines = malloc(horiz_line_capacity * sizeof(struct line));

	int num_test_cases;
	fscanf(input, "%d", &num_test_cases);
	for(int i = 0; i < num_test_cases; i++) {
		do_test_case(input, i);
	}

	free(horiz_lines);
	free(vert_lines);
	return 0;
}
