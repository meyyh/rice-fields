#include <linux/input.h>
#include <fcntl.h>
#include <stdio.h>
#include <signal.h>
#include <unistd.h>
#include <stdbool.h>

void emit(int fd, int type, int code, int val)
{
    struct input_event ie;
    ie.type = type;
    ie.code = code;
    ie.value = val;

    struct input_event report;
    report.type = EV_SYN;
    report.code = SYN_REPORT;
    report.value = 0;

    write(fd, &ie, sizeof(ie));
    write(fd, &report, sizeof(report));
}

volatile sig_atomic_t should_exit = 0;

void handle_sigusr1(int sig) {
    (void)sig;  
    should_exit = 1;
}

int main(){
    signal(SIGUSR1, handle_sigusr1);
    int fd = open("/dev/input/by-path/platform-i8042-serio-0-event-kbd", O_WRONLY | O_NONBLOCK);
    if (fd < 0)
    {
        printf("%s, fd errors\n");
        return;
    }

    emit(fd, EV_KEY, 133, 1);

    while (1) {
        if (should_exit) {
            break;
        }

        pause();
    }

    emit(fd, EV_KEY, 133, 1);
    close(fd);
}