FROM python:3.11-slim-bookworm

LABEL org.opencontainers.image.source = "https://github.com/muselab-d2x/d2x"

# Install sfdx
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y gnupg wget curl git

# Install Node.js
RUN \
  echo "deb https://deb.nodesource.com/node_20.x bullseye main" > /etc/apt/sources.list.d/nodesource.list && \
  wget -qO- https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
  apt-get update
RUN apt-get install -y nodejs
# RUN npm install --global npm jq commander
# RUN npm install --global sfdx-cli --ignore-scripts
RUN npm install --global @salesforce/cli --ignore-scripts

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt-get install -y gh

# Install PowerShell
RUN apt-get install -y libicu72
WORKDIR /tmp
RUN wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell_7.4.1-1.deb_amd64.deb
RUN dpkg -i powershell_7.4.1-1.deb_amd64.deb
RUN apt-get install -f
RUN rm powershell_7.4.1-1.deb_amd64.deb

# Install common tools
RUN apt-get install -y unzip bash

# Install Salesforce CLI plugins:
# RUN sfdx plugins:install @salesforce/sfdx-scanner
RUN sf plugins install @salesforce/sfdx-scanner

# Install CumulusCI
RUN pip install --no-cache-dir --upgrade pip pip-tools
RUN pip --no-cache-dir install docutils
RUN pip --no-cache-dir install cumulusci

# Copy devhub auth script and make it executable
COPY devhub.sh /usr/local/bin/devhub.sh
RUN chmod +x /usr/local/bin/devhub.sh

# Create d2x user
RUN useradd -r -m -s /bin/bash -c "D2X User" d2x

# Setup PATH
RUN echo 'export PATH=~/.local/bin:$PATH' >> /root/.bashrc
RUN echo 'export PATH=~/.local/bin:$PATH' >> /home/d2x/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /root/.bashrc
RUN echo '/usr/local/bin/devhub.sh' >> /home/d2x/.bashrc

USER d2x
CMD ["bash"]
