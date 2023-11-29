# Use the Debian 12 image as the base for our container.
FROM debian:12

# Update the package index and upgrade packages.
# Install 'age' for key generation and 'acl' for managing access control lists.
RUN apt-get update && apt-get upgrade -y && apt-get install -y age acl