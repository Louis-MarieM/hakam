# Fundamental image
FROM python:3.13-slim

# Configuration
WORKDIR /hakam
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1


# Dependancies installation
RUN apt-get update && apt-get install -y \
    openssh-client \
    git \
    rsync \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir \
    ansible==${ANSIBLE_VERSION} \
    ansible-lint \
    jinja2 \
    netaddr

# Make entrypoint.sh runnable.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ansible-playbook", "--version"]