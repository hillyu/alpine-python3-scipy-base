From python:3-alpine
ARG USE_MIRROR
ARG python_packages="pandas scipy sklearn"
RUN [ "$USE_MIRROR" = "true" ] && sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories ||echo "$USE_MIRROR";
#RUN apk update && apk upgrade
RUN apk add make automake gcc g++ 
RUN apk add lapack-dev blas-dev
RUN [ "$USE_MIRROR" = "true" ] && pip install --no-cache-dir ${python_packages} -i https://pypi.douban.com/simple || pip install --no-cache-dir ${python_packages}
