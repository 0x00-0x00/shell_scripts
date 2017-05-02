#include <stdio.h>
#include <unistd.h>
#include <errno.h>
#include <stdlib.h>


int main(int argc, char* argv[])
{
    int user_id, return_code;
    user_id = geteuid();
    if (user_id != 0) {
        fprintf(stderr, "Not enough privileges to run this program.\n");
        exit(1);
    }

    return_code = system("iptables -P INPUT ACCEPT; iptables -P OUTPUT ACCEPT; iptables -P FORWARD ACCEPT; iptables -F");
    if ( return_code != 0 ) {
        fprintf(stdout, "ERROR: Could not free the iptables rules.\n");
        exit(1);
    }
    fprintf(stdout, "IPTables ruleset was successfully cleansed.\n");
    return 0;
}
