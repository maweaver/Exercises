#ifndef MIX_STDLIB
#define MIX_STDLIB

#define MIX_TAPE_MIN      0
#define MIX_TAPE_MAX      7
#define MIX_DISK_MIN      8
#define MIX_DISK_MAX     15
#define MIX_CARD_READER  16
#define MIX_CARD_PUNCH   17
#define MIX_PRINTER      18
#define MIX_TYPEWRITER   19
#define MIX_PAPER        20

void mix_io_init();

void mix_io_destroy();

void mix_tape_wind(int device, int blocks);

void mix_disk_position(int device);

void mix_printer_page_break();

void mix_paper_rewind();

char *mix_str_to_ascii(const char *str, int len);

char *mix_ascii_to_str(const char *ascii);

int mix_int_to_word(int num);

#endif
