# Detecting Path Traversal and Data Exfiltration in Containers using gVisor

# Honeypots for DevSecOps

Honeypots are decoy systems or traps designed to lure cyberattackers and study their methods without them knowing they are being observed. In the context of DevSecOps, integrating honeypots can provide several benefits, aligning with the mindset of incorporating security practices throughout the development, deployment, and maintenance lifecycle. Here's how honeypots can contribute to DevSecOps workflows:

1. Early Threat Detection: Honeypots can detect threats early in the DevSecOps pipeline by identifying attack patterns and techniques targeting the system. They serve as an early warning system for security teams to investigate and respond before attackers reach production systems.
2. Improved Security Posture: By monitoring the honeypot, the DevSecOps team gains insight into the types of attacks and attackers that are prevalent, which can inform the overall security strategy. This knowledge allows the team to proactively enhance security measures in development and operational environments based on real-world attack data.
3. Attack Analysis and Intelligence: Honeypots provide an opportunity to analyze how attackers operate, which vulnerabilities they exploit, and what their end goals might be. This intelligence can lead to better-informed security decisions, such as prioritizing patching certain vulnerabilities or implementing specific defensive measures.
4. Training and Awareness: The data collected from honeypots can be used for training DevSecOps teams. It helps developers and operations staff understand the security landscape and the importance of following best practices. Teams can simulate attacks in a controlled environment to learn and improve their skills.
5. Reducing False Positives: Since honeypots are designed to be enticing for attackers, interactions with them are likely to be malicious. This reduces the noise from false positives that might come from monitoring legitimate system use, allowing security professionals to focus on genuine threats.
6. Resource Protection: Honeypots can act as a distraction or a decoy, diverting attackers away from actual production systems. By engaging attackers with these false targets, honeypots can potentially prevent or mitigate the impact of an attack on valuable resources.
7. Compliance and Regulation: Honeypots can help organizations comply with regulatory requirements that mandate breach detection capabilities and proactive security measures. By demonstrating an active approach to understanding and responding to threats, organizations may fulfill certain compliance obligations.
8. Continuous Feedback Loop: In DevSecOps, feedback at every stage is crucial for improvement. Honeypots provide continuous feedback on threats and vulnerabilities, allowing the team to improve the security of the applications and infrastructure iteratively and responsively.

Incorporating honeypots into a DevSecOps workflow allows teams to stay ahead of threats by employing proactive detection methods and by building an adaptive security posture that evolves with the emerging threat landscape. It's important to note, however, that honeypots should be just one aspect of a comprehensive security approach, complemented by other tools and practices such as vulnerability scanning, penetration testing, secure coding practices, and effective incident response planning.

# Hardened runtime

Honeypots are decoy systems designed as traps to lure and contain potential attackers. The containers within these decoy systems must be robust to prevent targets from escaping the honeypot environment. To secure kernel syscalls, we can switch to a hardened runtime for containers, which is akin to installing tempered glass in a window: the goal is to allow light to enter while also protecting against small rocks that could shatter the glass. In the article that follows, we will explore the use of gVisor's runsc hardened runtime as a case study in enhancing security.

# Boosting Container Security Visibility: How gVisor Enhances IOCs Detection

Indicators of Compromise (IOCs) are the digital and informational "clues" that incident responders use to detect, diagnose, halt, and remediate malicious activity in their networks. Imagine you're playing in your backyard and you've set up some rules to know if someone sneaks in to play with your toys without asking you. These rules help you figure out if something fishy has happened. In our little scenario, these rules can be like the "Indicators of Compromise" or IOCs.

Now let's think about what kind of rules (IOCs) you might have:

