FROM rhub/r-minimal

RUN apk add --no-cache --update-cache \
        --repository http://nl.alpinelinux.org/alpine/v3.11/main \
        autoconf=2.69-r2 \
        automake=1.16.1-r0 && \
    # repeat autoconf and automake (under `-t`)
    # to (auto)remove them after installation
    installr -d \
        -t "libsodium-dev curl-dev linux-headers autoconf automake" \
        -a libsodium \
        shiny

RUN installr -d dplyr
RUN installr -d purrr
RUN installr -d remotes
RUN installr -d magrittr
RUN installr -d yaml

RUN installr -d config
RUN installr -d DT
RUN installr -d -t linux-headers testthat

RUN wget https://github.com/jgm/pandoc/releases/download/2.13/pandoc-2.13-linux-amd64.tar.gz && \
    tar xzf pandoc-2.13-linux-amd64.tar.gz && \
    mv pandoc-2.13/bin/* /usr/local/bin/ && \
    rm -rf pandoc-2.13*

RUN installr -d rmarkdown

RUN installr -t "gfortran g++ curl-dev openssl-dev" \
             -a "libcurl openssl" -d httr2

RUN installr -t "curl-dev openssl-dev libxml2-dev gfortran g++ libgit2" \
    -a "libcurl libgit2-dev libxml2 openssl" golem

RUN mkdir /build_zone
ADD . /build_zone
WORKDIR /build_zone
RUN R -e 'remotes::install_local(upgrade="never")'
RUN rm -rf /build_zone

EXPOSE 3838
CMD R -e "options('shiny.port'=3838,shiny.host='0.0.0.0');R.control::run_app()"
