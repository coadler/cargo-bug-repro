# cargo-bug-repro

In a Dockerfile, when a COPY directive replaces an existing file, `cargo`
still seems to think it's the same file. Only after `touch`ing it does the
cache reset.

See the example Dockerfile:

```Dockerfile
FROM rust:1.51

WORKDIR /src

RUN cargo init
COPY Cargo.toml Cargo.lock ./
RUN cargo build

COPY . .
RUN cargo build
```

```txt
$ docker run -it cargo-bug-broken /bin/bash
root@cbe6d78de04c:/src# ls
Cargo.lock  Cargo.toml	Dockerfile.broken  Dockerfile.fixed  src  target  test.sh

root@cbe6d78de04c:/src# cat src/main.rs
fn main() {
    println!("Goodbye, world!");
}

root@cbe6d78de04c:/src# cargo build
    Finished dev [unoptimized + debuginfo] target(s) in 0.00s

root@cbe6d78de04c:/src# ./target/debug/cargo-bug-repro
Hello, world!

root@cbe6d78de04c:/src# touch src/main.rs

root@cbe6d78de04c:/src# cargo build
   Compiling cargo-bug-repro v0.1.0 (/src)
    Finished dev [unoptimized + debuginfo] target(s) in 0.23s

root@cbe6d78de04c:/src# ./target/debug/cargo-bug-repro
Goodbye, world!

root@cbe6d78de04c:/src#
```

As you can see, touching the file causes the cache to reset. A fixed
Dockerfile looks like this:

```Dockerfile
FROM rust:1.51

WORKDIR /src

RUN cargo init
COPY Cargo.toml Cargo.lock ./
RUN cargo build

COPY . .
RUN touch src/main.rs && cargo build
```

See test.sh for a comparison of running both the broken and fixed
Dockerfiles.