- Footprints: If someone sneaked in, they might leave footprints in the garden that weren't there before. On a computer, this could be unusual activities or files that suddenly appear that weren't there before.
- Broken Toys: Maybe you find your toys in the wrong place or broken. In the computer world, this might be systems or files that are changed in ways they shouldn't be.
- Strange Noises: Perhaps you hear weird noises that you don't usually hear when everyone is playing nicely. On computers, this might be strange messages showing up in your system logs that tell you something isn't working correctly.
- The Secret Code: You and your friends have a secret knock for getting into the clubhouse. If someone doesn't use the correct knock, you know they're not supposed to be there. Similarly, if a computer gets an instruction that doesn't match the 'secret codes' it's supposed to follow, this could be an IOC.
- Someone tells you: If a neighbor saw someone sneaking around and they tell you about it, that's a clue! On the internet, there are big communities where people share information about suspicious behaviors they've seen, which can be considered IOCs.
- New Toys You Didn't Buy: Finding new toys in your backyard that you didn't put there would be very unusual. On a computer, IOCs can include unexpected new programs installed without your knowledge.

These rules help you decide if you need to tell an adult that someone might be playing in your yard without asking. Similarly, in computers and networks, IOCs help IT people decide if there's a need to look closer because something may be wrong, like someone trying to cause harm or steal information.

gVisor, a sandboxing tool developed by Google, is designed to provide strong isolation for container workloads. Its unique approach of intercepting system calls and running them through a guest kernel residing in userspace results in a form of lightweight virtualization. This setup gives gVisor the potential to enhance the detection of Indicators of Compromise (IOCs) in several ways:
demonstrationld signal a security breach, providing richer IOC data for incident responders.

However, this increase in IOC visibility through gVisor does come with trade-offs. The per-system call overhead introduced by gVisor's architecture could potentially impact performance, and the additional layer of abstraction could interfere with certain applications. It's also imperative that the gVisor itself is kept secure, as vulnerabilities in its implementation could potentially expose the very environments it is meant to protect.

By giving security teams a more detailed view of container activity, gVisor assists not just in the detection of IOCs, but also in the deployment of preventative measures and rapid response to security incidents.

# Hardened Containerized Honeypots: Uncovering Security Threats with gVisor Logs

In this hardened runtime demonstration, we will be using Docker Compose to run two containers: one as an HTTP server, and the other as an HTTP client. Initially, we need to ensure Docker's runtime is properly configured to work with gVisor's `runsc`. Below is the Docker runtime configuration for gVisor's `runsc`, located in `/etc/docker/daemon.json`:

```json
{
    "runtimes": {
        "runsc": {
            "path": "/usr/bin/runsc",
            "runtimeArgs": [
                "--debug-log=/tmp/runsc/",
                "--debug",
                "--log-packets",
                "--strace"
            ]
        }
    }
}
```

The cgi-bin script in the following code:

```sh
cat <<'EOOF' > /www/cgi-bin/page.sh
#!/bin/sh
# Define the MIME type of the response
echo "Content-Type: text/html"
# Send an empty line to conclude the HTTP headers
echo ""
# Output the entire QUERY_STRING provided by the web server
echo "$QUERY_STRING"
# Extract the file path from the QUERY_STRING
THEPATH=$(echo "$QUERY_STRING" | cut -d "=" -f 2)
# Echo the extracted path for debugging purposes
echo "$THEPATH"
# Navigate to the parent directory of the current script
cd ..
# Output the content of the file specified by the file path
cat "$THEPATH"
EOOF
```

The script here is embedded in a shell heredoc, which is used to create a new file. Here's a breakdown of what it does:

`cat <<'EOOF' > /www/cgi-bin/page.sh`: This command starts a heredoc, which is a way of redirecting a block of text into a file. The `<<'EOOF'` part indicates that the shell should read all the following lines until it encounters a line containing only EOOF. The character sequence `EOOF` can be any sequence of characters, as long as it is unique and does not appear elsewhere in the block of text. The single quotes around `EOOF` ensure that the text is treated literally, without variable expansion or command substitution by the shell. The text block is redirected into a new file named `page.sh` located in `/www/cgi-bin/`, which is a common directory for CGI (Common Gateway Interface) scripts on a web server.

