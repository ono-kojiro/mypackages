ZIPURL1 = https://www.cisco.com/content/dam/en_us/about/ac50/ac47/doc_jpg.zip
ZIPURL2 = https://www.cisco.com/content/dam/en_us/about/ac50/ac47/3015_jpeg.zip

ZIPFILE1 != basename $(ZIPURL1)
ZIPFILE2 != basename $(ZIPURL2)

all : fetch extract convert

fetch :
	if [ ! -e "$(ZIPFILE1)" ]; then \
        curl -L -O -C - $(ZIPURL1); \
    fi
	if [ ! -e "$(ZIPFILE2)" ]; then \
        curl -L -O -C - $(ZIPURL2); \
    fi

extract :
	mkdir -p orig/doc_jpg
	mkdir -p orig/3015_jpeg
	unzip -n -d orig/doc_jpg $(ZIPFILE1)
	unzip -n -d orig/3015_jpeg $(ZIPFILE2)

convert :
	if [ ! -d "doc_png" ]; then \
	  mkdir -p doc_png; \
	  python3 jpeg2png.py -o doc_png  orig/doc_jpg; \
	fi
	if [ ! -d "3015_png" ]; then \
	  mkdir -p 3015_png; \
	  python3 jpeg2png.py -o 3015_png orig/3015_jpeg; \
	fi

.PHONY : all fetch extract convert
