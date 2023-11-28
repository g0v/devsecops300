# DevSecOps: Shift Left Security

In the context of software development, "shift-left" and "shift-right" refer to the timing and integration of practices within the development lifecycle. Here's why DevSecOps is considered to be a "shift-left" approach:

Traditional Approach: Shift-Right

- In the traditional software development lifecycle, security practices were often "shift-right," meaning they were implemented late in the process, usually after the development and initial testing phases.
- Security testing or checks would often happen right before deployment or after the product was finished, which is toward the "right" on a timeline that moves from left (start) to right (finish).
- This late-stage security approach could lead to discovering vulnerabilities late in the cycle, making them more costly and challenging to fix.

DevSecOps: Shift-Left

- DevSecOps, however, emphasizes integrating security early and throughout the development process—essentially "shifting" it to the left on the timeline.
- By integrating security from the start and at every stage of development, issues can be identified and addressed when they are typically easier and less expensive to resolve.
- Shifting security left also means that developers become more involved in the security process, leading to a better understanding of security concerns and more secure coding practices.
- Continuous integration and continuous deployment (CI/CD) pipelines in DevSecOps include automated security testing and checks, which reinforces the shift-left strategy.

So, when we say DevSecOps is a "shift-left" approach, we mean that security is involved at the earliest stages of the software development process rather than being an afterthought. It aligns with the philosophy of early and continuous attention to security to prevent problems rather than having to deal with the consequences of security oversights later.

# ELI10 file permissions in the Linux world

Imagine you have a toy box at home. But it's not just any toy box—it's a special one with rules about who can play with the toys, who can put toys in or take them out, and who can put a lock on the box.

In the Linux world, your toys are the files and the toy box is a folder. Linux is like your parents, setting up rules for who can do what with the toys.

For every file (toy) and folder (toy box), there are three kinds of permissions:

- Read (r) - This lets you look at the toys in the box. If you have read permission on a file, you can see what's inside it. If it's on a folder, you can see what files are in there.
- Write (w) - This means you can put toys into the box or take them out. If you have write permission on a file, you can change what's written inside it, like painting over a toy. If it's on a folder, you can add new files or delete the files that are there.
- Execute (x) - This is a special rule for using the toys. For files that are like game instructions, execute permission means you can actually play the game. For a folder, having execute permission means you can go into the box and play with the toys inside.

There are also different groups of people who have these permissions:

- The owner - This is like you, the kid who owns the toy box. You usually get to decide what you want to do with your toys.
- The group - These are like your friends or siblings who you can share your toy box with. Your parents can set rules for what your friends can do with the toys, like maybe they can only play with them, but they can't take any out of the box or put new ones in.
- Others - This is everyone else who's not in your family and not a friend you've shared the toys with. Usually, you don't want them to do much with your toys, so the rules for them are the strictest.

In Linux, when you look at the toy box (folder) or a toy (file), you'll see a bunch of letters and dashes that look like this: drwxr-xr--. This is a code that tells you who can do what:

- The first letter tells you if it's a toy box (folder) or a toy (file)—d for directory (folder) and - for file.
- The next three letters are the rules for the owner (you)—for example, rwx means you can read, write, and execute.
- The middle three are for your friends in the group—r-x might mean they can read and play (execute), but not change the toys (write).
- The last three are for others, and they might just have r--, which means they can only look at the toys but not play with them or change anything.

So, just like your parents might put rules on your toy box, Linux has rules for its files and folders to make sure that only the right people can do certain things with them.

# DevSecOps vs. DevOpsSec

DevSecOps is sometimes referred to as a 'shift-left' approach to security. This concept doesn't merely advocate for the integration of security measures at the beginning of the DevOps process; it emphasizes the need to embed security practices throughout every stage of the DevOps lifecycle.

For the DevOps(DevOpsSec) way:

```sh
# DevOps
# Generate a new age encryption key and save it to a file.
age-keygen > /home/key101.txt

# Sec
# Set file permissions to ensure that only the owner can read and write to the key file.
# This is a basic security practice to protect sensitive information.
chmod 600 /home/key101.txt
```

