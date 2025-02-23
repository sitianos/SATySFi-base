FROM ocaml/opam:ubuntu-22.04-ocaml-4.12 AS satysfi-base

USER root
RUN apt update && apt install -y curl patch unzip make m4 gcc git rsync pkg-config

USER opam
ARG SATYSFI_VERSION=0.0.11
ARG SATYROGRAPHOS_VERSION=0.0.2.13

RUN opam init --no-setup --disable-sandboxing && \
    eval `opam env` && \
    opam repository add satysfi-external https://github.com/gfngfn/satysfi-external-repo.git && \
    opam repository add satyrographos https://github.com/na4zagin3/satyrographos-repo.git

RUN opam update && \
    opam install -y satysfi.${SATYSFI_VERSION} satysfi-dist.${SATYSFI_VERSION} satyrographos.${SATYROGRAPHOS_VERSION}

RUN mkdir /home/opam/work
WORKDIR /home/opam/work

ENTRYPOINT ["opam", "exec", "--"]
CMD ["satysfi"]

FROM satysfi-base AS satysfi-devcontainer

USER root
RUN apt update && apt install -y cargo pdf2svg

USER opam
RUN cd /tmp && \
    git clone https://github.com/monaqa/satysfi-language-server && \
    cd satysfi-language-server && \
    cargo install --path .

ENV PATH=${PATH}:/home/opam/.cargo/bin

FROM satysfi-devcontainer AS satysfi-slide-base

RUN opam update -y \
    && opam install \
        satysfi-algorithm \
        satysfi-bibyfi \
        satysfi-class-slydifi \
        satysfi-code-printer \
        satysfi-colorbox \
        satysfi-easytable \
        satysfi-enumitem \
        satysfi-figbox \
        satysfi-fonts-noto-sans \
        satysfi-fonts-noto-sans-cjk-jp \
        satysfi-fss \
        satysfi-lipsum \
        satysfi-uline \
        satysfi-class-jlreq \
        satysfi-azmath \
    && opam exec -- satyrographos install
