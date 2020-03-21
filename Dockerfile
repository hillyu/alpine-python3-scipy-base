From python:3-alpine
ARG USE_MIRROR
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR"
RUN apk update && apk upgrade
RUN apk add make automake gcc g++ 
RUN apk add lapack-dev blas-dev
RUN pip install --no-cache-dir numpy pandas sklearn\
    -i https://pypi.douban.com/simple