For the DevSecOps way:

```sh
# DevSec
# Apply a default Access Control List (ACL) recursively and with propagation (-PR)
# to the /home directory, which sets the file permission mask for newly created files to 600.
# This preemptive measure secures files by default as they are created.
setfacl -PRdm u::rw,g::-,o::- /home

# Ops
# Generate a new age encryption key and save it to a file.
# Thanks to the prior ACL settings, this file is automatically secured with the correct permissions.
age-keygen > /home/key101.txt
```

# Demonstration

First, create a Dockerfile for the shift-left security demonstration:

```dockerfile
# Use the Debian 12 image as the base for our container.
FROM debian:12

# Update the package index and upgrade packages.
# Install 'age' for key generation and 'acl' for managing access control lists.
RUN apt-get update && apt-get upgrade -y && apt-get install -y age acl
```

Then, create a docker-compose.yaml file to build the image and run the containers for the demo case:

```yaml
version: '3.8'
name: devsecops231128
services:
  devops:
    # Name of the service within Docker Compose.
    build:
      context: .
      dockerfile: Dockerfile
    image: devsecops3001:latest
    # Command to generate an encryption key, list files, set permissions, and list files again before sleeping.
    entrypoint:
      - /bin/bash
      - -c 
      - |
        age-keygen > /home/key101.txt
        ls -al /home
        chmod 600 /home/key101.txt
        ls -al /home
        sleep 1d

  devsecops:
    # Name of the service within Docker Compose emphasizing the security-first approach.
    image: devsecops3001:latest
    # Command to set default ACL, generate an encryption key, list files, and sleep.
    entrypoint:
      - /bin/bash
      - -c 
      - |
        # Security 'shift left': Set default ACL to secure all files at creation.
        setfacl -m default:user::rw-,group::---,other::--- /home
        sleep 2  # let the devops container starts first.
        age-keygen > /home/key101.txt
        ls -al /home
        sleep 1d
```

Finally, let's run this demo to demonstrate the concept of shifting security left:

```sh
# Build the Docker image according to the Dockerfile specifications.
docker compose build

# Start two containers in detached mode.
docker compose up -d

# View the logs from the running containers to observe the operations.
docker compose logs

# Optionally, execute a bash shell within the 'devops' container for interactive operations.
docker compose exec devops bash

# Alternatively, execute a bash shell within the 'devsecops' container for interactive operations.
docker compose exec devsecops bash

# Clean up by stopping and removing containers and networks created by up.
docker compose down
```

Remember to correct the docker compose command to docker-compose for consistency with the rest of the code, unless the latest CLI version accepts both syntaxes.

docker compose logs 

```sh
Attaching to devsecops231128-devops-1, devsecops231128-devsecops-1
devsecops231128-devops-1     | age-keygen: warning: writing secret key to a world-readable file
devsecops231128-devops-1     | Public key: age1fuxp00c7c72k74mry2jw03x2c9s628dxkmjz5rjvgw4ytl32f9gs32hsn3
devsecops231128-devops-1     | total 12
devsecops231128-devops-1     | -rw-r--r-- 1 root root  184 Nov 28 00:59 key101.txt
devsecops231128-devops-1     | drwxr-xr-x 1 root root 4096 Nov 28 00:59 .
devsecops231128-devops-1     | drwxr-xr-x 1 root root 4096 Nov 28 00:59 ..
devsecops231128-devops-1     | total 12
devsecops231128-devops-1     | -rw------- 1 root root  184 Nov 28 00:59 key101.txt
devsecops231128-devops-1     | drwxr-xr-x 1 root root 4096 Nov 28 00:59 .
devsecops231128-devops-1     | drwxr-xr-x 1 root root 4096 Nov 28 00:59 ..
devsecops231128-devsecops-1  | Public key: age14dlxh9yp4ncuy46ncn2zywskyly7j9f8hdt09rtf3rq7x5eldprqz9562m
devsecops231128-devsecops-1  | total 16
devsecops231128-devsecops-1  | -rw-------  1 root root  184 Nov 28 00:59 key101.txt
devsecops231128-devsecops-1  | drwxr-xr-x+ 1 root root 4096 Nov 28 00:59 .
devsecops231128-devsecops-1  | drwxr-xr-x  1 root root 4096 Nov 28 00:59 ..
```

