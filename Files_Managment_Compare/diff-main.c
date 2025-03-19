#include <assert.h>
#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>
#define BOOL_TO_STR(b) (b) ? "true" : "false"

int my_diff(const char* a, const char* b, bool flag_i, bool flag_B);

static void get_options(int argc, char** argv, bool* flag_i, bool* flag_B) {
    assert(argc >= 3);
    assert(argv);
    assert(flag_i);
    assert(flag_B);

    int option;
    while ((option = getopt(argc - 2, argv + 2, "iB")) != -1)
        switch (option) {
            case 'i':
                *flag_i = true;
                break;
            case 'B':
                *flag_B = true;
                break;
            default:
                break;
        }
}

int main(int argc, char** argv) {
    if (argc < 3) {
        fprintf(stderr, "Usage: %s file1 file2 -flags\n", argv[0]);
        return 1;
    }
    if (access(argv[1], F_OK) != 0) {
        fprintf(stderr, "[ERROR] could not open file \"%s\".\n", argv[1]);
        return 1;
    }
    if (access(argv[2], F_OK) != 0) {
        fprintf(stderr, "[ERROR] could not open file \"%s\".\n", argv[2]);
        return 1;
    }

    bool flag_i = false, flag_B = false;
    get_options(argc, argv, &flag_i, &flag_B);

    printf("calling my_diff(%s, %s, i = %s, B = %s);\n", argv[1],
           argv[2], BOOL_TO_STR(flag_i), BOOL_TO_STR(flag_B));
    return my_diff(argv[1], argv[2], flag_i, flag_B);
}
