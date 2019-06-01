FROM parity/parity:beta as notifier
  
FROM rust:slim as builder

LABEL maintainer="pavelkrolevets@gmail.com"

# install parity dependencies and build parity with secretstore

RUN apt-get update -qq && apt-get install build-essential cmake git libudev-dev -qqy && \
    git clone https://github.com/paritytech/parity && \
    cd parity && \
    git checkout fix_ss_blocking_wait && \
    cargo build --features secretstore --release

FROM ubuntu:latest

COPY --from=builder /parity/target/release/parity /bin/

ENTRYPOINT ["/bin/parity"]
