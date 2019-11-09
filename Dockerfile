FROM ponylang/ponyc:release-alpine AS build

WORKDIR /src/pony-stable

COPY Makefile LICENSE VERSION /src/pony-stable/

WORKDIR /src/pony-stable/stable

COPY stable /src/pony-stable/stable/

WORKDIR /src/pony-stable

RUN make arch=x86-64 static=true linker=bfd \
 && make install

FROM alpine:3.10

COPY --from=build /usr/local/bin/stable /usr/local/bin/stable

CMD stable
