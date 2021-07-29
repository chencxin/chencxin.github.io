FROM klakegg/hugo:0.81.0 as build

COPY . /src
WORKDIR /src
RUN hugo

FROM hub.dns.360.cn/library/nginx-worker:release

COPY --from=build /src/public /etc/nginx/public
COPY ./default.conf /etc/nginx/conf.d/default.conf

RUN set -xe \
    && chown -R nobody:nobody /etc/nginx/public 