The content of `page.sh`:
- `#!/bin/sh`: This is the shebang line that indicates what interpreter should be used to run the script, in this case /bin/sh (the Bourne shell or a compatible shell).
- `echo "Content-Type: text/html"`: This line sends the Content-Type header to the web server, indicating that the content returned by the script is HTML.
- `echo ""`: This prints a blank line, which is needed to separate HTTP headers from the content body in the CGI response.
- `echo "$QUERY_STRING"`: This line echoes the content of the QUERY_STRING environment variable, which typically contains the query parameters from the URL of a GET request.
- `THEPATH=$(echo "$QUERY_STRING" | cut -d "=" -f 2)`: This command extracts the value of the query string parameter (assuming there is only one and it's formatted like key=value) by using cut to split the string at "=" and taking the second field (the value).
- `echo "$THEPATH"`: This line echoes the extracted path.
- `cd ..`: This changes the current working directory to the parent directory of the script's location.
- `cat "$THEPATH"`: This line concatenates and displays the content of the file located at the path stored in THEPATH. Because the script has changed to the parent directory, it expects THEPATH to be a relative path from there.

The final EOOF without single quotes or any prefix indicates the end of the heredoc block.

Next, we include the runtime configuration and `cgi-bin/page.sh` in the following `docker-compose.yaml`:

```yaml
name: givsor231128
services:
  box101:
    image: busybox:1.35.0
    runtime: runsc # using gVisor's runsc runtime
    # https://gvisor.dev/docs/tutorials/docker-compose/
    # All services must be on the same network to communicate.
    network_mode: bridge
    command:
      - /bin/sh
      - -c
      - |
        echo "starting box101"
        mkdir /www /www/cgi-bin /www/etc
        cd /www
        cat <<\EOOF > index.html
        <html>
          <head><title>HELLO123</title></head>
          <body>HELLO123</body>
        </html>
        EOOF
        # 
        # NOTE: $$ to escape the $ dollar sign in a docker compose file
        # 
        cat <<\EOOF > /www/cgi-bin/page.sh
        #!/bin/sh
        echo "Content-Type: text/html"
        echo ""
        echo "$$QUERY_STRING"
        THEPATH=$(echo "$$QUERY_STRING" | cut -d "=" -f 2)
        echo "$$THEPATH"
        cd ..
        cat "$$THEPATH"
        EOOF
        chmod 700 /www/cgi-bin/page.sh
        busybox httpd -fv -p 3000
  box201:
    image: curlimages/curl:7.86.0
    runtime: runsc
    # All services must be on the same network to communicate.
    network_mode: bridge
    # When using the "bridge" network specify links.
    links:
      - box101  # linking to the HTTP server container for communication 
    command:
      - sh
      - -c
      - |
        sleep 3
        curl -sv --retry 5 --retry-all-errors http://box101:3000/index.html
        echo
        curl -sv http://box101:3000/cgi-bin/page.sh?name=index.html
        curl -sv http://box101:3000/cgi-bin/page.sh?name=../etc/passwd
        sleep 1d
  box301:
    image: busybox:1.36.1
    volumes:
      - /tmp/runsc:/tmp/runsc:ro
    command:
      - sh
      - -c
      - |
        sleep 5
        grep "/etc/passwd" /tmp/runsc/* | grep "cat"
        echo
        grep "/etc/passwd" /tmp/runsc/* | egrep "curl.*read"
        sleep 1d
```

With the setup complete, we start the demonstration by running `docker compose up -d`, followed by `docker compose logs` to examine the logs:

```log
givsor231128-box101-1  | starting box101
givsor231128-box101-1  | [::ffff:172.17.0.4]:28937: response:200
givsor231128-box201-1  | *   Trying 172.17.0.3:3000...
givsor231128-box201-1  | * Connected to box101 (172.17.0.3) port 3000 (#0)
givsor231128-box201-1  | > GET /index.html HTTP/1.1
givsor231128-box201-1  | > Host: box101:3000
givsor231128-box201-1  | > User-Agent: curl/7.86.0-DEV
givsor231128-box201-1  | > Accept: */*
givsor231128-box201-1  | > 
givsor231128-box201-1  | * Mark bundle as not supporting multiuse
givsor231128-box201-1  | < HTTP/1.1 200 OK
givsor231128-box201-1  | < Date: Wed, 29 Nov 2023 03:19:18 GMT
givsor231128-box201-1  | < Connection: close
givsor231128-box201-1  | < Content-type: text/html
givsor231128-box201-1  | < Accept-Ranges: bytes
givsor231128-box201-1  | < Last-Modified: Wed, 29 Nov 2023 03:19:15 GMT
givsor231128-box201-1  | < ETag: "6566adb3-4e"
givsor231128-box201-1  | < Content-Length: 78
givsor231128-box201-1  | < 
givsor231128-box201-1  | { [78 bytes data]
givsor231128-box201-1  | <html>
givsor231128-box201-1  |   <head><title>HELLO123</title></head>
givsor231128-box201-1  |   <body>HELLO123</body>
givsor231128-box201-1  | </html>
givsor231128-box201-1  | * Closing connection 0
givsor231128-box201-1  | 
givsor231128-box201-1  | *   Trying 172.17.0.3:3000...
givsor231128-box201-1  | * Connected to box101 (172.17.0.3) port 3000 (#0)
givsor231128-box201-1  | > GET /cgi-bin/page.sh?name=index.html HTTP/1.1
givsor231128-box201-1  | > Host: box101:3000
givsor231128-box201-1  | > User-Agent: curl/7.86.0-DEV
givsor231128-box201-1  | > Accept: */*
givsor231128-box201-1  | > 
givsor231128-box201-1  | * Mark bundle as not supporting multiuse
givsor231128-box201-1  | < HTTP/1.1 200 OK
givsor231128-box201-1  | < Content-Type: text/html
givsor231128-box201-1  | * no chunk, no close, no size. Assume close to signal end
givsor231128-box201-1  | < 
givsor231128-box201-1  | { [16 bytes data]
givsor231128-box201-1  | name=index.html
givsor231128-box201-1  | * Closing connection 0
givsor231128-box201-1  | index.html
givsor231128-box201-1  | <html>
givsor231128-box201-1  |   <head><title>HELLO123</title></head>
givsor231128-box201-1  |   <body>HELLO123</body>
givsor231128-box201-1  | </html>
givsor231128-box201-1  | *   Trying 172.17.0.3:3000...
givsor231128-box201-1  | * Connected to box101 (172.17.0.3) port 3000 (#0)
givsor231128-box201-1  | > GET /cgi-bin/page.sh?name=../etc/passwd HTTP/1.1
givsor231128-box201-1  | > Host: box101:3000
givsor231128-box201-1  | > User-Agent: curl/7.86.0-DEV
givsor231128-box201-1  | > Accept: */*
givsor231128-box201-1  | > 
givsor231128-box201-1  | * Mark bundle as not supporting multiuse
givsor231128-box201-1  | < HTTP/1.1 200 OK
givsor231128-box201-1  | < Content-Type: text/html
givsor231128-box201-1  | * no chunk, no close, no size. Assume close to signal end
givsor231128-box201-1  | < 
givsor231128-box201-1  | { [19 bytes data]
givsor231128-box201-1  | name=../etc/passwd
givsor231128-box201-1  | * Closing connection 0
givsor231128-box201-1  | ../etc/passwd
givsor231128-box201-1  | root:x:0:0:root:/root:/bin/sh
givsor231128-box201-1  | daemon:x:1:1:daemon:/usr/sbin:/bin/false
givsor231128-box201-1  | bin:x:2:2:bin:/bin:/bin/false
givsor231128-box201-1  | sys:x:3:3:sys:/dev:/bin/false
givsor231128-box201-1  | sync:x:4:100:sync:/bin:/bin/sync
givsor231128-box201-1  | mail:x:8:8:mail:/var/spool/mail:/bin/false
givsor231128-box201-1  | www-data:x:33:33:www-data:/var/www:/bin/false
givsor231128-box201-1  | operator:x:37:37:Operator:/var:/bin/false
givsor231128-box201-1  | nobody:x:65534:65534:nobody:/home:/bin/false
```

Once the two containers are up and running, we can check the `runsc` debug logs located in `/tmp/runsc/`. 

Using the `grep "/etc/passwd" /tmp/runsc/* | grep "cat"` to search the pattern. Let's break down what this command is intended to do based on standard usage of grep:

1. `grep`: This is the command-line utility for searching plain-text data sets for lines that match a specified pattern.
2. `/etc/passwd`: This is typically a path to a file, but in the context of grep, it is interpreted as the pattern to search for unless it is preceded by an option. `/etc/passwd` is actually a file that contains user account information on Unix-like systems.
3. `/tmp/runsc/*`: This seems to be the pattern of files to search within. The asterisk (*) signifies a glob pattern that matches any files or directories within the /tmp/runsc/ directory.
4. `|`: This is the pipe operator, which passes the output of one command as input to another command.
5. `grep "cat"`: This is searching the output from the previous grep for lines that contain the string "cat".

By running `grep '/etc/passwd' /tmp/runsc/* | grep 'cat'`, we observe the following output:

```log
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.047423   28907 strace.go:567] [  19:  19] page.sh E execve(0x522f90 /bin/cat, 0x522ed0 ["cat", "../etc/passwd"], 0x522ee8 ["GATEWAY_INTERFACE=CGI/1.1", "HOSTNAME=2bb1fdfd8add", "SHLVL=2", "REMOTE_ADDR=[::ffff:172.17.0.4]", "HOME=/root", "OLDPWD=/www/cgi-bin", "QUERY_STRING=name=../etc/passwd", "HTTP_USER_AGENT=curl/7.86.0-DEV", "REMOTE_PORT=58778", "HTTP_ACCEPT=*/*", "SCRIPT_FILENAME=/www/cgi-bin/page.sh", "HTTP_HOST=box101:3000", "REQUEST_URI=/cgi-bin/page.sh?name=../etc/passwd", "SERVER_SOFTWARE=busybox httpd/1.35.0", "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", "SERVER_PROTOCOL=HTTP/1.1", "PATH_INFO=", "REQUEST_METHOD=GET", "PWD=/www", "SCRIPT_NAME=/cgi-bin/page.sh"])
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.047670   28907 strace.go:605] [  19:  19] page.sh X execve(0x522f90 /bin/cat, 0x522ed0 ["cat", "../etc/passwd"], 0x522ee8 ["GATEWAY_INTERFACE=CGI/1.1", "HOSTNAME=2bb1fdfd8add", "SHLVL=2", "REMOTE_ADDR=[::ffff:172.17.0.4]", "HOME=/root", "OLDPWD=/www/cgi-bin", "QUERY_STRING=name=../etc/passwd", "HTTP_USER_AGENT=curl/7.86.0-DEV", "REMOTE_PORT=58778", "HTTP_ACCEPT=*/*", "SCRIPT_FILENAME=/www/cgi-bin/page.sh", "HTTP_HOST=box101:3000", "REQUEST_URI=/cgi-bin/page.sh?name=../etc/passwd", "SERVER_SOFTWARE=busybox httpd/1.35.0", "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin", "SERVER_PROTOCOL=HTTP/1.1", "PATH_INFO=", "REQUEST_METHOD=GET", "PWD=/www", "SCRIPT_NAME=/cgi-bin/page.sh"]) = 0 (0x0) (235.218µs)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.048502   28907 strace.go:567] [  19:  19] cat E open(0x7ed669af0dca ../etc/passwd, O_RDONLY|0x0, 0o0)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.048521   28907 strace.go:605] [  19:  19] cat X open(0x7ed669af0dca ../etc/passwd, O_RDONLY|0x0, 0o0) = 3 (0x3) (8.378µs)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.048665   28907 strace.go:570] [  19:  19] cat E sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.048822   28907 strace.go:608] [  19:  19] cat X sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000) = 340 (0x154) (140.552µs)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.049197   28907 strace.go:570] [  19:  19] cat E sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.049231   28907 strace.go:608] [  19:  19] cat X sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000) = 0 (0x0) (5.08µs)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.049516   28907 strace.go:561] [  19:  19] cat E close(0x3 /etc/passwd)
/tmp/runsc/runsc.log.20231129-111914.726806.boot.txt:I1129 11:19:19.049535   28907 strace.go:599] [  19:  19] cat X close(0x3 /etc/passwd) = 0 (0x0) (3.294µs)
```

The log output indicates that the Busybox HTTPd CGI script read the sensitive file `/etc/passwd`, which is an example of Indicators of Compromise related to "Path Traversal" and "Exfiltration Over Web Service" attacks. However, what might not be immediately apparent is that curl, a commonly used HTTP client tool, also read the `/etc/passwd` file. Without monitoring the syscalls in the container, we may fail to detect this behavior and realize that some network tools have the functionality to read sensitive files like `/etc/passwd`.

To highlight curl’s system call, we execute `grep "/etc/passwd" /tmp/runsc/* | egrep "curl.*read"` and obtain the following:

```log
/tmp/runsc/runsc.log.20231129-111915.376630.boot.txt:I1129 11:19:18.951779   29017 strace.go:567] [   4:   4] curl E read(0x3 /etc/passwd, 0x7eba88d8a670, 0x400)
/tmp/runsc/runsc.log.20231129-111915.376630.boot.txt:I1129 11:19:18.951807   29017 strace.go:605] [   4:   4] curl X read(0x3 /etc/passwd, 0x7eba88d8a670 "root:x:0:0:root:/root:/bin/ash\nbin:x:1:1:bin:/bin:/sbin/nologin\ndaemon:x:2:2:daemon:/sbin:/sbin/nologin\nadm:x:3:4:adm:/var/adm:/sbin/nologin\nlp:x:4:7:lp:/var/spool/lpd:/sbin/nologin\nsync:x:5:0:sync:/sbin:/bin/sync\nshutdown:x:6:0:shutdown:/sbin:/sbin/shutdown\nhalt:x:7:0:halt:/sbin:/sbin/halt\nmail:x:8:12:mail:/var/mail:/sbin/nologin\nnews:x:9:13:news:/usr/lib/news:/sbin/nologin\nuucp:x:10:14:uucp:/var/spool/uucppublic:/sbin/nologin\noperator:x:11:0:operator:/root:/sbin/nologin\nman:x:13:15:man:/usr/man:/sbin/nologin\npostmaster:x:14:12:postmaster:/var/mail:/sbin/nologin\ncron:x:16:16:cron:/var/spool/cron:/sbin/nologin\nftp:x:21:21::/var/lib/ftp:/sbin/nologin\nsshd:x:22:22:sshd:/dev/null:/sbin/nologin\nat:x:25:25:at:/var/spool/cron/atjobs:/sbin/nologin\nsquid:x:31:31:Squid:/var/cache/squid:/sbin/nologin\nxfs:x:33:33:X Font Server:/etc/X11/fs:/sbin/nologin\ngames:x:35:35:games:/usr/games:/sbin/nologin\ncyrus:x:85:12::/usr/cyrus:/sbin/nologin\nvpopmail:x:89:89::/var/vpopmail:/sbin/nologin\nntp:x:123:123:NTP:/var/empty:/sbin/nolo", 0x400) = 1024 (0x400) (4.955µs)
```

The shell script uses a combination of grep and egrep to filter the content of files within the /tmp/runsc/ directory. Here’s a step-by-step explanation:

1. `grep "/etc/passwd"`: This command searches for the string "/etc/passwd" within all files inside the `/tmp/runsc/` directory. The asterisk (*) is a wildcard character that matches all files in that directory. The double quotes around /etc/passwd ensure that the search pattern is treated as a single string, so it looks exactly for occurrences of "/etc/passwd" and not `/etc/passwd` as separate parts.
2. `/tmp/runsc/*`: Indicates all files in the /tmp/runsc/ directory. grep will search each file in that directory for the given pattern.
3. `|`: The pipe operator takes the output from the grep command on the left and makes it the input for the egrep command on the right.
4. `egrep "curl.*read"`: This command filters the output received from the first grep command. egrep is an extended version of grep, which supports extended regular expressions. In this case, it looks for lines that contain the string "curl" followed by any character (.) repeated zero or more times (*), and then the string "read."

Summarized, the script is looking for lines in all files within the `/tmp/runsc/` directory that contain the string "/etc/passwd", and of those lines, it filters and displays only the ones that have the word "curl" somewhere before the word "read". This would typically match command lines or code snippets that refer to `/etc/passwd` in the context of a curl command that includes reading, or it could be looking for potential security issues where the `/etc/passwd` file is being read by a curl command (perhaps indicating an attempt to exfiltrate contents of the file).

This confirms that curl executed a read operation on the `/etc/passwd` file. A copy of the runsc logs can be found in the tmp-runsc subdirectory of this guide. For more information on these types of attacks, you can refer to the following resources:

- Path Traversal | OWASP Foundation https://owasp.org/www-community/attacks/Path_Traversal
- Exfiltration Over Web Service, Technique T1567 - Enterprise | MITRE ATT&CK® https://attack.mitre.org/techniques/T1567/
- Sand & Honey: Building Honeypots - Lacework https://www.lacework.com/blog/sand-honey-building-honeypots/

# QA

1. What does DevSecOps stand for? A) Development, Security, and Operations B) Device Security and Optimization C) Development, Services, and Opportunities D) Device, Software, and Operations
   - Correct Answer: A) Development, Security, and Operations 
   - Explanation: "DevSecOps stands for development, security, and operations."
