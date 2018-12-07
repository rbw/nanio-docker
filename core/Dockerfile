FROM alpine:3.8

# Install environment
RUN apk update >/dev/null

RUN apk add --no-cache file git gcc python3-dev musl-dev autoconf automake libtool make >/dev/null && \
    if [[ ! -e /usr/bin/python ]]; then ln -sf /usr/bin/python3 /usr/bin/python; fi

# Compile and install the blake2 library
RUN git clone https://github.com/BLAKE2/libb2 /tmp/libb2 >/dev/null

WORKDIR /tmp/libb2

RUN ./autogen.sh >/dev/null
RUN ./configure >/dev/null
RUN make install >/dev/null

# Copy settings and dependencies
COPY app /app
COPY settings /app/settings

# Install dependencies
RUN pip3 install pip --upgrade >/dev/null
RUN pip3 install --no-cache-dir -r /app/requirements.txt --upgrade >/dev/null

WORKDIR /app

ENTRYPOINT ["python3", "-m", "nanio"]