# Real world use case: CIS benchmark

The Center for Internet Security (CIS) Benchmarks are a set of best practice security configuration guidelines developed to help organizations secure their IT systems and data against cyber threats. These benchmarks are consensus-based and created by cybersecurity experts and various stakeholders from the IT industry, including government entities, academia, and consultants.

The CIS Benchmarks cover a wide array of products and systems including, but not limited to:

- Operating systems (such as Windows, Linux, and macOS)
- Cloud providers (like AWS, Azure, and Google Cloud Platform)
- Databases (such as MySQL, PostgreSQL, and MongoDB)
- Web servers (e.g., Apache and IIS)
- Network devices (such as routers and firewalls)
- Mobile devices (iOS and Android)

Each benchmark provides detailed recommendations that outline secure configuration settings for the specific system or software, including instructions on how to harden various aspects such as:

- User account management
- Password policies
- File permissions
- Network settings
- Firewall configurations
- Log and audit settings
- Patching and updates

By adhering to CIS Benchmarks, organizations can establish a strong security posture aligned with industry standards, reduce their attack surface, and ensure compliance with regulatory requirements. These benchmarks are often used for compliance, regulatory obligations, and as part of security auditing processes. They are valuable not only for system administrators and security professionals but also for IT auditors and compliance officers. Additionally, some compliance frameworks may reference CIS Benchmarks as part of their security controls.

# OS security hardening

The excerpt provided is from the debian-cis project's script that checks and enforces security compliance as per the CIS Benchmark guidelines. It particularly addresses the required file permissions for the /etc/passwd backup file and for SSH private key files.

While changing the /etc/passwd, such as adding a new user, the original /etc/passwd file will be saved as /etc/passwd-. For the /etc/passwd backup file, the script ensures the following security configurations:

```sh
# CIS Benchmark recommendation for /etc/passwd- file permissions
HARDENING_LEVEL=1
DESCRIPTION="Ensure /etc/passwd- has permissions of 600 and is owned by root:root."

FILE='/etc/passwd-'
PERMISSIONS='600'  # Indicates the recommended permissions
PERMISSIONSOK='644 640 600'  # A range of acceptable permission levels
USER='root'  # The owner of the file should be the root user
GROUP='root'  # The group owner of the file should be the root group
```

When it comes to SSH private key files, the script enforces the following settings:

```sh
# CIS Benchmark recommendation for SSH private key file permissions
HARDENING_LEVEL=1
DESCRIPTION="Verify that SSH private keys have strict permissions of 600 and are owned by root:root."

DIR='/etc/ssh'  # Directory where SSH private keys are typically stored
PERMISSIONS='600'  # Strict permissions are required for private keys
USER='root'  # Ownership of the private key files should be by the root user
GROUP='root'  # The group owner of the private key files should also be root
```

- https://github.com/ovh/debian-cis/blob/de295b3a77fc10ccd8bf9fe03f3d28dc02f33325/bin/hardening/6.1.6_etc_passwd-_permissions.sh#L21C14-L21C14
- https://github.com/ovh/debian-cis/blob/de295b3a77fc10ccd8bf9fe03f3d28dc02f33325/bin/hardening/5.2.2_ssh_host_private_keys_perm_ownership.sh#L21


# CIS Kubernetes Benchmark

The following excerpt is from the kube-bench configuration for CIS Kubernetes Benchmark 1.24. It details the required file permissions for various Kubernetes components as recommended by the CIS Benchmark:

```yaml
controls:
version: "cis-1.24"
id: 1
text: "Control Plane Security Configuration"
type: "master"
groups:
  - id: 1.1
    text: "Control Plane Node Configuration Files"
    checks:
      - id: 1.1.1
        text: "Ensure that the API server pod specification file permissions are set to 600 or more restrictive (Automated)"
        audit: "/bin/sh -c 'if test -e $apiserverconf; then stat -c permissions=%a $apiserverconf; fi'"
        tests:
          test_items:
            - flag: "permissions"
              compare:
                op: bitmask
                value: "600"
```