2. What is the primary goal of incorporating honeypots in DevSecOps? A) To entertain cyberattackers B) To train attackers with better methods C) To lure and study cyberattacker methods D) To create additional tasks for security teams
   - Correct Answer: C) To lure and study cyberattacker methods 
   - Explanation: "Honeypots are decoy systems or traps designed to lure cyberattackers and study their methods..."
3. Which of the following is not a benefit of using honeypots in DevSecOps? A) Improved Security Posture B) Attack Analysis and Intelligence C) Guaranteed prevention of all cyberattacks D) Training and Awareness
   - Correct Answer: C) Guaranteed prevention of all cyberattacks 
   - Explanation: While honeypots provide numerous benefits, they do not guarantee the prevention of all cyberattacks. Instead, they are part of a comprehensive security approach.
4. What does gVisor primarily provide for container workloads? A) Accelerated performance B) Strong isolation C) User authentication D) Data visualization
   - Correct Answer: B) Strong isolation 
   - Explanation: "gVisor, a sandboxing tool developed by Google, is designed to provide strong isolation for container workloads."
5. Which of the following is an example of an Indicator of Compromise (IOC)? A) Bloated software B) Completed transactions C) Unexpected new programs installed without knowledge D) Regular log rotation
   - Correct Answer: C) Unexpected new programs installed without knowledge 
   - Explanation: "IOCs can include unexpected new programs installed without your knowledge."
