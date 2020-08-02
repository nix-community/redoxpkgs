#include <unistd.h>
#include <stdio.h>

int main() {
    char cwd[1024];
    getcwd(cwd, sizeof(cwd));
    printf("%s\n", cwd);
}