# Use a build argument to select the Python version.
ARG PYTHON_VERSION=3.13
FROM python:${PYTHON_VERSION}

# Avoid interactive prompts during apt-get install.
ENV DEBIAN_FRONTEND=noninteractive

# Set the working directory inside the container.
WORKDIR /app

# Install system dependencies (git and curl).
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
 && rm -rf /var/lib/apt/lists/*

# Copy repository contents into the container.
COPY . /app

# If using Python 3.10, install the Rust toolchain (version 1.70.0).
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain 1.70.0
ENV PATH="/root/.cargo/bin:${PATH}";
# Upgrade pip.
RUN python -m pip install --upgrade pip
# Install project dependencies.
# For Python 3.10, set the QISKIT_NO_CACHE_GATES environment variable.
RUN if [ "$PYTHON_VERSION" = "3.13.1" ]; then \
        python -m pip install -U -r requirements.txt -c constraints.txt; \
        python -m pip install -U -r requirements-dev.txt -c constraints.txt; \
        python -m pip install -c constraints.txt -e .; \
    fi
# If using Python 3.10, install optional dependencies and run the extra report.

# The default command runs the tests.
CMD ["stestr", "ru"]
