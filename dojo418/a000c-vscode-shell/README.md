# shell in vscode

- http://localhost:3000/?folder=/home/workspace
- new terminal
- sh app.sh
- mkdir myporject
- code myproject

NOTE: Experiencing copy-paste issues with openvscode-server in Firefox? Try switching to Chrome, which should resolve the problem.

## Introduction to Shell Scripting: Understanding the Basics

Shell scripting is a powerful way to automate tasks in UNIX and Linux systems. We'll break down the provided script, exploring its components, and explaining how you can modify it or use its elements in your scripts. By the end of this guide, you'll be comfortable with basic shell scripting concepts and ready to write your own scripts.

#### Table of Contents:
1. Introduction to Shell Scripting
2. Step-by-Step Breakdown of the Script
3. Running and Customizing Your Script

---

### Introduction to Shell Scripting

Shell scripting involves writing a series of commands in a text file to be executed by the shell. It is useful for automating repetitive tasks, managing system operations, and simplifying complex sequences of commands.

#### Choosing a Shell
- **sh (Bourne Shell)**: A straightforward shell, good for scripts that need portability across different UNIX systems.
- **bash (Bourne Again Shell)**: An enhanced version of sh, common in Linux systems, offering more features.

The provided script uses `sh`, making it portable and compatible with many UNIX systems.

---

### Step-by-Step Breakdown of the Script

Let's break down the script line by line to understand its components and how they work.

1. **Shebang Line**: 
    ```sh
    #!/bin/sh
    ```
    This specifies the script should be executed using the Bourne shell (`sh`).

2. **Displaying Available Shells**:
    ```sh
    cat /etc/shells
    ```
    The `cat` command displays the contents of `/etc/shells`, showing available shells on the system.

3. **Clearing the Screen**:
    ```sh
    clear
    ```
    Clears the terminal screen for a clean start.

4. **Greeting the User**:
    ```sh
    echo "Hello, $USER"
    ```
    `echo` prints text to the terminal. `$USER` is an environment variable representing the current logged-in user's name.

5. **Displaying the Date and Week Number**:
    ```sh
    echo "Today's date is `date`, this is week `date +"%V"`."
    ```
    The `date` command is used here twice. The outer backticks (`` ` ``) execute the `date` command to show the current date and time. The inner command (`date +"%V"`) fetches the current week number of the year.

6. **Displaying System Information**:
    ```sh
    echo "This is `uname -s` running on a `uname -m` processor."
    ```
    - `uname -s`: Shows the operating system name.
    - `uname -m`: Displays the machine hardware name.

7. **Showing Uptime Information**:
    ```sh
    echo "This is the uptime information:"
    uptime
    ```
    `uptime` provides information about how long the system has been running.

8. **Ending Message**:
    ```sh
    echo
    echo "That's all folks!"
    ```

---

### Running and Customizing Your Script

1. **Saving the Script**:
   - Save the script with a `.sh` extension, for example `myscript.sh`.

2. **Making the Script Executable**:
   ```sh
   chmod +x myscript.sh
   ```
   This command gives execute permission to your script.

3. **Running the Script**:
   ```sh
   ./myscript.sh
   ```
   Execute your script from the terminal.

4. **Customizing the Script**:
   - Modify any `echo` statements to provide different messages.
   - Add your own commands such as `ls` to list files, or `df` to display disk space usage.
