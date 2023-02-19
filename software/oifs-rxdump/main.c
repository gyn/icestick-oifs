#include <stdio.h>
#include <unistd.h>
#include <ftdi.h>
#include <signal.h>
#include <sys/time.h>

#define CONFIG_BUFFER_SIZE (1 * 1024 * 1024)

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

    unsigned char *buf = malloc(CONFIG_BUFFER_SIZE);
    if (!buf)
    {
        fprintf(stderr, "Failed to malloc %d bytes\n",
                CONFIG_BUFFER_SIZE);

        goto done;
    }

    uint64_t freebytes = CONFIG_BUFFER_SIZE;

    while (freebytes > 0)
    {
        uint64_t index = CONFIG_BUFFER_SIZE - freebytes;
        ret = ftdi_read_data(ftdi, buf + index, freebytes);
        if (ret < 0)
        {
            fprintf(stderr, "Failed to read data %d (%s)\n",
                    ret, ftdi_get_error_string(ftdi));
        }

        freebytes -= ret;
    }

    printf("Data   : 0x%x Bytes\n", CONFIG_BUFFER_SIZE);
    printf("Buffer :\n");
    for (size_t i = 0; i < CONFIG_BUFFER_SIZE; i++)
    {
        if ((i & 0x0F) == 0x0F)
        {
            printf("%02x\n", buf[i]);
        }
        else
        {
            printf("%02x ", buf[i]);
        }
    }

    free(buf);

done:
    ftdi_usb_close(ftdi);

    ftdi_free(ftdi);

    return 0;
}
