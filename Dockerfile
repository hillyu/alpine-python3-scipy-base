FROM alpine:latest
ARG USE_MIRROR
ARG alpine_packages="python3 py3-numpy py3-scipy py3-scikit-learn py3-pandas py3-requests py3-pillow"
        #curl ca-certificates python3 py3-numpy py3-numpy-f2py \
        #freetype jpeg libpng libstdc++ libgomp graphviz font-noto \
        #libgomp is openmp implementation TODO: check if it is already installed"
ARG alpine_deps="make automake gcc g++"
ARG python_packages
#pillow depends on cffi
#ARG python_packages="pyyaml pymkl cffi requests pillow"
#ARG python_packages="ipywidgets notebook matplotlib seaborn" # notebook

RUN echo "|--> Updating" \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    && echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||:
RUN echo "|--> Install basics pre-requisites" \
    && apk update && apk upgrade \
    && apk add --no-cache ${alpine_packages}\
    && echo "|--> Install Python basics" \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 --no-cache-dir install --upgrade pip setuptools wheel \
        $([ "$USE_MIRROR" = "true" ] && echo "-i https://pypi.douban.com/simple" ||:)\
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
    && ln -s locale.h /usr/include/xlocale.h \
    && echo "|--> Install build dependencies" \
    && apk add --no-cache --virtual=.build-deps \
        ${alpine_deps}\
    && echo "|--> Install Python packages"; 
RUN if [ ! -z $python_packages]; then pip install -U --no-cache-dir ${python_packages} \
        $([ "$USE_MIRROR" = "true" ] && echo "-i https://pypi.douban.com/simple" ||:); fi\
    && echo "|--> Cleaning" \
    && rm /usr/include/xlocale.h \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/cache/apk/* \
    && find /usr/lib/ -name __pycache__ | xargs rm -r \
    && apk del .build-deps \
    && echo "|--> Done!"
#ENTRYPOINT ["/sbin/tini", "--"]
