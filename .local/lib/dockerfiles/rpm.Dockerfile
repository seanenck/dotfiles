FROM fedora:rawhide

RUN dnf update -y && dnf install -y golang go-bindata wget make fedora-packager

ARG OBJECT_VERSION
ARG OBJECT_NAME

ENV OBJECT=${OBJECT_NAME}-${OBJECT_VERSION}
ENV VERSION=${OBJECT_VERSION}

RUN wget https://cgit.voidedtech.com/${OBJECT_NAME}/snapshot/${OBJECT}.tar.gz
RUN tar xf ${OBJECT}.tar.gz
RUN mv ${OBJECT} build/

RUN rpmdev-setuptree
RUN rmdir ~/rpmbuild/BUILD/
COPY rpmbuild/*.spec ~/rpmbuild/SPECS/
RUN mv build/ ~/rpmbuild/BUILD

WORKDIR ~/rpmbuild/SPECS/

RUN rpmbuild -bb *.spec
RUN cp ~/rpmbuild/RPMS/x86_64/*.rpm /rpm/
