FROM ponylang/ponyc:release-alpine AS build

WORKDIR /src/pony-stable

COPY Makefile LICENSE VERSION /src/pony-stable/

WORKDIR /src/pony-stable/tack

COPY tack /src/pony-stable/tack/

WORKDIR /src/pony-stable

RUN make arch=x86-64 static=true linker=bfd \
 && make install

FROM alpine:3.10

COPY --from=build /usr/local/bin/tack /usr/local/bin/tack

CMD tack
