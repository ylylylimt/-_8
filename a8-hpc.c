# include <stdio.h>
# include <unistd.h>
# include <math.h>
# include <float.h>
# include <limits.h>
# include <sys/time.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

#ifndef STREAM_ARRAY_SIZE
#   define STREAM_ARRAY_SIZE	75000000
#endif

#ifndef NTIMES
#   define NTIMES	20
#endif

double mysecond();

int main() {
 
    double *avgtime = (double *)malloc(4 * sizeof(double));
    for (int r = 0; r < 4; r++) {
        avgtime[r] = 0.0;
    }


    double *maxtime = (double *)malloc(4 * sizeof(double));
    for (int p = 0; p < 4; p++) {
        maxtime[p] = 0.0;
    }

    double *mintime = (double *)malloc(4 * sizeof(double));
    for (int h = 0; h < 4; h++) {
        mintime[h] = FLT_MAX;
    }
    
    const char *labels[] = {"Copy:      ", "Scale:     ", "Add:       ", "Triad:     "};
    char **label = (char **)malloc(4 * sizeof(char *));

    for (int i = 0; i < 4; ++i) {
        label[i] = (char *)malloc(strlen(labels[i]) + 1);
        strcpy(label[i], labels[i]);
    }

	double* bytes = (double*)malloc(4 * sizeof(double) * STREAM_ARRAY_SIZE);

    bytes[0] = 2 * sizeof(double) * STREAM_ARRAY_SIZE;
    bytes[1] = 2 * sizeof(double) * STREAM_ARRAY_SIZE;
    bytes[2] = 3 * sizeof(double) * STREAM_ARRAY_SIZE;
    bytes[3] = 3 * sizeof(double) * STREAM_ARRAY_SIZE;

    int			k;
    ssize_t		j;
    double		q;
    double		t, times[4][NTIMES];
    double *a = malloc(STREAM_ARRAY_SIZE * sizeof(double));
    double *b = malloc(STREAM_ARRAY_SIZE * sizeof(double));
    double *c = malloc(STREAM_ARRAY_SIZE * sizeof(double));
    for (j=0; j<STREAM_ARRAY_SIZE; j++) {
	    a[j] = 1.0;
	    b[j] = 2.0;
	    c[j] = 0.0;
	}

    t = mysecond();

    for (j = 0; j < STREAM_ARRAY_SIZE; j++){
		a[j] = 2.0E0 * a[j];
    	t = 1.0E6 * (mysecond() - t);
	}

    q = 3.0;

    for (k=0; k<NTIMES; k++){
		times[0][k] = mysecond();

		for (j=0; j<STREAM_ARRAY_SIZE; j++){
			c[j] = a[j];
		}

		times[0][k] = mysecond() - times[0][k];
		times[1][k] = mysecond();

		for (j=0; j<STREAM_ARRAY_SIZE; j++){
			b[j] = q*c[j];
		}

		times[1][k] = mysecond() - times[1][k];
		times[2][k] = mysecond();

		for (j=0; j<STREAM_ARRAY_SIZE; j++){
			c[j] = a[j]+b[j];
		}

		times[2][k] = mysecond() - times[2][k];
		times[3][k] = mysecond();

		for (j=0; j<STREAM_ARRAY_SIZE; j++){
			a[j] = b[j]+q*c[j];
		}

		times[3][k] = mysecond() - times[3][k];
	}

    for (k=1; k<NTIMES; k++) {
		for (j=0; j<4; j++){
			avgtime[j] = avgtime[j] + times[j][k];
			mintime[j] = (mintime[j] < times[j][k]) ? mintime[j] : times[j][k];
			maxtime[j] = (maxtime[j] > times[j][k]) ? maxtime[j] : times[j][k];
		}
	}
    printf("Array size = %d (elements).\nEach kernel will be executed %u times.\n", STREAM_ARRAY_SIZE,  NTIMES);
    printf("-------------------------------------------------------------\n");
    printf("%-8s  %13s  %11s  %11s  %11s\n", "Function", "Best Rate MB/s", "Avg time", "Avg time", "Max time");
    for (j=0; j<4; j++) {
		avgtime[j] = avgtime[j]/(double)(NTIMES-1);

		printf("%s%12.1f  %11.6f  %11.6f  %11.6f\n", label[j],
	       1.0E-06 * bytes[j]/mintime[j],
	       avgtime[j],
	       mintime[j],
	       maxtime[j]);
    }
    free(a);
    free(b);
    free(c);
    free(avgtime);
    free(maxtime);
    free(mintime);
    for (int i = 0; i < 4; ++i) {
        free(label[i]);
    }
    free(label);
    free(bytes);
    return 0;
}

double mysecond() {
    struct timespec tp;
    clock_gettime(CLOCK_MONOTONIC, &tp);
    return ((double)tp.tv_sec + (double)tp.tv_nsec * 1.0e-9);
}
