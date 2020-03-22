FROM alpine:latest
ARG USE_MIRROR
ARG python_packages="pyyaml pymkl cffi scikit-learn  matplotlib pandas pillow"
#RUN echo "|--> Updating" \
    #&& echo http://dl-cdn.alpinelinux.org/alpine/edge/main | tee /etc/apk/repositories \
    #&& echo http://dl-cdn.alpinelinux.org/alpine/edge/testing | tee -a /etc/apk/repositories \
    #&& echo http://dl-cdn.alpinelinux.org/alpine/edge/community | tee -a /etc/apk/repositories
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR";
#RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
RUN echo "|--> Install basics pre-requisites" \
    && apk update && apk upgrade \
    #&& apk add --no-cache tini \
        #curl ca-certificates python3 py3-numpy py3-numpy-f2py \
        #freetype jpeg libpng libstdc++ libgomp graphviz font-noto \
    && apk add --no-cache python3 py3-numpy py3-scipy cython\
    && echo "|--> Install Python basics" \
    && python3 -m ensurepip \
    && rm -r /usr/lib/python*/ensurepip \
    && pip3 --no-cache-dir install --upgrade pip setuptools wheel -i https://pypi.douban.com/simple \
    && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi \
    && if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi \
    && ln -s locale.h /usr/include/xlocale.h \
    && echo "|--> Install build dependencies" \
    && apk add --no-cache --virtual=.build-deps \
        build-base linux-headers python3-dev git cmake jpeg-dev bash \
        libffi-dev gfortran openblas-dev py3-numpy-dev freetype-dev libpng-dev \
    && echo "|--> Install Python packages"; 
RUN [ "$USE_MIRROR" = "true" ] && pip install -U --no-cache-dir ${python_packages} -i https://pypi.douban.com/simple||pip install -U --no-cache-dir ${python_packages}
#ipywidgets notebook requests seaborn 
RUN echo "|--> Cleaning" \
    && rm /usr/include/xlocale.h \
    && rm -rf /root/.cache \
    && rm -rf /root/.[acpw]* \
    && rm -rf /var/cache/apk/* \
    && find /usr/lib/ -name __pycache__ | xargs rm -r \
    && apk del .build-deps \
    #&& echo "|--> Configure Jupyter extension" \
    #&& jupyter nbextension enable --py widgetsnbextension \
    #&& mkdir -p ~/.ipython/profile_default/startup/ \
    #&& echo "import warnings" >> ~/.ipython/profile_default/startup/config.py \
    #&& echo "warnings.filterwarnings('ignore')" >> ~/.ipython/profile_default/startup/config.py \
    #&& echo "c.NotebookApp.token = u''" >> ~/.ipython/profile_default/startup/config.py \
    && echo "|--> Done!"
#ENTRYPOINT ["/sbin/tini", "--"]
