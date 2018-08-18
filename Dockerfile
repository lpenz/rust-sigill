FROM rust:1.27.2

# install debian packages:
ENV DEBIAN_FRONTEND=noninteractive
RUN set -x -e; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        valgrind \
        locales \
        gosu sudo

# setup sudo and locale
RUN set -x -e; \
    echo 'ALL ALL=NOPASSWD:ALL' > /etc/sudoers.d/all; \
    chmod 0400 /etc/sudoers.d/all; \
    echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen; \
    locale-gen
ENV LC_ALL=en_US.UTF-8

# update cargo
COPY Cargo.toml /tmp/Cargo.toml
RUN set -x -e; \
    cd /tmp; \
    mkdir -p src; \
    touch src/main.rs; \
    cargo update; \
    rm -f Cargo.toml

# default commands test everything
CMD set -x -e; \
    cd "$target"; \
    export PATH="/usr/local/cargo/bin:$PATH"; \
    cargo build; \
    valgrind ./target/debug/rust-sigill

# setup entrypoint with user UID/GID from host
RUN set -x -e; \
    (\
    echo '#!/bin/bash'; \
    echo 'MY_UID=${MY_UID:-1000}'; \
    echo 'set -x -e'; \
    echo 'useradd -M -u "$MY_UID" -o user'; \
    echo 'echo export PATH="/usr/local/cargo/bin:$PATH" >> /home/user/.bashrc'; \
    echo 'chown -R user:user /home/user /usr/local/cargo/registry'; \
    echo 'cd /home/user/work'; \
    echo 'exec gosu user "${@:-/bin/bash}"'; \
    ) > /usr/local/bin/entrypoint.sh; \
    chmod a+x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# If your UID is 1000, you can simply run the container as
# docker run -it --rm -v $PWD:/home/user/work ${PWD##*/}
# otherwise, run it as:
# docker run -it --rm -v $PWD:/home/user/work -e MY_UID=$UID  ${PWD##*/}