6. What is the main trade-off mentioned when using gVisor's increased IOC visibility? A) Decreased network security B) Higher system storage requirements C) Impact on performance D) Improved application interaction
   - Correct Answer: C) Impact on performance 
   - Explanation: "The per-system call overhead introduced by gVisor's architecture could potentially impact performance..."
7. What kind of attack is indicated by the log output that shows the Busybox HTTPd CGI script reading the sensitive file /etc/passwd? A) Denial of Service attack B) Path Traversal attack C) SQL Injection attack D) Cross-Site Scripting attack
   - Correct Answer: B) Path Traversal attack 
   - Explanation: "The log output indicates... 'Path Traversal' and 'Exfiltration Over Web Service' attacks."
8. What type of system call made by curl confirms its attempt to read the /etc/passwd file? A) write B) execute C) read D) open
   - Correct Answer: C) read 
   - Explanation: "This confirms that curl executed a read operation on the /etc/passwd file."
9. When configuring Docker to use gVisor's runsc, where is the configuration typically located? A) /bin/docker/config.json B) /usr/lib/docker/daemon.json C) /etc/docker/daemon.json D) /home/docker/.dockerconfig
   - Correct Answer: C) /etc/docker/daemon.json 
   - Explanation: "Below is the Docker runtime configuration for gVisor's runsc, located in /etc/docker/daemon.json."
