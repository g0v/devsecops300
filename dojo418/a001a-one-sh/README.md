Let's break down the two scripts and explain why the second script is better due to refactoring.

**Script 1 (app0.sh)**
```sh
#!/bin/sh

# Get the two numbers from the command line arguments
num1=$1
num2=$2

# Add the two numbers
result=$((num1 + num2))

# Print the result
echo $result
```
This script is simple and straightforward. It takes two command-line arguments, adds them together, and prints the result. However, there are a few issues with this script:

* The logic for adding the two numbers is mixed with the script's main flow.
* If we wanted to reuse the addition logic elsewhere in the script, we'd have to duplicate the code or create a separate script.
* The script is not very modular or reusable.

**Script 2 (app1.sh)**
```sh
#!/bin/sh

# Function to add two integers
add() {
  local num1=$1
  local num2=$2
  echo $((num1 + num2))
}

result=$(add "$1" "$2")
echo $result
```
This script is an improved version of the first script. Here's what's changed:

* We've extracted the addition logic into a separate function called `add`. This function takes two arguments, adds them together, and returns the result.
* The main script flow is now simpler and more focused on calling the `add` function with the command-line arguments.
* The `add` function is reusable and can be called from anywhere in the script.

By extracting the addition logic into a separate function, we've achieved several benefits:

* **Modularity**: The script is now more modular, with a clear separation of concerns between the main script flow and the addition logic.
* **Reusability**: The `add` function can be reused throughout the script, reducing code duplication and making the script more maintainable.
* **Readability**: The script is easier to read and understand, as the addition logic is now encapsulated in a single, well-named function.

In summary, refactoring the script to extract the addition logic into a separate function has made the code more modular, reusable, and readable. This is a great example of how refactoring can improve the quality and maintainability of code!

# Motivation

https://en.wikipedia.org/wiki/Code_refactoring

> Refactoring is usually motivated by noticing a code smell. For example, the method at hand may be very long, or it may be a near duplicate of another nearby method. Once recognized, such problems can be addressed by refactoring the source code, or transforming it into a new form that behaves the same as before but that no longer "smells".

> For a long routine, one or more smaller subroutines can be extracted; or for duplicate routines, the duplication can be removed and replaced with one shared function. Failure to perform refactoring can result in accumulating technical debt; on the other hand, refactoring is one of the primary means of repaying technical debt.

Extract Method  https://refactoring.guru/extract-method