This snippet from the kube-bench configuration specifies the recommended file permissions for master node components in a Kubernetes cluster, as outlined by the CIS Kubernetes 1.24 Benchmark.

It's essential to follow the updated guidelines provided by the CIS benchmarks and tools like kube-bench to ensure that Kubernetes clusters are configured securely according to best practices. This helps in maintaining the security and integrity of the infrastructure managed by Kubernetes.

- https://github.com/aquasecurity/kube-bench/blob/f8fe5ee173ac72f555391623dc81df6708bc7122/cfg/cis-1.24/master.yaml#L12

# Continuous Security Measures

Embracing a shift-left security approach is a critical initial step in enhancing security; however, it is merely the foundation upon which continuous security measures must be built. Consider the ```chmod``` command from our demonstration: it has the capability to modify file permissions as desired. However, there is a need for persistent vigilance to ensure that file permissions remain in alignment with predefined security policies.

Just as securing a room involves more than an automatic door-closing mechanism, comprehensive security in IT systems requires ongoing monitoring and assessment. Implementing security-by-design principles, such as those demonstrated by shift-left practices, is the start. To maintain a robust security posture, one must adopt continuous verification tools and processes—akin to a mechanism that constantly monitors the state of the door.

In the context of IT security, leveraging tools like the CIS Benchmark provides an essential detection mechanism. These benchmarks serve as a constant watchdog, systematically enforcing and checking that security configurations, such as file permissions, stay synchronized with established best practices. Rather than solely relying on the initial security design, such as automatic door-closing features, it's vital to also employ active surveillance measures to detect and rectify any deviations from the security baseline.

# QA: Multiple Choice Questions

1. What is the primary goal of DevSecOps? A. Speed up development B. Focus on operations C. Merge development and operations D. Integrate security throughout the IT lifecycle
   - Correct Answer: D
   - Explanation: DevSecOps is an approach that integrates "security as a shared responsibility throughout the entire IT lifecycle."
2. In which approach are security practices usually implemented late in the process? A. Shift-left B. DevSecOps C. Shift-right D. Agile
   - Correct Answer: C
   - Explanation: In the traditional software development lifecycle, security practices were often "shift-right," meaning they were implemented late in the process.
3. What does 'chmod 600 /home/key101.txt' do? A. Sets the file to be writable by the group B. Sets the file to be executable by others C. Sets the file permissions so that only the owner can read and write D. Removes all permissions from the file
   - Correct Answer: C
   - Explanation: "# Set file permissions to ensure that only the owner can read and write to the key file."
4. What does the 'setfacl' command do in the given context? A. It generates an age encryption key B. It sets file permissions for existing files to 600 C. It applies a default Access Control List for newly created files D. It revokes all permissions for the users
   - Correct Answer: C
   - Explanation: "Apply a default Access Control List (ACL) recursively and with propagation (-PR) to the /home directory, which sets the file permission mask for newly created files to 600."
5. What kind of base image is used in the provided Dockerfile? A. Ubuntu B. Alpine C. Debian D. CentOS
   - Correct Answer: C
   - Explanation: "Use the Debian 12 image as the base for our container."
6. Which version of docker-compose syntax is used in the provided YAML example? A. '2.0' B. '3.3' C. '3.8' D. '3.0'
   - Correct Answer: C
   - Explanation: "version: '3.8'"
7. What Docker Compose service name emphasizes the security-first approach? A. devops B. secops C. secure-devops D. devsecops
   - Correct Answer: D
   - Explanation: "Name of the service within Docker Compose emphasizing the security-first approach."
8. What does 'age-keygen > /home/key101.txt' do? A. Decrypts key101.txt B. Copies key101.txt to the /home directory C. Backs up key101.txt D. Generates a new age encryption key and saves it to key101.txt
   - Correct Answer: D
   - Explanation: "Generate a new age encryption key and save it to a file."
