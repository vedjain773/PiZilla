# PiZilla

A bare metal OS kernel for the Raspberry Pi 3B, written in Zig.

![Demo](./assets/demo2.png)

## Requirements

- [Zig](https://ziglang.org/) 0.16 or later
- [QEMU](https://www.qemu.org/) with `qemu-system-aarch64` for emulation

## Usage
Clone the repository
```bash
git clone https://github.com/vedjain773/PiZilla.git
cd PiZilla
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

At its core, PiZilla runs a preemptive round-robin scheduler with full context switching, driven by an interrupt-based timer and IRQ handling, so multiple tasks actually share the CPU rather than running cooperatively.

For I/O, it talks to the VideoCore GPU through the mailbox interface and drives a framebuffer capable of pixel, line, and bitmap font rendering. Serial input and output are handled by both the Mini UART and PL011 UART drivers, including keyboard input.

To put it all together, the kernel runs a playable game of Pong (player vs. AI) with WASD controls and a live tick counter, entirely on bare metal with no OS underneath.

## About

Inspired by [NovaPI](https://github.com/moxybaba/NovaPi), a project some friends built at my club. I wanted to try OS development and picked Zig over C or Rust — it felt purpose-built for embedded/systems work, without Rust's borrow-checker friction. I'm still new to the language, so the code leans more C/C++ in style than idiomatic Zig.

## Acknowledgements

- [raspberry-pi-os](https://github.com/s-matyukevich/raspberry-pi-os)
- [NovaPi](https://github.com/moxybaba/NovaPi)