10. In the docker-compose.yaml provided in the article, which network mode are the services configured to use? A) host B) none C) bridge D) overlay
    - Correct Answer: C) bridge 
    - Explanation: "network_mode: bridge"
11. Which Docker command do you use to start the containers as per the article's demonstration? A) docker run -d B) docker start -d C) docker-compose start -d D) docker-compose up -d
    - Correct Answer: D) docker-compose up -d 
    - Explanation: "We start the demonstration by running docker compose up -d."
12. Which of the following log messages could be associated with a Path Traversal and Exfiltration Over Web Service attack? A) sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000) B) close(0x3 /etc/passwd) C) "Content-Type: text/html" D) chmod 700 /www/cgi-bin/page.sh
    - Correct Answer: A) sendfile(0x1 pipe:[7], 0x3 /etc/passwd, 0x0, 0x1000000) 
    - Explanation: The sendfile system call indicates the file /etc/passwd being read and possibly exfiltrated.
13. What operational mode does gVisor's runsc use to run system calls? A) Kernel mode B) Userspace mode C) Hypervisor mode D) Bootloader mode
    - Correct Answer: B) Userspace mode 
    - Explanation: "Its unique approach of intercepting system calls and running them through a guest kernel residing in userspace results in a form of lightweight virtualization."
14. What kind of files do the runtimeArgs in /etc/docker/daemon.json indicate gVisor's runsc is configured to generate? A) Performance reports B) Debug logs C) User profiles D) Traffic statistics
    - Correct Answer: B) Debug logs 
    - Explanation: "runtimeArgs": ["--debug-log=/tmp/runsc/", "--debug", ...]