9. Which permission allows the user to execute a file as a program? A. Read (r) B. Write (w) C. Execute (x) D. Modify (m)
   - Correct Answer: C
   - Explanation: "Execute (x) - This is a special rule for using the toys."
10. What does 'ls -al /home' do in the given Docker Compose setup? A. Changes file permissions B. Lists all the files in the /home directory including hidden ones C. Lists only the write-protected files in the /home directory D. Creats a new directory under /home
    - Correct Answer: B
    - Explanation: The 'ls -al' command lists all files, including hidden ones (those starting with a dot), in long format which includes permissions, number of links, owner, group, size, date modified, and file/directory name.
11. What are the CIS Benchmarks designed for? A. Speed testing system performance B. Securing IT systems against cyber threats C. Only for mobile device security D. Updating software to the latest version
    - Correct Answer: B
    - Explanation: "The CIS Benchmarks are a set of best practice security configuration guidelines developed to help organizations secure their IT systems and data against cyber threats."
12. Who develops the CIS Benchmarks? A. Independent hackers B. Cybersecurity enthusiasts C. System admins D. Cybersecurity experts and IT industry stakeholders
    - Correct Answer: D
    - Explanation: "These benchmarks are consensus-based and created by cybersecurity experts and various stakeholders from the IT industry."
13. What is the recommended file permissions for the API server pod specification file according to the CIS Kubernetes Benchmark 1.24? A. 700 or more restrictive B. 600 or more restrictive C. 500 or more restrictive D. 400 or more restrictive
    - Correct Answer: B
    - Explanation: "Ensure that the API server pod specification file permissions are set to 600 or more restrictive (Automated)."
14. What does the '+' symbol indicate in the file permission output 'drwxr-xr-x+'? A. Increased execution permissions B. Extra permissions available C. Special permissions like setuid, setgid, or sticky bit D. Access control lists are in effect on the directory
    - Correct Answer: D
    - Explanation: The '+' symbol indicates that there are additional permissions available via ACLs (Access Control Lists).
15. What is the implication of discovering vulnerabilities late in the software development cycle? A. Vulnerabilities are less costly to fix B. Vulnerabilities become a feature C. Vulnerabilities can be ignored safely D. Vulnerabilities are more costly and challenging to fix
    - Correct Answer: D
    - Explanation: "This late-stage security approach could lead to discovering vulnerabilities late in the cycle, making them more costly and challenging to fix."
16. Why is the shift-left approach emphasized in DevSecOps? A. It offers better performance B. It enhances later stages of development C. It allows issues to be identified and addressed earlier and more easily D. It is less expensive in terms of tools required
    - Correct Answer: C
    - Explanation: "By integrating security from the start and at every stage of development, issues can be identified and addressed when they are typically easier and less expensive to resolve."
17. In Linux file permission notation, what does 'rw-' indicate for the owner? A. Read, write, and execute permissions B. Read and write permissions, no execute C. Read and execute permissions, no write D. Write and execute permissions, no read
    - Correct Answer: B
    - Explanation: "The next three letters are the rules for the owner (you)—for example, rwx means you can read, write, and execute."
18. What does the 'age-keygen' tool do? A. Generates an access control list B. Sets file permissions C. Generates an encryption key D. Encrypts age keys
    - Correct Answer: C
    - Explanation: "age-keygen > /home/key101.txt - Generates a new age encryption key and saves it to a file."
19. Which tool can be used to check if Kubernetes clusters are configured securely according to the CIS Benchmarks? A. Docker Compose B. kube-bench C. setfacl D. age-keygen
    - Correct Answer: B
    - Explanation: "It's essential to follow the updated guidelines provided by the CIS benchmarks and tools like kube-bench to ensure that Kubernetes clusters are configured securely according to best practices."
20. What is a valid reason to employ CIS Benchmarks? A. To accelerate software development B. To ensure compliance with regulatory requirements C. To minimize software testing D. To simplify user interface design
    - Correct Answer: B
    - Explanation: "By adhering to CIS Benchmarks, organizations can establish a strong security posture aligned with industry standards, reduce their attack surface, and ensure compliance with regulatory requirements."