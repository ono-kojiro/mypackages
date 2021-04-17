#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <errno.h>

#include <getopt.h>

#include <fetch.h>

int main(int argc, char **argv)
{
	int ret = 0;
	/* for getopt_long */
	int c;
	int index;
	
	struct option options[] = {
		{ "help", no_argument, 0, 'h' },
		{ "version", no_argument, 0, 'v' },
		{ "output", required_argument, 0, 'o' },
		{ 0, 0, 0, 0 }
	};

	int i;
	const char *url_str;
	struct url *url;
	fetchIO *io = NULL;
	const char *filename;

	struct url_stat st;
	off_t statsize = 0;
	off_t written = 0;
	ssize_t fetched;
	size_t size;
	size_t wrote;
	char *ptr;

	char buf[4096];

	const char *output = NULL;
	FILE *fp;

	int rate;

	while(1){
		c = getopt_long(argc, argv, "hvo:", options, &index);
		if(c == -1){
			break;
		}
		switch(c){
		case 'h' :
			break;
		case 'v' :
			break;
		case 'o' :
			output = optarg;
			break;
		default :
			break;
		}
	}


	for(i = optind; i < argc; i++){
		url_str = argv[i];
		fprintf(stderr, "%s\n", url_str);

		url = fetchParseURL(url_str);
		if(!url){
			fprintf(stderr, "parse failed, '%s'\n", url_str);
			exit(1);
		}

		io = fetchXGet(url, &st, "");
		if(!io){
			fprintf(stderr, "download error: %s %s\n", url_str,
				fetchLastErrString);
			return -1;
		}

		if(output){
			filename = output;
		}
		else{
			filename = strrchr(url_str, '/');
			if(filename){
				filename++;
			}
			else{
				filename = (const char *)url_str;
			}
		}

		fprintf(stderr, "output : %s\n",filename);

		fp = fopen(filename, "wb");
		if(!fp){
			perror(filename);
			exit(1);
		}

		while(written < st.size){
			rate = (int) written * 100 / st.size;
			fprintf(stderr, "\rwrite %d %%", rate);
			fetched = fetchIO_read(io, buf, sizeof(buf));
			if(fetched == 0){
				break;
			}

			if(fetched < 0 && errno == EINTR){
				continue;
			}

			if(fetched < 0){
				fprintf(stderr, "download error: %s",
					fetchLastErrString);
				return -1;
			}

			statsize += fetched;
			size = (size_t)fetched;

			for(ptr = buf; size > 0; ptr += wrote, size -= wrote){
				wrote = fwrite(ptr, 1, size, fp);
				if(wrote < size){
					if(ferror(fp) && errno == EINTR){
						clearerr(fp);
					}
					else{
						break;
					}
				}

				written += (off_t)wrote;
			}
		}

		fprintf(stderr, "\ndone.\n");

		fetchIO_close(io);
		fetchFreeURL(url);

		fclose(fp);

		if(written != st.size){
			fprintf(stderr, "download error: %s truncated\n", url_str);
			return -1;
		}
	}

	return 0;
}