15. What is the primary purpose of honeypots in a security context? A) Data storage B) Traffic rerouting C) Intrusion deception and analysis D) Performance testing
    - Correct Answer: C) Intrusion deception and analysis 
    - Explanation: "...honeypots can provide several benefits, aligning with the mindset of incorporating security practices throughout the development, deployment, and maintenance lifecycle."
16. In the provided docker-compose.yaml, what port is Busybox's HTTPd configured to listen on? A) 80 B) 3000 C) 8080 D) 443
    - Correct Answer: B) 3000 
    - Explanation: "busybox httpd -fv -p 3000"
17. What is the command used for the "box201" service in the docker-compose.yaml? A) To ping the "box101" service B) To copy files from "box101" to "box201" C) Make a series of HTTP requests to the "box101" service D) Execute a database query against "box101"
    - Correct Answer: C) Make a series of HTTP requests to the "box101" service 
    - Explanation: The command for "box201" makes curl requests to the HTTP server "box101".
18. According to the article, what can the community sharing of IOCs on the internet be most likened to? A) Classified government intelligence B) Proprietary corporate secrets C) Neighborly gossip D) Public service announcements
    - Correct Answer: D) Public service announcements 
    - Explanation: "On the internet, there are big communities where people share information about suspicious behaviors they've seen, which can be considered IOCs."
19. How can honeypots help organizations from a regulatory point of view? A) By reducing operational costs B) By providing content for marketing purposes C) By helping with breach detection capabilities and proactive security measures D) By decentralizing IT infrastructure
    - Correct Answer: C) By helping with breach detection capabilities and proactive security measures
    - Explanation: "Honeypots can help organizations comply with regulatory requirements that mandate breach detection capabilities and proactive security measures."
20. In the context of the article, what functionality of network tools is underscored as being particularly concerning? A) Their ability to optimize network traffic B) Their potential use in reading sensitive files C) Their role in network topology mapping D) Their capability to reinforce firewalls
    - Correct Answer: B) Their potential use in reading sensitive files 
    - Explanation: "Without monitoring the syscalls in the container, we may fail to detect this behavior and realize that some network tools have the functionality to read sensitive files like /etc/passwd."
