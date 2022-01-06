#include <stdio.h>
#include <stdlib.h>

#include <time.h>

int main(int argc, char **argv)
{
  int ret = 0;
  struct timespec ts0, ts2;

  ret = clock_gettime(CLOCK_REALTIME, &ts0);
  printf("%10ld.%09ld\n", ts0.tv_sec, ts0.tv_nsec);
  return 0;
}


