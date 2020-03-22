From python:3-alpine
ARG USE_MIRROR
#ARG python_packages="numpy scipy pandas sklearn matplot"
#sklearn packages will install numpy scipy scikitlearn"
ARG python_packages="scipy"
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR";
RUN apk update && apk upgrade \
&& apk add --no-cache make automake gcc g++ build-base gfortran \
&& apk add --no-cache py3-numpy py3-numpy-f2py jpeg libpng libstdc++ libpng libgomp graphviz \
&& apk add --no-cache linux-headers python3-dev git cmake jpeg-dev bash \
        libffi-dev gfortran openblas-dev py3-numpy-dev  libpng-dev \
#RUN apk add openblas-dev
RUN [ "$USE_MIRROR" = "true" ] && pip install --no-cache-dir ${python_packages} -i https://pypi.douban.com/simple || pip install --no-cache-dir ${python_packages}
