FROM rclone/rclone:latest

RUN apk add --no-cache bash xz

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER root
ENTRYPOINT ["/entrypoint.sh"]
