# PiZilla

A bare metal OS kernel for the Raspberry Pi 3B, written in Zig.

![Demo](./assets/demo2.png)

## Requirements

- [Zig](https://ziglang.org/) 0.16 or later
- [QEMU](https://www.qemu.org/) with `qemu-system-aarch64` for emulation

## Usage
Clone the repository
```bash
git clone https://github.com/vedjain773/PiZilla.git and cd PiZilla 
```

Build the project
```bash
make
```

Run on QEMU
```bash
make qemu-d
```

## Features
- Preemptive multitasking with a round-robin task scheduler and full context switching
- Interrupt-driven timer with IRQ handling
- Mailbox interface for communicating with the VideoCore GPU
- Framebuffer driver with pixel, line, and bitmap font rendering
- Mini UART and PL011 UART drivers for serial I/O, including keyboard input
- A playable Pong game (player vs. AI) with a live tick counter, running entirely on bare metal

### Controls
The pong game uses standard WASD controls.

## About
The project was greatly inspired by NovaPI, a similar project some friends at my club worked on a 
year back. I've always been interested in compilers and systems programming in general, and wanted to pick up a project related to OS development.

Although C was the default choice for kernel/OS related projects like these, I wanted to use a 
more modern language to get a more unique developer experience out of this. I initially leaned
toward using Rust, but its borrow checker and the need to add mut every time I needed a mutable variable seemed pretty weird to me coming from languages like C/C++.

It was for these reasons that I decided to go with Zig instead. The syntax felt much more
intuitive to me than Rust's ever did, and it just felt like the language was built for embedded/OS development. I was also a massive fan of the cross compiler bundled in with Zig, and the fact that it uses LLVM under the hood (I'm a massive fan of the LLVM project).

That said, I'm still pretty new to the language, and much of the code I've written in Zig comes from a C/C++ mindset, so it definitely isn't the most elegant Zig codebase out there.

## Acknowledgements

- [raspberry-pi-os](https://github.com/s-matyukevich/raspberry-pi-os)
- [NovaPi](https://github.com/moxybaba/NovaPi)
