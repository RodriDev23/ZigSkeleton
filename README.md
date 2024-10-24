# Zig Project Generator CLI

## Overview

This CLI tool allows users to quickly set up a basic structure for a Zig project, including essential files such as the `main.zig` file and the `src` folder. It provides a solid foundation for building and managing Zig projects efficiently.

## Features

- Generates a `main.zig` file as the entry point.
- Creates a `src` directory for your source files.
- Includes a `zig build` setup for easy building in both development and production modes.
- Automates project setup with a single command.

## Installation

Clone this repository and navigate into the project directory:
```bash
git clone <repository_url>
cd <project_directory>
```

Build the CLI tool:
```bash
zig build --release-fast
```

After that, you will see a directory like this:
```bash
zig-out/
```

Navigate inside the `zig-out` directory, and you'll find another directory called `bin`:
```bash
ls
ZigSkeleton
```

Move the binary to `/usr/bin/` with the following command:
```bash
sudo mv ZigSkeleton /usr/bin
```

After this, the installation is complete.

## Usage

To create a new Zig project, simply run the following in your terminal:
```bash
ZigSkeleton
```

This will prompt the program to ask for the project name and generate the following structure:
```
<project_name>/
├── src/
│   └── main.zig
└── build.zig
```

At the end, you can run your project and see a "Hello, World!" output:
```bash
zig build run
```

## Contributing

Feel free to open issues or submit pull requests for improvements and features.
