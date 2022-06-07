FROM gcr.io/oss-fuzz-base/base-builder

COPY build.sh $SRC/
COPY *_fuzz_seed_corpus.zip $SRC/

RUN git clone -b fuzzing --depth 1 https://gitlab.com/daniel.zatovic/cryptsetup_fuzzing.git cryptsetup
