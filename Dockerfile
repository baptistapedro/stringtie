FROM fuzzers/afl:2.52 as builder

RUN apt-get update
RUN apt install -y build-essential wget git curl clang cmake  automake autotools-dev  libtool zlib1g zlib1g-dev libexif-dev
ADD . /stringtie
WORKDIR /stringtie
RUN rm -rf /stringtie/tests
RUN wget https://github.com/gpertea/stringtie/raw/test_data/tests.tar.gz
RUN tar xvfz tests.tar.gz
RUN make CC=afl-gcc CXX=afl-g++
RUN mkdir /bam_corpus
RUN mv ./tests/*.bam /bam_corpus/
RUN rm -f /bam_corpus/mix_short.bam
RUN rm -f /bam_corpus/short_reads_and_superreads.bam

FROM fuzzers/afl:2.52
COPY --from=builder /stringtie/stringtie /
COPY --from=builder /bam_corpus/*.bam /testsuite/

ENTRYPOINT ["afl-fuzz", "-i", "/testsuite", "-o", "/stringtieOut"]
CMD ["/stringtie", "-o", "out.gtf", "@@"]
