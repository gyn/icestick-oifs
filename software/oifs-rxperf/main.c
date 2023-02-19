#include <stdio.h>
#include <unistd.h>
#include <ftdi.h>
#include <signal.h>
#include <sys/time.h>

#define CONFIG_BUFFER_SIZE 4096

static int exitsignal = 0;

static void sigintHandler(int signum)
{
    (void)signum;

    exitsignal = 1;
}

int main(int argc, char **argv)
{
    int c;
    int vid = 0x0403;
    int pid = 0x6010;
    int interface = INTERFACE_B; // 0=ANY, 1=A, 2=B, 3=C, 4=D

    while ((c = getopt(argc, argv, "i:v:p:")) != -1)
    {
        switch (c)
        {
        case 'i':
            interface = strtoul(optarg, NULL, 0);
            break;
        case 'v':
            vid = strtoul(optarg, NULL, 0);
            break;
        case 'p':
            pid = strtoul(optarg, NULL, 0);
            break;
        default:
            fprintf(stderr,
                    "usage: %s [-i interface] [-v vid] [-p pid]\n", *argv);
            exit(-1);
        }
    }

    printf("Device : vid 0x%0x pid 0x%0x Port %c\n",
           vid, pid, interface - 1 + 'A');

    struct ftdi_version_info version;

    version = ftdi_get_library_version();
    printf("Lib    : libftdi %s.%d-%s\n",
           version.version_str, version.micro, version.snapshot_str);

    struct ftdi_context *ftdi;
    ftdi = ftdi_new();
    if (ftdi == 0)
    {
        fprintf(stderr, "Failed to allocate ftdi structure :%s\n",
                ftdi_get_error_string(ftdi));

        return EXIT_FAILURE;
    }

    ftdi_set_interface(ftdi, interface);

    int ret;
    ret = ftdi_usb_open(ftdi, vid, pid);
    if (ret < 0)
    {
        fprintf(stderr, "Failed to open ftdi device: %d (%s)\n",
                ret, ftdi_get_error_string(ftdi));

        ftdi_free(ftdi);

        return EXIT_FAILURE;
    }

    signal(SIGINT, sigintHandler);

    printf("Perf   : start. Press ctrl + c to stop\n");

    fflush(stdout);

    uint64_t totalbytes = 0;
    unsigned char buf[CONFIG_BUFFER_SIZE];

    struct timeval start;
    gettimeofday(&start, NULL);

    while (!exitsignal)
    {
        ret = ftdi_read_data(ftdi, buf, CONFIG_BUFFER_SIZE * sizeof(char));
        if (ret < 0)
        {
            fprintf(stderr, "Failed to read data %d (%s)\n",
                    ret, ftdi_get_error_string(ftdi));

            usleep(1 * 1000000);

            continue;
        }

        totalbytes += ret;
    }

    struct timeval stop;
    gettimeofday(&stop, NULL);

    uint64_t duration;
    duration = 1000000 * (stop.tv_sec - start.tv_sec) +
               stop.tv_usec - start.tv_usec;

    printf("Result : %lld Bytes / %lld us => %f Bps\n",
           totalbytes, duration, 1000000.0 * totalbytes / duration);

    ftdi_usb_close(ftdi);

    ftdi_free(ftdi);

    return 0;
}
