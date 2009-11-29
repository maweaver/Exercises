#include <stdio.h>
#include <stdlib.h>

#include <mixstdlib.h>

static FILE **io_files;

void mix_io_init() {
	io_files = calloc(21, sizeof(FILE *));
	io_files[MIX_PRINTER] = stderr;
	io_files[MIX_TYPEWRITER] = stdout;
	io_files[MIX_PAPER] = stdin;
}

void mix_io_destroy() {
	free(io_files);
}


void mix_ioc(int device, int operation) {
	if(device <= MIX_TAPE_MAX) {
		mix_tape_wind(device, operation);
	} else if(device <= MIX_DISK_MAX) {
		mix_disk_position(operation);
	} else if(device == MIX_PRINTER) {
		mix_printer_page_break();
	} else if(device == MIX_PAPER) {
		mix_paper_rewind();
	}
}

void mix_in() {
}

void mix_out(int device, int *words, int block_size) {
	if(!io_files[device]) {
		return;
	}

	if(device > 15) {
		// Text mode
		for(int i = 0; i < block_size; i++) {
			int word = words[i];
			char str[5];
			str[0] = (word >> (6 * 4)) & 0x3F;
			str[1] = (word >> (6 * 3)) & 0x3F;
			str[2] = (word >> (6 * 2)) & 0x3F;
			str[3] = (word >> (6 * 1)) & 0x3F;
			str[4] = (word >> (6 * 0)) & 0x3F;
			char *ascii = mix_str_to_ascii(str, 5);
			fprintf(io_files[device], ascii);
			free(ascii);
		}
	} else {
		// Binary mode
	}
}

void mix_tape_wind(int device, int blocks) {
	if(!io_files[device]) {
		return;
	}

	if(!blocks) {
		fseek(io_files[device], 0, SEEK_SET);
	} else {
		fseek(io_files[device], 100 * blocks, SEEK_CUR);
	}
}

void mix_disk_position(int device) {
}

void mix_printer_page_break() {
	fputc(0xC, io_files[MIX_PRINTER]);
}

void mix_paper_rewind() {
	fputc('\r', io_files[MIX_PAPER]);
}
