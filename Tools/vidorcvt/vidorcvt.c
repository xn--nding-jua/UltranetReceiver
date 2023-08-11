#include <stdio.h>
int main(int argc, char *argv[])
{
  // For simplicity, we just read stdin and produce stdout. Redirect, Luke!
  unsigned int mask1;
  unsigned int mask2;
  int i=0;
  while (!feof(stdin))
    {
      int n,o;
      if (scanf("%d,",&n)!=1) break;
      mask2=0x80;
      // If you don't like this brute force reverse, there are many other ways:
      // http://graphics.stanford.edu/~seander/bithacks.html#BitReverseObvious
      o=0;
      for (mask1=1;mask1<=0x80;mask1<<=1)
	{
	  if (n&mask1) o|=mask2;
	  mask2>>=1;
	}
      printf("%d,",o);
      if (++i==16)
	{
	  putchar('\n');
	  i=0;
	}
    }
  printf("\n");
}